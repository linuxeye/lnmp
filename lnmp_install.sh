#!/bin/bash
# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script, please use root to install lnmp" && kill -9 $$

echo "#######################################################################"
echo "#                    LNMP for CentOS/RadHat 5/6                       #"
echo "# For more information please visit http://blog.linuxeye.com/31.html  #"
echo "#######################################################################"
echo ''

# get ipv4 
IP=`ifconfig | grep 'inet addr:' | cut -d: -f2 | grep -v ^10\. | grep -v ^192\.168 | grep -v ^172\. | grep -v ^127\. | awk '{print  $1}' | awk '{print;exit}'`
[ ! -n "$IP" ] && IP=`ifconfig | grep 'inet addr:' | cut -d: -f2 | grep -v ^127\. | awk '{print  $1}' | awk '{print;exit}'`

#Definition Directory
home_dir=/home/wwwroot
mkdir -p $home_dir
mkdir -p /root/lnmp/{source,conf}

#choice database 
while :
do
        read -p "Do you want to install MySQL or MariaDB ? ( MySQL / MariaDB ) " choice_DB
        choice_db=`echo $choice_DB | tr [A-Z] [a-z]`
        if [ "$choice_db" != 'mariadb' ] && [ "$choice_db" != 'mysql' ];then
                echo -e "\033[31minput error! please input 'MySQL' or 'MariaDB'\033[0m"
        else
                break
        fi
done

