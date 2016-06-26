#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_OpenResty() {
cd $oneinstack_dir/src
src_url=http://mirrors.linuxeye.com/oneinstack/src/pcre-$pcre_version.tar.gz && Download_src
src_url=https://openresty.org/download/openresty-$openresty_version.tar.gz && Download_src
src_url=https://www.openssl.org/source/openssl-$openssl_version.tar.gz && Download_src

id -u $run_user >/dev/null 2>&1
[ $? -ne 0 ] && useradd -M -s /sbin/nologin $run_user

tar xzf pcre-$pcre_version.tar.gz
tar xzf openresty-$openresty_version.tar.gz
tar xzf openssl-$openssl_version.tar.gz
cd openresty-$openresty_version

# close debug
openresty_version_tmp=${openresty_version%.*}
sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' bundle/nginx-$openresty_version_tmp/auto/cc/gcc # close debug

if [ "$je_tc_malloc" == '1' ];then
    malloc_module="--with-ld-opt='-ljemalloc'"
elif [ "$je_tc_malloc" == '2' ];then
    malloc_module='--with-google_perftools_module'
    mkdir /tmp/tcmalloc
    chown -R ${run_user}.$run_user /tmp/tcmalloc
fi

[ ! -d "$openresty_install_dir" ] && mkdir -p $openresty_install_dir
./configure --prefix=$openresty_install_dir --user=$run_user --group=$run_user --with-http_stub_status_module --with-http_v2_module --with-http_ssl_module --with-ipv6 --with-http_gzip_static_module --with-http_realip_module --with-http_flv_module --with-openssl=../openssl-$openssl_version --with-pcre=../pcre-$pcre_version --with-pcre-jit $malloc_module
make -j ${THREAD} && make install
if [ -e "$openresty_install_dir/nginx/conf/nginx.conf" ];then
    cd ..
    rm -rf openresty-$openresty_version
    echo "${CSUCCESS}OpenResty installed successfully! ${CEND}"
else
    rm -rf $openresty_install_dir
    echo "${CFAILURE}OpenResty install failed, Please Contact the author! ${CEND}"
    kill -9 $$
fi

[ -z "`grep ^'export PATH=' /etc/profile`" ] && echo "export PATH=$openresty_install_dir/nginx/sbin:\$PATH" >> /etc/profile
[ -n "`grep ^'export PATH=' /etc/profile`" -a -z "`grep $openresty_install_dir /etc/profile`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=$openresty_install_dir/nginx/sbin:\1@" /etc/profile
. /etc/profile

[ "$OS" == 'CentOS' ] && { /bin/cp ../init.d/Nginx-init-CentOS /etc/init.d/nginx; chkconfig --add nginx; chkconfig nginx on; }
[[ $OS =~ ^Ubuntu$|^Debian$ ]] && { /bin/cp ../init.d/Nginx-init-Ubuntu /etc/init.d/nginx; update-rc.d nginx defaults; }
cd ..

sed -i "s@/usr/local/nginx@$openresty_install_dir/nginx@g" /etc/init.d/nginx

mv $openresty_install_dir/nginx/conf/nginx.conf{,_bk}
if [[ $Apache_version =~ ^[1-2]$ ]];then
    /bin/cp config/nginx_apache.conf $openresty_install_dir/nginx/conf/nginx.conf
elif [[ $Tomcat_version =~ ^[1-2]$ ]] && [ ! -e "$php_install_dir/bin/php" ];then
    /bin/cp config/nginx_tomcat.conf $openresty_install_dir/nginx/conf/nginx.conf
else
    /bin/cp config/nginx.conf $openresty_install_dir/nginx/conf/nginx.conf
    [ "$PHP_yn" == 'y' ] && [ -z "`grep '/php-fpm_status' $openresty_install_dir/nginx/conf/nginx.conf`" ] &&  sed -i "s@index index.html index.php;@index index.html index.php;\n    location ~ /php-fpm_status {\n        #fastcgi_pass remote_php_ip:9000;\n        fastcgi_pass unix:/dev/shm/php-cgi.sock;\n        fastcgi_index index.php;\n        include fastcgi.conf;\n        allow 127.0.0.1;\n        deny all;\n        }@" $openresty_install_dir/nginx/conf/nginx.conf
fi
cat > $openresty_install_dir/nginx/conf/proxy.conf << EOF
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
sed -i "s@/data/wwwroot/default@$wwwroot_dir/default@" $openresty_install_dir/nginx/conf/nginx.conf
sed -i "s@/data/wwwlogs@$wwwlogs_dir@g" $openresty_install_dir/nginx/conf/nginx.conf
sed -i "s@^user www www@user $run_user $run_user@" $openresty_install_dir/nginx/conf/nginx.conf
[ "$je_tc_malloc" == '2' ] && sed -i 's@^pid\(.*\)@pid\1\ngoogle_perftools_profiles /tmp/tcmalloc;@' $openresty_install_dir/nginx/conf/nginx.conf

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
