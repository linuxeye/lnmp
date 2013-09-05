#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_Tengine()
{
cd $lnmp_dir/src
. ../functions/download.sh 
. ../functions/check_os.sh 
. ../options.conf

src_url=http://ftp.cs.stanford.edu/pub/exim/pcre/pcre-8.33.tar.gz && Download_src
src_url=http://tengine.taobao.org/download/tengine-1.5.1.tar.gz && Download_src

tar xzf pcre-8.33.tar.gz
cd pcre-8.33
./configure
make && make install
cd ../

tar xzf tengine-1.5.1.tar.gz 
cd tengine-1.5.1 

# Modify Tengine version
#sed -i 's@TENGINE "/" TENGINE_VERSION@"Tengine/unknown"@' src/core/nginx.h

# disabled debug
sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' auto/cc/gcc

if [ "$je_tc_malloc" == '1' ];then
	malloc_module='--with-jemalloc'
elif [ "$je_tc_malloc" == '2' ];then
	malloc_module='--with-google_perftools_module'
	mkdir /tmp/tcmalloc
	chown -R www.www /tmp/tcmalloc
else
        malloc_module=
fi

./configure --prefix=$tengine_install_dir --user=www --group=www --with-http_stub_status_module --with-http_ssl_module --with-http_flv_module --with-http_gzip_static_module --with-http_concat_module=shared --with-http_sysguard_module=shared $malloc_module
make && make install
cd ../../
OS_CentOS='/bin/cp init/Nginx-init-CentOS /etc/init.d/nginx \n
chkconfig --add nginx \n
chkconfig nginx on'
OS_Debian_Ubuntu='/bin/cp init/Nginx-init-Ubuntu /etc/init.d/nginx \n
update-rc.d nginx defaults'
OS_command
sed -i "s@/usr/local/nginx@$tengine_install_dir@g" /etc/init.d/nginx

mv $tengine_install_dir/conf/nginx.conf $tengine_install_dir/conf/nginx.conf_bk
sed -i "s@/home/wwwroot/default@$home_dir/default@" conf/nginx.conf
/bin/cp conf/nginx.conf $tengine_install_dir/conf/nginx.conf
sed -i "s@/home/wwwlogs@$wwwlogs_dir@g" $tengine_install_dir/conf/nginx.conf
[ "$je_tc_malloc" == '2' ] && sed -i 's@^pid\(.*\)@pid\1\ngoogle_perftools_profiles /tmp/tcmalloc;@' $tengine_install_dir/conf/nginx.conf 

# worker_cpu_affinity
sed -i "s@^worker_processes.*@worker_processes auto;\nworker_cpu_affinity auto;\ndso {\n\tload ngx_http_concat_module.so;\n\tload ngx_http_sysguard_module.so;\n}@" $tengine_install_dir/conf/nginx.conf

# logrotate nginx log
cat > /etc/logrotate.d/nginx << EOF
$wwwlogs_dir/*.log {
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
sed -i "s@^web_install_dir.*@web_install_dir=$tengine_install_dir@" options.conf
sed -i "s@/usr/local/nginx@$tengine_install_dir@g" vhost.sh
sed -i "s@/home/wwwroot@$home_dir@g" vhost.sh
sed -i "s@/home/wwwlogs@$wwwlogs_dir@g" vhost.sh
service nginx start
}