#eheck dbrootpwd
while :
do
        read -p "Please input the root password of database:" dbrootpwd
        (( ${#dbrootpwd} >= 5 )) && break || echo -e "\033[31m$choice_DB root password least 5 characters! \033[0m"
done

while :
do
        read -p "Do you want to install Memcache? (y/n)" Memcache_yn
        if [ "$Memcache_yn" != 'y' ] && [ "$Memcache_yn" != 'n' ];then
                echo -e "\033[31minput error! please input 'y' or 'n'\033[0m"
        else
                break
        fi
done

while :
do
        read -p "Do you want to install Pure-FTPd? (y/n)" FTP_yn
        if [ "$FTP_yn" != 'y' ] && [ "$FTP_yn" != 'n' ];then
                echo -e "\033[31minput error! please input 'y' or 'n'\033[0m"
        else
                break
        fi
done

if [ $FTP_yn == 'y' ];then
        while :
        do
                read -p "Please input the manager password of Pureftpd:" ftpmanagerpwd
                (( ${#ftpmanagerpwd} >= 5 )) && break || echo -e "\033[31mFtp manager password least 5 characters! \033[0m"
        done
fi

while :
do
        read -p "Do you want to install phpMyAdmin? (y/n)" phpMyAdmin_yn
        if [ "$phpMyAdmin_yn" != 'y' ] && [ "$phpMyAdmin_yn" != 'n' ];then
                echo -e "\033[31minput error! please input 'y' or 'n'\033[0m"
        else
                break
        fi
done

function Download_src()
{
cd /root/lnmp
[ -s init.sh ] && echo 'init.sh found' || wget -c --no-check-certificate https://raw.github.com/lj2007331/lnmp/master/init.sh
[ -s vhost.sh ] && echo 'vhost.sh found' || wget -c --no-check-certificate https://raw.github.com/lj2007331/lnmp/master/vhost.sh
[ -s install_ngx_pagespeed.sh ] && echo 'install_ngx_pagespeed.sh found' || wget -c --no-check-certificate https://raw.github.com/lj2007331/lnmp/master/install_ngx_pagespeed.sh
cd conf
[ -s tz.zip ] && echo 'tz.zip found' || wget -c http://www.yahei.net/tz/tz.zip 
[ -s index.html ] && echo 'index.html found' || wget -c --no-check-certificate https://raw.github.com/lj2007331/lnmp/master/conf/index.html
[ -s wordpress.conf ] && echo 'wordpress.conf found' || wget -c --no-check-certificate https://raw.github.com/lj2007331/lnmp/master/conf/wordpress.conf
[ -s discuz.conf ] && echo 'discuz.conf found' || wget -c --no-check-certificate https://raw.github.com/lj2007331/lnmp/master/conf/discuz.conf
[ -s phpwind.conf ] && echo 'phpwind.conf found' || wget -c --no-check-certificate https://raw.github.com/lj2007331/lnmp/master/conf/phpwind.conf
[ -s typecho.conf ] && echo 'typecho.conf found' || wget -c --no-check-certificate https://raw.github.com/lj2007331/lnmp/master/conf/typecho.conf
[ -s ecshop.conf ] && echo 'ecshop.conf found' || wget -c --no-check-certificate https://raw.github.com/lj2007331/lnmp/master/conf/ecshop.conf
[ -s drupal.conf ] && echo 'drupal.conf found' || wget -c --no-check-certificate https://raw.github.com/lj2007331/lnmp/master/conf/drupal.conf
[ -s init.d.nginx ] && echo 'init.d.nginx found' || wget -c --no-check-certificate https://raw.github.com/lj2007331/lnmp/master/conf/init.d.nginx
[ -s nginx.conf ] && echo 'nginx.conf found' || wget -c --no-check-certificate https://raw.github.com/lj2007331/lnmp/master/conf/nginx.conf
[ -s pure-ftpd.conf ] && echo 'pure-ftpd.conf found' || wget -c --no-check-certificate https://raw.github.com/lj2007331/lnmp/master/conf/pure-ftpd.conf
[ -s pureftpd-mysql.conf ] && echo 'pureftpd-mysql.conf found' || wget -c --no-check-certificate https://raw.github.com/lj2007331/lnmp/master/conf/pureftpd-mysql.conf
[ -s script.mysql ] && echo 'script.mysql found' || wget -c --no-check-certificate https://raw.github.com/lj2007331/lnmp/master/conf/script.mysql
cd /root/lnmp/source
[ -s cmake-2.8.11.2.tar.gz ] && echo 'cmake-2.8.11.2.tar.gz found' || wget -c http://www.cmake.org/files/v2.8/cmake-2.8.11.2.tar.gz
[ -s mysql-5.6.13.tar.gz ] && echo 'mysql-5.6.13.tar.gz found' || wget -c http://cdn.mysql.com/Downloads/MySQL-5.6/mysql-5.6.13.tar.gz 
[ -s mariadb-5.5.32.tar.gz ] && echo 'mariadb-5.5.32.tar.gz found' || wget -c http://ftp.osuosl.org/pub/mariadb/mariadb-5.5.32/kvm-tarbake-jaunty-x86/mariadb-5.5.32.tar.gz 
[ -s libiconv-1.14.tar.gz ] && echo 'libiconv-1.14.tar.gz found' || wget -c http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
[ -s libmcrypt-2.5.8.tar.gz ] && echo 'libmcrypt-2.5.8.tar.gz found' || wget -c http://iweb.dl.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz
[ -s mhash-0.9.9.9.tar.gz ] && echo 'mhash-0.9.9.9.tar.gz found' || wget -c http://iweb.dl.sourceforge.net/project/mhash/mhash/0.9.9.9/mhash-0.9.9.9.tar.gz
[ -s mcrypt-2.6.8.tar.gz ] && echo 'mcrypt-2.6.8.tar.gz found' || wget -c --no-check-certificate https://vps.googlecode.com/files/mcrypt-2.6.8.tar.gz
[ -s php-5.5.1.tar.gz ] && echo 'php-5.5.1.tar.gz found' || wget -c http://kr1.php.net/distributions/php-5.5.1.tar.gz
[ -s memcached-1.4.15.tar.gz ] && echo 'memcached-1.4.15.tar.gz found' || wget -c --no-check-certificate https://memcached.googlecode.com/files/memcached-1.4.15.tar.gz 
[ -s memcache-2.2.7.tgz ] && echo 'memcache-2.2.7.tgz found' || wget -c http://pecl.php.net/get/memcache-2.2.7.tgz
[ -s ImageMagick-6.8.6-6.tar.gz ] && echo 'ImageMagick-6.8.6-6.tar.gz found' || wget -c ftp://sunsite.icm.edu.pl/packages/ImageMagick/ImageMagick-6.8.6-6.tar.gz 
[ -s imagick-3.1.0RC2.tgz ] && echo 'imagick-3.1.0RC2.tgz found' || wget -c http://pecl.php.net/get/imagick-3.1.0RC2.tgz
[ -s pecl_http-1.7.6.tgz ] && echo 'pecl_http-1.7.6.tgz found' || wget -c http://pecl.php.net/get/pecl_http-1.7.6.tgz
[ -s pcre-8.33.tar.gz ] && echo 'pcre-8.33.tar.gz found' || wget -c http://ftp.exim.llorien.org/pcre/pcre-8.33.tar.gz 
[ -s nginx-1.4.2.tar.gz ] && echo 'nginx-1.4.2.tar.gz found' || wget -c http://nginx.org/download/nginx-1.4.2.tar.gz
[ -s pure-ftpd-1.0.36.tar.gz ] && echo 'pure-ftpd-1.0.36.tar.gz found' || wget -c ftp://ftp.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-1.0.36.tar.gz
[ -s ftp_v2.1.tar.gz ] && echo 'ftp_v2.1.tar.gz found' || wget -c http://machiel.generaal.net/files/pureftpd/ftp_v2.1.tar.gz 
[ -s phpMyAdmin-4.0.5-all-languages.tar.gz ] && echo 'phpMyAdmin-4.0.5-all-languages.tar.gz found' || wget -c http://iweb.dl.sourceforge.net/project/phpmyadmin/phpMyAdmin/4.0.5/phpMyAdmin-4.0.5-all-languages.tar.gz
# check source packages
for src in `cat ./lnmp_install.sh | grep found.*wget | awk '{print $3}' | grep gz`
do
        if [ ! -e "/root/lnmp/source/$src" ];then
                echo -e "\033[31m$src no found! \033[0m"
		echo -e "\033[31mUpdated version of the Package source,Please Contact Author! \033[0m"
                kill -9 $$
        fi
done
}

function Install_MySQL()
{
cd /root/lnmp/source
useradd -M -s /sbin/nologin mysql
mkdir -p $db_data_dir;chown mysql.mysql -R $db_data_dir
tar xzf cmake-2.8.11.2.tar.gz 
cd cmake-2.8.11.2
./configure
make &&  make install
cd ..
tar zxf mysql-5.6.13.tar.gz
cd mysql-5.6.13
cmake . -DCMAKE_INSTALL_PREFIX=$db_install_dir \
-DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
-DMYSQL_DATADIR=$db_data_dir \
-DSYSCONFDIR=/etc \
-DMYSQL_USER=mysql \
-DMYSQL_TCP_PORT=3306 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_EXTRA_CHARSETS=1 \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DEXTRA_CHARSETS=all \
-DWITH_BIG_TABLES=1 \
-DWITH_DEBUG=0
make && make install

if [ -d "$db_install_dir" ];then
        echo -e "\033[32mMySQL install successfully! \033[0m"
else
        echo -e "\033[31mMySQL install failed,Please Contact Author! \033[0m"
        kill -9 $$
fi

/bin/cp support-files/mysql.server /etc/init.d/mysqld 
chmod +x /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig mysqld on
cd ..

# my.cf
cat > /etc/my.cnf << EOF
[mysqld]
basedir = $db_install_dir
datadir = $db_data_dir
pid-file = /var/run/mysql.pid
character-set-server = utf8
collation-server = utf8_general_ci
user = mysql
port = 3306
default_storage_engine = InnoDB
innodb_file_per_table = 1
server_id = 1
log_bin = mysql-bin
binlog_format = mixed
expire_logs_days = 7
bind-address = 0.0.0.0

# name-resolve
skip-name-resolve
skip-host-cache

#lower_case_table_names = 1
ft_min_word_len = 1
query_cache_size = 64M
query_cache_type = 1

skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M

# LOG
log_error = $db_data_dir/mysql-error.log
long_query_time = 1
slow_query_log
slow_query_log_file = $db_data_dir/mysql-slow.log

# Oher
#max_connections = 1000
open_files_limit = 65535

[client]
port = 3306
EOF

$db_install_dir/scripts/mysql_install_db --user=mysql --basedir=$db_install_dir --datadir=$db_data_dir

chown mysql.mysql -R $db_data_dir
/sbin/service mysqld start
export PATH=$PATH:$db_install_dir/bin
echo "export PATH=\$PATH:$db_install_dir/bin" >> /etc/profile
source /etc/profile

$db_install_dir/bin/mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"$dbrootpwd\" with grant option;"
$db_install_dir/bin/mysql -e "grant all privileges on *.* to root@'localhost' identified by \"$dbrootpwd\" with grant option;"
$db_install_dir/bin/mysql -uroot -p$dbrootpwd -e "delete from mysql.user where Password='';"
$db_install_dir/bin/mysql -uroot -p$dbrootpwd -e "delete from mysql.db where User='';"
$db_install_dir/bin/mysql -uroot -p$dbrootpwd -e "drop database test;"
$db_install_dir/bin/mysql -uroot -p$dbrootpwd -e "reset master;"
/sbin/service mysqld restart
}

function Install_MariaDB()
{
cd /root/lnmp/source
useradd -M -s /sbin/nologin mysql
mkdir -p $db_data_dir;chown mysql.mysql -R $db_data_dir
tar xzf cmake-2.8.11.2.tar.gz
cd cmake-2.8.11.2
./configure
make &&  make install
cd ..
tar zxf mariadb-5.5.32.tar.gz
cd mariadb-5.5.32
cmake . -DCMAKE_INSTALL_PREFIX=$db_install_dir \
-DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
-DMYSQL_DATADIR=$db_data_dir \
-DSYSCONFDIR=/etc \
-DMYSQL_USER=mysql \
-DMYSQL_TCP_PORT=3306 \
-DWITH_XTRADB_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_EXTRA_CHARSETS=1 \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DEXTRA_CHARSETS=all \
-DWITH_BIG_TABLES=1 \
-DWITH_DEBUG=0
make && make install

if [ -d "$db_install_dir" ];then
        echo -e "\033[32mMariaDB install successfully! \033[0m"
else
        echo -e "\033[31mMariaDB install failed,Please Contact Author! \033[0m"
        kill -9 $$
fi

/bin/cp support-files/my-small.cnf /etc/my.cnf
/bin/cp support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig mysqld on
cd ..

# my.cf
cat > /etc/my.cnf << EOF
[mysqld]
basedir = $db_install_dir
datadir = $db_data_dir
pid-file = /var/run/mariadb.pid
character-set-server = utf8
collation-server = utf8_general_ci
user = mysql
port = 3306
default_storage_engine = InnoDB
innodb_file_per_table = 1
server_id = 1
log_bin = mysql-bin
binlog_format = mixed
expire_logs_days = 7
bind-address = 0.0.0.0

# name-resolve
skip-name-resolve
skip-host-cache

#lower_case_table_names = 1
ft_min_word_len = 1
query_cache_size = 64M
query_cache_type = 1

skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M

# LOG
log_error = $db_data_dir/mariadb-error.log
long_query_time = 1
slow_query_log
slow_query_log_file = $db_data_dir/mariadb-slow.log

# Oher
#max_connections = 1000
open_files_limit = 65535

[client]
port = 3306
EOF

$db_install_dir/scripts/mysql_install_db --user=mysql --basedir=$db_install_dir --datadir=$db_data_dir

chown mysql.mysql -R $db_data_dir
/sbin/service mysqld start
export PATH=$PATH:$db_install_dir/bin
echo "export PATH=\$PATH:$db_install_dir/bin" >> /etc/profile
source /etc/profile

$db_install_dir/bin/mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"$dbrootpwd\" with grant option;"
$db_install_dir/bin/mysql -e "grant all privileges on *.* to root@'localhost' identified by \"$dbrootpwd\" with grant option;"
$db_install_dir/bin/mysql -uroot -p$dbrootpwd -e "delete from mysql.user where Password='';"
$db_install_dir/bin/mysql -uroot -p$dbrootpwd -e "delete from mysql.db where User='';"
$db_install_dir/bin/mysql -uroot -p$dbrootpwd -e "drop database test;"
$db_install_dir/bin/mysql -uroot -p$dbrootpwd -e "reset master;"
/sbin/service mysqld restart
}

function Install_PHP()
{
cd /root/lnmp/source
tar xzf libiconv-1.14.tar.gz
cd libiconv-1.14
./configure --prefix=/usr/local
make && make install
cd ../

tar xzf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8
./configure
make && make install
/sbin/ldconfig
cd libltdl/
./configure --enable-ltdl-install
make && make install
cd ../../

tar xzf mhash-0.9.9.9.tar.gz
cd mhash-0.9.9.9
./configure
make && make install
cd ../

tar xzf ImageMagick-6.8.6-6.tar.gz
cd ImageMagick-6.8.6-6
./configure
make && make install
cd ../

# linked library
cat >> /etc/ld.so.conf.d/local.conf <<EOF
/usr/local/lib
EOF
cat >> /etc/ld.so.conf.d/mysql.conf <<EOF
$db_install_dir/lib
EOF
/sbin/ldconfig
ln -s /usr/local/bin/libmcrypt-config /usr/bin/libmcrypt-config
ln -s $db_install_dir/include/* /usr/local/include/
ln -s /usr/local/include/ImageMagick-6 /usr/local/include/ImageMagick
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
        ln -s /lib64/libpcre.so.0.0.1 /lib64/libpcre.so.1
        cp -frp /usr/lib64/libldap* /usr/lib
else
        ln -s /lib/libpcre.so.0.0.1 /lib/libpcre.so.1
fi

tar xzf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8
/sbin/ldconfig
./configure
make && make install
cd ../

tar xzf php-5.5.1.tar.gz
useradd -M -s /sbin/nologin www
cd php-5.5.1
./configure  --prefix=/usr/local/php --with-config-file-path=/usr/local/php/etc \
--with-fpm-user=www --with-fpm-group=www --enable-opcache --enable-fpm --with-mysql=$db_install_dir \
--with-mysqli=$db_install_dir/bin/mysql_config --with-pdo-mysql --disable-fileinfo \
--with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib \
--with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-exif \
--enable-sysvsem --enable-inline-optimization --with-curl --with-kerberos --enable-mbregex \
--enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-xsl --with-openssl \
--with-mhash --enable-pcntl --enable-sockets --with-ldap --with-ldap-sasl --with-xmlrpc \
--enable-ftp --with-gettext --enable-zip --enable-soap --disable-ipv6 --disable-debug
make ZEND_EXTRA_LIBS='-liconv'
make install

if [ -d "/usr/local/php" ];then
        echo -e "\033[32mPHP install successfully! \033[0m"
else
        echo -e "\033[31mPHP install failed,Please Contact Author! \033[0m"
        kill -9 $$
fi
#wget -c http://pear.php.net/go-pear.phar
#/usr/local/php/bin/php go-pear.phar

cp php.ini-production /usr/local/php/etc/php.ini

#php-fpm Init Script
cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
chkconfig --add php-fpm
chkconfig php-fpm on
cd ../

tar xzf imagick-3.1.0RC2.tgz
cd imagick-3.1.0RC2
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../

# Support HTTP request curls
tar xzf pecl_http-1.7.6.tgz
cd pecl_http-1.7.6 
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../

# Modify php.ini
sed -i 's@extension_dir = "ext"@extension_dir = "ext"\nextension_dir = "/usr/local/php/lib/php/extensions/no-debug-non-zts-20121212/"\nextension = "imagick.so"\nextension = "http.so"@' /usr/local/php/etc/php.ini
sed -i 's@^output_buffering =@output_buffering = On\noutput_buffering =@' /usr/local/php/etc/php.ini 
sed -i 's@^;cgi.fix_pathinfo.*@cgi.fix_pathinfo=0@' /usr/local/php/etc/php.ini 
sed -i 's@^short_open_tag = Off@short_open_tag = On@' /usr/local/php/etc/php.ini
sed -i 's@^expose_php = On@expose_php = Off@' /usr/local/php/etc/php.ini
sed -i 's@^request_order.*@request_order = "CGP"@' /usr/local/php/etc/php.ini
sed -i 's@^;date.timezone.*@date.timezone = Asia/Shanghai@' /usr/local/php/etc/php.ini
sed -i 's@^post_max_size.*@post_max_size = 50M@' /usr/local/php/etc/php.ini
sed -i 's@^upload_max_filesize.*@upload_max_filesize = 50M@' /usr/local/php/etc/php.ini
sed -i 's@^;upload_tmp_dir.*@upload_tmp_dir = /tmp@' /usr/local/php/etc/php.ini
sed -i 's@^max_execution_time.*@max_execution_time = 300@' /usr/local/php/etc/php.ini
sed -i 's@^disable_functions.*@disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket@' /usr/local/php/etc/php.ini
sed -i 's@^session.cookie_httponly.*@session.cookie_httponly = 1@' /usr/local/php/etc/php.ini
sed -i 's@^pdo_mysql.default_socket.*@pdo_mysql.default_socket = /tmp/mysql.sock@' /usr/local/php/etc/php.ini
sed -i 's@#sendmail_path.*@#sendmail_path = /usr/sbin/sendmail -t@' /usr/local/php/etc/php.ini

sed -i 's@^\[opcache\]@[opcache]\nzend_extension=opcache.so@' /usr/local/php/etc/php.ini
sed -i 's@^;opcache.enable=.*@opcache.enable=1@' /usr/local/php/etc/php.ini
sed -i 's@^;opcache.memory_consumption.*@opcache.memory_consumption=128@' /usr/local/php/etc/php.ini
sed -i 's@^;opcache.interned_strings_buffer.*@opcache.interned_strings_buffer=8@' /usr/local/php/etc/php.ini
sed -i 's@^;opcache.max_accelerated_files.*@opcache.max_accelerated_files=4000@' /usr/local/php/etc/php.ini
sed -i 's@^;opcache.revalidate_freq.*@opcache.revalidate_freq=60@' /usr/local/php/etc/php.ini
sed -i 's@^;opcache.fast_shutdown.*@opcache.fast_shutdown=1@' /usr/local/php/etc/php.ini
sed -i 's@^;opcache.enable_cli.*@opcache.enable_cli=1@' /usr/local/php/etc/php.ini

cat > /usr/local/php/etc/php-fpm.conf <<EOF 
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
emergency_restart_interval = 1m
process_control_timeout = 5s
daemonize = yes

;;;;;;;;;;;;;;;;;;;;
; Pool Definitions ;
;;;;;;;;;;;;;;;;;;;;

[www]

listen = 127.0.0.1:9000
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = www
listen.group = www
listen.mode = 0666
user = www
group = www

pm = dynamic
pm.max_children = 32
pm.start_servers = 4 
pm.min_spare_servers = 4
pm.max_spare_servers = 16
pm.max_requests = 512

request_terminate_timeout = 0
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

service php-fpm start
}

function Install_Memcache()
{
cd /root/lnmp/source
tar xzf memcache-2.2.7.tgz
cd memcache-2.2.7
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
sed -i 's@-zts-20121212/"@-zts-20121212/"\nextension = "memcache.so"@' /usr/local/php/etc/php.ini
cd ../

tar xzf memcached-1.4.15.tar.gz
cd memcached-1.4.15
./configure --prefix=/usr/local/memcached
make && make install

ln -s /usr/local/memcached/bin/memcached /usr/bin/memcached
/bin/cp scripts/memcached.sysv /etc/init.d/memcached
sed -i 's@^USER=.*@USER=root@' /etc/init.d/memcached
sed -i 's@chown@#chown@' /etc/init.d/memcached
sed -i 's@/var/run/memcached/memcached.pid@/var/run/memcached.pid@' /etc/init.d/memcached
sed -i 's@^prog=.*@prog="/usr/local/memcached/bin/memcached"@' /etc/init.d/memcached
chmod +x /etc/init.d/memcached
chkconfig --add memcached
chkconfig memcached on
service php-fpm restart
service memcached start
cd ..
}

function Install_Nginx()
{
cd /root/lnmp/source
tar xzf pcre-8.33.tar.gz
cd pcre-8.33
./configure
make && make install
cd ../

#tar xzf ngx_cache_purge-2.1.tar.gz 
tar xzf nginx-1.4.2.tar.gz
cd nginx-1.4.2

# Modify Nginx version
sed -i 's@#define NGINX_VERSION.*$@#define NGINX_VERSION      "1.2"@g' src/core/nginx.h 
sed -i 's@#define NGINX_VER.*NGINX_VERSION$@#define NGINX_VER          "Linuxeye/" NGINX_VERSION@g' src/core/nginx.h 
#./configure --prefix=/usr/local/nginx --user=www --group=www --with-http_stub_status_module --with-http_ssl_module --add-module=../ngx_cache_purge-2.1
./configure --prefix=/usr/local/nginx --user=www --group=www --with-http_stub_status_module --with-http_ssl_module
make && make install
cd /root/lnmp/conf
cp init.d.nginx /etc/init.d/nginx
chmod 755 /etc/init.d/nginx
chkconfig --add nginx
chkconfig nginx on
mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf_bk
cp nginx.conf /usr/local/nginx/conf/nginx.conf
sed -i "s@/home/wwwroot@$home_dir@" nginx.conf
#worker_cpu_affinity
Nginx_conf=/usr/local/nginx/conf/nginx.conf
CPU_num=`cat /proc/cpuinfo | grep processor | wc -l`
if [ $CPU_num == 1 ];then
        sed -i 's@^worker_processes.*@worker_processes 1;@' $Nginx_conf 
elif [ $CPU_num == 2 ];then
        sed -i 's@^worker_processes.*@worker_processes 2;\nworker_cpu_affinity 10 01;@' $Nginx_conf 
elif [ $CPU_num == 3 ];then
        sed -i 's@^worker_processes.*@worker_processes 3;\nworker_cpu_affinity 100 010 001;@' $Nginx_conf
elif [ $CPU_num == 4 ];then
        sed -i 's@^worker_processes.*@worker_processes 4;\nworker_cpu_affinity 1000 0100 0010 0001;@' $Nginx_conf 
elif [ $CPU_num == 6 ];then
        sed -i 's@^worker_processes.*@worker_processes 6;\nworker_cpu_affinity 100000 010000 001000 000100 000010 000001;@' $Nginx_conf 
elif [ $CPU_num == 8 ];then
        sed -i 's@^worker_processes.*@worker_processes 8;\nworker_cpu_affinity 10000000 01000000 00100000 00010000 00001000 00000100 00000010 00000001;@' $Nginx_conf 
else
        echo Google worker_cpu_affinity
fi

#logrotate nginx log
echo '/usr/local/nginx/logs/*.log {
daily
rotate 5
missingok
dateext
compress
notifempty
sharedscripts
postrotate
    [ -e /var/run/nginx.pid ] && kill -USR1 `cat /var/run/nginx.pid`
endscript
}' > /etc/logrotate.d/nginx

service nginx restart
}

function Install_Pureftp()
{
cd /root/lnmp/source
tar xzf pure-ftpd-1.0.36.tar.gz
cd pure-ftpd-1.0.36
./configure --prefix=/usr/local/pureftpd CFLAGS=-O2 --with-mysql=$db_install_dir --with-quotas --with-cookie --with-virtualhosts --with-virtualchroot --with-diraliases --with-sysquotas --with-ratios --with-altlog --with-paranoidmsg --with-shadow --with-welcomemsg  --with-throttling --with-uploadscript --with-language=english 
make && make install
cp configuration-file/pure-config.pl /usr/local/pureftpd/sbin
chmod +x /usr/local/pureftpd/sbin/pure-config.pl
cp contrib/redhat.init /etc/init.d/pureftpd
sed -i 's@fullpath=.*@fullpath=/usr/local/pureftpd/sbin/$prog@' /etc/init.d/pureftpd
sed -i 's@pureftpwho=.*@pureftpwho=/usr/local/pureftpd/sbin/pure-ftpwho@' /etc/init.d/pureftpd
sed -i 's@/etc/pure-ftpd.conf@/usr/local/pureftpd/pure-ftpd.conf@' /etc/init.d/pureftpd
chmod +x /etc/init.d/pureftpd
chkconfig --add pureftpd
chkconfig pureftpd on

cd /root/lnmp/conf
/bin/cp pure-ftpd.conf /usr/local/pureftpd/
/bin/cp pureftpd-mysql.conf /usr/local/pureftpd/
mysqlftppwd=`cat /dev/urandom | head -1 | md5sum | head -c 8`
sed -i 's/tmppasswd/'$mysqlftppwd'/g' /usr/local/pureftpd/pureftpd-mysql.conf
sed -i 's/mysqlftppwd/'$mysqlftppwd'/g' script.mysql
sed -i 's/ftpmanagerpwd/'$ftpmanagerpwd'/g' script.mysql
$db_install_dir/bin/mysql -uroot -p$dbrootpwd< script.mysql
service pureftpd start

tar xzf /root/lnmp/source/ftp_v2.1.tar.gz -C $home_dir 
sed -i 's/tmppasswd/'$mysqlftppwd'/' $home_dir/ftp/config.php
sed -i "s/myipaddress.com/`echo $IP`/" $home_dir/ftp/config.php
sed -i 's@\$DEFUserID.*;@\$DEFUserID = "501";@' $home_dir/ftp/config.php
sed -i 's@\$DEFGroupID.*;@\$DEFGroupID = "501";@' $home_dir/ftp/config.php
sed -i 's@iso-8859-1@UTF-8@' $home_dir/ftp/language/english.php
rm -rf  $home_dir/ftp/install.php
}

function Install_phpMyAdmin()
{ 
cd $home_dir
tar xzf /root/lnmp/source/phpMyAdmin-4.0.5-all-languages.tar.gz
mv phpMyAdmin-4.0.5-all-languages phpMyAdmin
}

function TEST()
{
echo '<?php
phpinfo()
?>' > $home_dir/phpinfo.php
cp /root/lnmp/conf/index.html $home_dir
unzip -q /root/lnmp/conf/tz.zip -d $home_dir
chown -R www.www $home_dir
}

function Iptables()
{
cat > /etc/sysconfig/iptables << EOF
# Firewall configuration written by system-config-securitylevel
# Manual customization of this file is not recommended.
*filter
:INPUT DROP [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 21 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 20000:30000 -j ACCEPT
-A INPUT -p icmp -m limit --limit 100/sec --limit-burst 100 -j ACCEPT
-A INPUT -p icmp -m limit --limit 1/s --limit-burst 10 -j ACCEPT
COMMIT
EOF
service iptables restart
}

Download_src 2>&1 | tee -a /root/lnmp/lnmp_install.log 
chmod +x /root/lnmp/{init,vhost}.sh
sed -i "s@/home/wwwroot@$home_dir@g" /root/lnmp/vhost.sh
/root/lnmp/init.sh 2>&1 | tee -a /root/lnmp/lnmp_install.log 
if [ $choice_db == 'mysql' ];then
	db_install_dir=/usr/local/mysql
	db_data_dir=/data/mysql
	Install_MySQL 2>&1 | tee -a /root/lnmp/lnmp_install.log 
fi
if [ $choice_db == 'mariadb' ];then
	db_install_dir=/usr/local/mariadb
	db_data_dir=/data/mariadb
	Install_MariaDB 2>&1 | tee -a /root/lnmp/lnmp_install.log 
fi
Install_PHP 2>&1 | tee -a /root/lnmp/lnmp_install.log 
Install_Nginx 2>&1 | tee -a /root/lnmp/lnmp_install.log 

if [ $Memcache_yn == 'y' ];then
	Install_Memcache 2>&1 | tee -a /root/lnmp/lnmp_install.log 
fi

if [ $FTP_yn == 'y' ];then
	Install_Pureftp 2>&1 | tee -a /root/lnmp/lnmp_install.log 
	Iptables 2>&1 | tee -a /root/lnmp/lnmp_install.log 
fi

if [ $phpMyAdmin_yn == 'y' ];then
	Install_phpMyAdmin 2>&1 | tee -a /root/lnmp/lnmp_install.log
fi
TEST 2>&1 | tee -a /root/lnmp/lnmp_install.log 

echo "################Congratulations####################"
echo -e "\033[32mPlease restart the server and see if the services start up fine.\033[0m"
echo ''
echo "The path of some dirs:"
echo -e "Nginx dir:                       \033[32m/usr/local/nginx\033[0m"
echo -e "$choice_DB dir:                  \033[32m$db_install_dir\033[0m"
echo -e "PHP dir:                         \033[32m/usr/local/php\033[0m"
echo -e "$choice_DB User:                 \033[32mroot\033[0m"
echo -e "$choice_DB Password:             \033[32m${dbrootpwd}\033[0m"
echo -e "Manager url:                     \033[32mhttp://$IP/\033[0m"
echo -e "add ngx_pagespeed module:        \033[32m./install_ngx_pagespeed.sh\033[0m"
