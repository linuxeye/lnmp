#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_PHP-5-3()
{
cd $lnmp_dir/src
. ../functions/download.sh 
. ../functions/check_os.sh
. ../options.conf

src_url=http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz && Download_src
src_url=http://downloads.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz && Download_src
src_url=http://downloads.sourceforge.net/project/mhash/mhash/0.9.9.9/mhash-0.9.9.9.tar.gz && Download_src
src_url=http://downloads.sourceforge.net/project/mcrypt/MCrypt/2.6.8/mcrypt-2.6.8.tar.gz && Download_src
src_url=http://www.php.net/distributions/php-5.3.28.tar.gz && Download_src

tar xzf libiconv-1.14.tar.gz
cd libiconv-1.14
./configure --prefix=/usr/local
[ ! -z "`cat /etc/issue | grep 'Ubuntu 13'`" ] && sed -i 's@_GL_WARN_ON_USE (gets@//_GL_WARN_ON_USE (gets@' srclib/stdio.h 
make && make install
cd ../
/bin/rm -rf libiconv-1.14

tar xzf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8
./configure
make && make install
ldconfig
cd libltdl/
./configure --enable-ltdl-install
make && make install
cd ../../
/bin/rm -rf libmcrypt-2.5.8

tar xzf mhash-0.9.9.9.tar.gz
cd mhash-0.9.9.9
./configure
make && make install
cd ../
/bin/rm -rf mhash-0.9.9.9 

# linked library
if [ "$PHP_MySQL_driver" == '1' ];then
        PHP_MySQL_options="--with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd"
elif [ "$PHP_MySQL_driver" == '2' ];then
        [ "$DB_yn" == 'n' ] && db_install_dir=$mysql_install_dir
        ln -s $db_install_dir/include /usr/include/mysql
        PHP_MySQL_options="--with-mysql=$db_install_dir --with-mysqli=$db_install_dir/bin/mysql_config --with-pdo-mysql=$db_install_dir/bin/mysql_config"
fi
echo "$db_install_dir/lib" > /etc/ld.so.conf.d/mysql.conf
echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
ldconfig
OS_CentOS='ln -s /usr/local/bin/libmcrypt-config /usr/bin/libmcrypt-config \n
if [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 64 ];then \n
        ln -s /lib64/libpcre.so.0.0.1 /lib64/libpcre.so.1 \n
else \n
        ln -s /lib/libpcre.so.0.0.1 /lib/libpcre.so.1 \n
fi'
OS_command

tar xzf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8
ldconfig
./configure
make && make install
cd ../
/bin/rm -rf mcrypt-2.6.8 

tar xzf php-5.3.28.tar.gz
useradd -M -s /sbin/nologin www
wget -O fpm-race-condition.patch 'https://bugs.php.net/patch-display.php?bug_id=65398&patch=fpm-race-condition.patch&revision=1375772074&download=1'
patch -d php-5.3.28 -p0 < fpm-race-condition.patch
cd php-5.3.28
make clean
if [ "$Apache_version" == '1' -o "$Apache_version" == '2' ];then
CFLAGS= CXXFLAGS= ./configure --prefix=$php_install_dir --with-config-file-path=$php_install_dir/etc \
--with-apxs2=$apache_install_dir/bin/apxs $PHP_MySQL_options --disable-fileinfo \
--with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib \
--with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-exif \
--enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex \
--enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl \
--with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-ftp \
--with-gettext --enable-zip --enable-soap --disable-ipv6 --disable-debug
else
CFLAGS= CXXFLAGS= ./configure --prefix=$php_install_dir --with-config-file-path=$php_install_dir/etc \
--with-fpm-user=www --with-fpm-group=www --enable-fpm $PHP_MySQL_options --disable-fileinfo \
--with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib \
--with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-exif \
--enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex \
--enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl \
--with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-ftp \
--with-gettext --enable-zip --enable-soap --disable-ipv6 --disable-debug
fi
make ZEND_EXTRA_LIBS='-liconv'
make install

if [ -d "$php_install_dir" ];then
        echo -e "\033[32mPHP install successfully! \033[0m"
else
        echo -e "\033[31mPHP install failed, Please Contact the author! \033[0m"
        kill -9 $$
fi

[ -n "`cat /etc/profile | grep 'export PATH='`" -a -z "`cat /etc/profile | grep $php_install_dir`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=$php_install_dir/bin:\1@" /etc/profile
. /etc/profile

# wget -c http://pear.php.net/go-pear.phar
# $php_install_dir/bin/php go-pear.phar

/bin/cp php.ini-production $php_install_dir/etc/php.ini

# Modify php.ini
Mem=`free -m | awk '/Mem:/{print $2}'`
if [ $Mem -gt 1024 -a $Mem -le 1500 ];then
        Memory_limit=192
elif [ $Mem -gt 1500 -a $Mem -le 3500 ];then
        Memory_limit=256
elif [ $Mem -gt 3500 -a $Mem -le 4500 ];then
        Memory_limit=320
elif [ $Mem -gt 4500 ];then
        Memory_limit=448
else
        Memory_limit=128
fi
sed -i "s@^memory_limit.*@memory_limit = ${Memory_limit}M@" $php_install_dir/etc/php.ini
sed -i 's@^output_buffering =@output_buffering = On\noutput_buffering =@' $php_install_dir/etc/php.ini
sed -i 's@^;cgi.fix_pathinfo.*@cgi.fix_pathinfo=0@' $php_install_dir/etc/php.ini
sed -i 's@^short_open_tag = Off@short_open_tag = On@' $php_install_dir/etc/php.ini
sed -i 's@^expose_php = On@expose_php = Off@' $php_install_dir/etc/php.ini
sed -i 's@^request_order.*@request_order = "CGP"@' $php_install_dir/etc/php.ini
sed -i 's@^;date.timezone.*@date.timezone = Asia/Shanghai@' $php_install_dir/etc/php.ini
sed -i 's@^post_max_size.*@post_max_size = 50M@' $php_install_dir/etc/php.ini
sed -i 's@^upload_max_filesize.*@upload_max_filesize = 50M@' $php_install_dir/etc/php.ini
sed -i 's@^;upload_tmp_dir.*@upload_tmp_dir = /tmp@' $php_install_dir/etc/php.ini
sed -i 's@^max_execution_time.*@max_execution_time = 300@' $php_install_dir/etc/php.ini
sed -i 's@^disable_functions.*@disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket@' $php_install_dir/etc/php.ini
sed -i 's@^session.cookie_httponly.*@session.cookie_httponly = 1@' $php_install_dir/etc/php.ini
sed -i 's@^mysqlnd.collect_memory_statistics.*@mysqlnd.collect_memory_statistics = On@' $php_install_dir/etc/php.ini
[ -e /usr/sbin/sendmail ] && sed -i 's@^;sendmail_path.*@sendmail_path = /usr/sbin/sendmail -t -i@' $php_install_dir/etc/php.ini

if [ "$Apache_version" != '1' -a "$Apache_version" != '2' ];then
# php-fpm Init Script
/bin/cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
OS_CentOS='chkconfig --add php-fpm \n
chkconfig php-fpm on'
OS_Debian_Ubuntu='update-rc.d php-fpm defaults'
OS_command

cat > $php_install_dir/etc/php-fpm.conf <<EOF
;;;;;;;;;;;;;;;;;;;;;
; FPM Configuration ;
;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;
; Global Options ;
;;;;;;;;;;;;;;;;;;

[global]
pid = run/php-fpm.pid
error_log = log/php-fpm.log
log_level = notice

emergency_restart_threshold = 30
emergency_restart_interval = 60s 
process_control_timeout = 5s
daemonize = yes

;;;;;;;;;;;;;;;;;;;;
; Pool Definitions ;
;;;;;;;;;;;;;;;;;;;;

[www]
listen = /dev/shm/php-cgi.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = www
listen.group = www
listen.mode = 0666
user = www
group = www

pm = dynamic
pm.max_children = 12
pm.start_servers = 8
pm.min_spare_servers = 6
pm.max_spare_servers = 12
pm.max_requests = 2048
pm.process_idle_timeout = 10
request_terminate_timeout = 120
request_slowlog_timeout = 0

slowlog = log/slow.log
rlimit_files = 51200
rlimit_core = 0

catch_workers_output = yes
env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp
EOF

[ -d "/run/shm" -a ! -e "/dev/shm" ] && sed -i 's@/dev/shm@/run/shm@' $php_install_dir/etc/php-fpm.conf $lnmp_dir/vhost.sh $lnmp_dir/conf/nginx.conf 

if [ $Mem -le 3000 ];then
        sed -i "s@^pm.max_children.*@pm.max_children = $(($Mem/2/20))@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.start_servers.*@pm.start_servers = $(($Mem/2/30))@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = $(($Mem/2/40))@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = $(($Mem/2/20))@" $php_install_dir/etc/php-fpm.conf
elif [ $Mem -gt 3000 -a $Mem -le 4500 ];then
        sed -i "s@^pm.max_children.*@pm.max_children = 80@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.start_servers.*@pm.start_servers = 50@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 40@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 80@" $php_install_dir/etc/php-fpm.conf
elif [ $Mem -gt 4500 -a $Mem -le 6500 ];then
        sed -i "s@^pm.max_children.*@pm.max_children = 90@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.start_servers.*@pm.start_servers = 60@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 50@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 90@" $php_install_dir/etc/php-fpm.conf
elif [ $Mem -gt 6500 -a $Mem -le 8500 ];then
        sed -i "s@^pm.max_children.*@pm.max_children = 100@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.start_servers.*@pm.start_servers = 70@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 60@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 100@" $php_install_dir/etc/php-fpm.conf
elif [ $Mem -gt 8500 ];then
        sed -i "s@^pm.max_children.*@pm.max_children = 120@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.start_servers.*@pm.start_servers = 80@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 70@" $php_install_dir/etc/php-fpm.conf
        sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 120@" $php_install_dir/etc/php-fpm.conf
fi

[ "$Web_yn" == 'n' ] && sed -i "s@^listen =.*@listen = $local_IP:9000@" $php_install_dir/etc/php-fpm.conf 
service php-fpm start
elif [ "$Apache_version" == '1' -o "$Apache_version" == '2' ];then
service httpd restart
fi
cd ..
/bin/rm -rf php-5.3.28 
cd ..
}
