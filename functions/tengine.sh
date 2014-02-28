#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_Tengine()
{
cd $lnmp_dir/src
. ../functions/download.sh 
. ../functions/check_os.sh 
. ../options.conf

src_url=http://downloads.sourceforge.net/project/pcre/pcre/8.34/pcre-8.34.tar.gz && Download_src
src_url=http://tengine.taobao.org/download/tengine-2.0.0.tar.gz && Download_src

tar xzf pcre-8.34.tar.gz
cd pcre-8.34
./configure
make && make install
cd ../

tar xzf tengine-2.0.0.tar.gz 
useradd -M -s /sbin/nologin www
cd tengine-2.0.0 

# Modify Tengine version
#sed -i 's@TENGINE "/" TENGINE_VERSION@"Tengine/unknown"@' src/core/nginx.h

# close debug
sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' auto/cc/gcc

if [ "$je_tc_malloc" == '1' ];then
	malloc_module='--with-jemalloc'
elif [ "$je_tc_malloc" == '2' ];then
	malloc_module='--with-google_perftools_module'
	mkdir /tmp/tcmalloc
	chown -R www.www /tmp/tcmalloc
fi

./configure --prefix=$tengine_install_dir --user=www --group=www --with-http_stub_status_module --with-http_ssl_module --with-http_flv_module --with-http_gzip_static_module --with-http_concat_module=shared --with-http_sysguard_module=shared $malloc_module
make && make install
if [ -d "$tengine_install_dir" ];then
        echo -e "\033[32mTengine install successfully! \033[0m"
else
        echo -e "\033[31mTengine install failed, Please Contact the author! \033[0m"
        kill -9 $$
fi

[ -n "`cat /etc/profile | grep 'export PATH='`" -a -z "`cat /etc/profile | grep $tengine_install_dir`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=\1:$tengine_install_dir/bin@" /etc/profile
. /etc/profile

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
if [ "$Apache_version" == '1' -o "$Apache_version" == '2' ];then
        /bin/cp conf/nginx_apache.conf $tengine_install_dir/conf/nginx.conf
else
        /bin/cp conf/nginx.conf $tengine_install_dir/conf/nginx.conf
fi
sed -i "s@/home/wwwlogs@$wwwlogs_dir@g" $tengine_install_dir/conf/nginx.conf
[ "$je_tc_malloc" == '2' ] && sed -i 's@^pid\(.*\)@pid\1\ngoogle_perftools_profiles /tmp/tcmalloc;@' $tengine_install_dir/conf/nginx.conf 

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

sed -i "s@^web_install_dir.*@web_install_dir=$tengine_install_dir@" options.conf
sed -i "s@/home/wwwroot@$home_dir@g" vhost.sh
sed -i "s@/home/wwwlogs@$wwwlogs_dir@g" vhost.sh
ldconfig
service nginx start
}
