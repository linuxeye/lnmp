#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_Tengine()
{
cd $lnmp_dir/src
. ../functions/download.sh 
. ../functions/check_os.sh 
. ../options.conf

src_url=http://downloads.sourceforge.net/project/pcre/pcre/8.35/pcre-8.35.tar.gz && Download_src
src_url=http://tengine.taobao.org/download/tengine-1.5.2.tar.gz && Download_src

tar xzf pcre-8.35.tar.gz
cd pcre-8.35
./configure
make && make install
cd ../

tar xzf tengine-1.5.2.tar.gz 
useradd -M -s /sbin/nologin www
cd tengine-1.5.2 

# Modify Tengine version
#sed -i 's@TENGINE "/" TENGINE_VERSION@"Tengine/unknown"@' src/core/nginx.h

# close debug
sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' auto/cc/gcc

# make[1]: *** [objs/src/event/ngx_event_openssl.o] Error 1
sed -i 's@\(.*\)this option allow a potential SSL 2.0 rollback (CAN-2005-2969)\(.*\)@#ifdef SSL_OP_MSIE_SSLV2_RSA_PADDING\n\1this option allow a potential SSL 2.0 rollback (CAN-2005-2969)\2@' src/event/ngx_event_openssl.c
sed -i 's@\(.*\)SSL_CTX_set_options(ssl->ctx, SSL_OP_MSIE_SSLV2_RSA_PADDING)\(.*\)@\1SSL_CTX_set_options(ssl->ctx, SSL_OP_MSIE_SSLV2_RSA_PADDING)\2\n#endif@' src/event/ngx_event_openssl.c

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

[ -n "`cat /etc/profile | grep 'export PATH='`" -a -z "`cat /etc/profile | grep $tengine_install_dir`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=$tengine_install_dir/bin:\1@" /etc/profile
. /etc/profile

cd ../../
OS_CentOS='/bin/cp init/Nginx-init-CentOS /etc/init.d/nginx \n
chkconfig --add nginx \n
chkconfig nginx on'
OS_Debian_Ubuntu='/bin/cp init/Nginx-init-Ubuntu /etc/init.d/nginx \n
update-rc.d nginx defaults'
OS_command
sed -i "s@/usr/local/nginx@$tengine_install_dir@g" /etc/init.d/nginx

mv $tengine_install_dir/conf/nginx.conf{,_bk}
if [ "$Apache_version" == '1' -o "$Apache_version" == '2' ];then
        /bin/cp conf/nginx_apache.conf $tengine_install_dir/conf/nginx.conf
else
        /bin/cp conf/nginx.conf $tengine_install_dir/conf/nginx.conf
fi
sed -i "s@/home/wwwroot/default@$home_dir/default@" $tengine_install_dir/conf/nginx.conf
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
