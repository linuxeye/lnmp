#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       http://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_Tengine() {
cd $oneinstack_dir/src
src_url=http://mirrors.linuxeye.com/oneinstack/src/pcre-$pcre_version.tar.gz && Download_src
src_url=http://tengine.taobao.org/download/tengine-$tengine_version.tar.gz && Download_src

tar xzf pcre-$pcre_version.tar.gz
cd pcre-$pcre_version
./configure
make && make install
cd ..

id -u $run_user >/dev/null 2>&1
[ $? -ne 0 ] && useradd -M -s /sbin/nologin $run_user 

tar xzf tengine-$tengine_version.tar.gz 
cd tengine-$tengine_version 
# Modify Tengine version
#sed -i 's@TENGINE "/" TENGINE_VERSION@"Tengine/unknown"@' src/core/nginx.h

# close debug
sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' auto/cc/gcc

if [ "$je_tc_malloc" == '1' ];then
    malloc_module='--with-jemalloc'
elif [ "$je_tc_malloc" == '2' ];then
    malloc_module='--with-google_perftools_module'
    mkdir /tmp/tcmalloc
    chown -R ${run_user}.$run_user /tmp/tcmalloc
fi

[ ! -d "$tengine_install_dir" ] && mkdir -p $tengine_install_dir
./configure --prefix=$tengine_install_dir --user=$run_user --group=$run_user --with-http_stub_status_module --with-http_spdy_module --with-http_ssl_module --with-ipv6 --with-http_gzip_static_module --with-http_realip_module --with-http_flv_module --with-http_concat_module=shared --with-http_sysguard_module=shared $malloc_module
make && make install
if [ -e "$tengine_install_dir/conf/nginx.conf" ];then
    cd ..
    rm -rf tengine-$tengine_version 
    echo "${CSUCCESS}Tengine install successfully! ${CEND}"
else
    rm -rf $tengine_install_dir
    echo "${CFAILURE}Tengine install failed, Please Contact the author! ${CEND}"
    kill -9 $$
fi

[ -z "`grep ^'export PATH=' /etc/profile`" ] && echo "export PATH=$tengine_install_dir/sbin:\$PATH" >> /etc/profile 
[ -n "`grep ^'export PATH=' /etc/profile`" -a -z "`grep $tengine_install_dir /etc/profile`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=$tengine_install_dir/sbin:\1@" /etc/profile
. /etc/profile

[ "$OS" == 'CentOS' ] && { /bin/cp ../init.d/Nginx-init-CentOS /etc/init.d/nginx; chkconfig --add nginx; chkconfig nginx on; } 
[[ $OS =~ ^Ubuntu$|^Debian$ ]] && { /bin/cp ../init.d/Nginx-init-Ubuntu /etc/init.d/nginx; update-rc.d nginx defaults; } 
cd ..

sed -i "s@/usr/local/nginx@$tengine_install_dir@g" /etc/init.d/nginx

mv $tengine_install_dir/conf/nginx.conf{,_bk}
if [[ $Apache_version =~ ^[1-2]$ ]];then
    /bin/cp config/nginx_apache.conf $tengine_install_dir/conf/nginx.conf
elif [[ $Tomcat_version =~ ^[1-2]$ ]] && [ ! -e "$php_install_dir/bin/php" ];then
    /bin/cp config/nginx_tomcat.conf $tengine_install_dir/conf/nginx.conf
else
    /bin/cp config/nginx.conf $tengine_install_dir/conf/nginx.conf
    [ "$PHP_yn" == 'y' ] && [ -z "`grep '/php-fpm_status' $tengine_install_dir/conf/nginx.conf`" ] &&  sed -i "s@index index.html index.php;@index index.html index.php;\n    location ~ /php-fpm_status {\n        #fastcgi_pass remote_php_ip:9000;\n        fastcgi_pass unix:/dev/shm/php-cgi.sock;\n        fastcgi_index index.php;\n        include fastcgi.conf;\n        allow 127.0.0.1;\n        deny all;\n        }@" $tengine_install_dir/conf/nginx.conf
fi
cat > $tengine_install_dir/conf/proxy.conf << EOF
proxy_connect_timeout 300s;
proxy_send_timeout 900;
proxy_read_timeout 900;
proxy_buffer_size 32k;
proxy_buffers 4 64k;
proxy_busy_buffers_size 128k;
proxy_redirect off;
proxy_hide_header Vary;
proxy_set_header Accept-Encoding '';
proxy_set_header Referer \$http_referer;
proxy_set_header Cookie \$http_cookie;
proxy_set_header Host \$host;
proxy_set_header X-Real-IP \$remote_addr;
proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
EOF
sed -i "s@/data/wwwroot/default@$wwwroot_dir/default@" $tengine_install_dir/conf/nginx.conf
sed -i "s@/data/wwwlogs@$wwwlogs_dir@g" $tengine_install_dir/conf/nginx.conf
sed -i "s@^user www www@user $run_user $run_user@" $tengine_install_dir/conf/nginx.conf
[ "$je_tc_malloc" == '2' ] && sed -i 's@^pid\(.*\)@pid\1\ngoogle_perftools_profiles /tmp/tcmalloc;@' $tengine_install_dir/conf/nginx.conf 
uname -r | awk -F'.' '{if ($1$2>=39)S=0;else S=1}{exit S}' && [ -z "`grep 'reuse_port on;' $tengine_install_dir/conf/nginx.conf`" ] && sed -i "s@worker_connections 51200;@worker_connections 51200;\n    reuse_port on;@" $tengine_install_dir/conf/nginx.conf

# worker_cpu_affinity
sed -i "s@^worker_processes.*@worker_processes auto;\nworker_cpu_affinity auto;\ndso {\n\tload ngx_http_concat_module.so;\n\tload ngx_http_sysguard_module.so;\n}@" $tengine_install_dir/conf/nginx.conf

# logrotate nginx log
cat > /etc/logrotate.d/nginx << EOF
$wwwlogs_dir/*nginx.log {
daily
rotate 5
missingok
dateext
compress
notifempty
sharedscripts
postrotate
    [ -e /var/run/nginx.pid ] && kill -USR1 \`cat /var/run/nginx.pid\`
endscript
}
EOF

ldconfig
service nginx start
}
