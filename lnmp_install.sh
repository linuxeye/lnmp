#!/bin/bash
# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script, please use root to install lnmp" && exit 1

echo "#######################################################################"
echo "#                    LNMP for CentOS/RadHat 5/6                       #"
echo "# For more information please visit https://github.com/lj2007331/lnmp #"
echo "#######################################################################"
echo ''

# get IP
IP=`ifconfig | grep 'inet addr:' | cut -d: -f2 | grep -v ^10\. | grep -v ^192\.168 | grep -v ^172\. | grep -v ^127\. | awk '{print  $1}' | awk '{print;exit}'`

# start 
while :
do
        read -p "Please input the root password of MySQL:" mysqlrootpwd
        FTP_yn='y'
        read -p "Do you want to install Pure-FTPd? (y/n)" FTP_yn
        if [ "$FTP_yn" != 'y' ] && [ "$FTP_yn" != 'n' ];then
                echo -e "\033[31minput error! please input 'y' or 'n'\033[0m"
                exit 1 
        fi
        [ $FTP_yn == 'y' ] && read -p "Please input the manager password of Pureftpd:" ftpmanagerpwd
        phpMyAdmin_yn='y'
        read -p "Do you want to install phpMyAdmin? (y/n)" phpMyAdmin_yn
        if [ "$phpMyAdmin_yn" != 'y' ] && [ "$phpMyAdmin_yn" != 'n' ];then
                echo -e "\033[31minput error! please input 'y' or 'n'\033[0m"
                exit 1 
        fi
        if [ "$FTP_yn" == 'y' ];then
                if (( ${#mysqlrootpwd} >= 5 && ${#ftpmanagerpwd} >=5 ));then
                        break
                else
                        echo -e "\033[31mpassword least 5 characters! \033[0m"
                fi
        else
                if (( ${#mysqlrootpwd} >= 5 ));then
                        break
                else
                        echo -e "\033[31mpassword least 5 characters! \033[0m"
                fi
        fi
done

#Definition Directory
home_dir=/home/wwwroot
mkdir -p $home_dir
mkdir -p /root/lnmp/{source,conf}

function Download_src()
{
cd /root/lnmp
[ -s init.sh ] && echo 'init.sh found' || wget --no-check-certificate https://raw.github.com/lj2007331/lnmp/master/init.sh
[ -s vhost.sh ] && echo 'vhost.sh found' || wget --no-check-certificate https://raw.github.com/lj2007331/lnmp/master/vhost.sh
cd conf
[ -s tz.php ] && echo 'tz.php found' || wget --no-check-certificate https://raw.github.com/lj2007331/lnmp/master/conf/tz.php
[ -s index.html ] && echo 'index.html found' || wget --no-check-certificate https://raw.github.com/lj2007331/lnmp/master/conf/index.html
[ -s init.d.nginx ] && echo 'init.d.nginx found' || wget --no-check-certificate https://raw.github.com/lj2007331/lnmp/master/conf/init.d.nginx
[ -s nginx.conf ] && echo 'nginx.conf found' || wget --no-check-certificate https://raw.github.com/lj2007331/lnmp/master/conf/nginx.conf
[ -s pure-ftpd.conf ] && echo 'pure-ftpd.conf found' || wget --no-check-certificate https://raw.github.com/lj2007331/lnmp/master/conf/pure-ftpd.conf
[ -s pureftpd-mysql.conf ] && echo 'pureftpd-mysql.conf found' || wget --no-check-certificate https://raw.github.com/lj2007331/lnmp/master/conf/pureftpd-mysql.conf
[ -s script.mysql ] && echo 'script.mysql found' || wget --no-check-certificate https://raw.github.com/lj2007331/lnmp/master/conf/script.mysql
cd /root/lnmp/source
[ -s cmake-2.8.11.2.tar.gz ] && echo 'cmake-2.8.11.2.tar.gz found' || wget http://www.cmake.org/files/v2.8/cmake-2.8.11.2.tar.gz
[ -s mysql-5.6.12.tar.gz ] && echo 'mysql-5.6.12.tar.gz found' || wget http://fossies.org/linux/misc/mysql-5.6.12.tar.gz
[ -s libiconv-1.14.tar.gz ] && echo 'libiconv-1.14.tar.gz found' || wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
[ -s libmcrypt-2.5.8.tar.gz ] && echo 'libmcrypt-2.5.8.tar.gz found' || wget http://iweb.dl.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz
[ -s mhash-0.9.9.9.tar.gz ] && echo 'mhash-0.9.9.9.tar.gz found' || wget http://iweb.dl.sourceforge.net/project/mhash/mhash/0.9.9.9/mhash-0.9.9.9.tar.gz
[ -s mcrypt-2.6.8.tar.gz ] && echo 'mcrypt-2.6.8.tar.gz found' || wget http://vps.googlecode.com/files/mcrypt-2.6.8.tar.gz
[ -s php-5.5.1.tar.gz ] && echo 'php-5.5.1.tar.gz found' || wget http://kr1.php.net/distributions/php-5.5.1.tar.gz
[ -s memcache-2.2.7.tgz ] && echo 'memcache-2.2.7.tgz found' || wget http://pecl.php.net/get/memcache-2.2.7.tgz
[ -s PDO_MYSQL-1.0.2.tgz ] && echo 'PDO_MYSQL-1.0.2.tgz found' || wget http://pecl.php.net/get/PDO_MYSQL-1.0.2.tgz
[ -s ImageMagick-6.8.6-6.tar.gz ] && echo 'ImageMagick-6.8.6-6.tar.gz found' || wget ftp://sunsite.icm.edu.pl/packages/ImageMagick/ImageMagick-6.8.6-6.tar.gz 
[ -s imagick-3.1.0RC2.tgz ] && echo 'imagick-3.1.0RC2.tgz found' || wget http://pecl.php.net/get/imagick-3.1.0RC2.tgz
[ -s pecl_http-1.7.6.tgz ] && echo 'pecl_http-1.7.6.tgz found' || wget http://pecl.php.net/get/pecl_http-1.7.6.tgz
[ -s pcre-8.33.tar.gz ] && echo 'pcre-8.33.tar.gz found' || wget http://ftp.exim.llorien.org/pcre/pcre-8.33.tar.gz 
[ -s nginx-1.4.2.tar.gz ] && echo 'nginx-1.4.2.tar.gz found' || wget http://nginx.org/download/nginx-1.4.2.tar.gz
[ -s pure-ftpd-1.0.36.tar.gz ] && echo 'pure-ftpd-1.0.36.tar.gz found' || wget ftp://ftp.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-1.0.36.tar.gz
[ -s ftp_v2.1.tar.gz ] && echo 'ftp_v2.1.tar.gz found' || wget http://machiel.generaal.net/files/pureftpd/ftp_v2.1.tar.gz 
[ -s phpMyAdmin-4.0.4.1-all-languages.tar.gz ] && echo 'phpMyAdmin-4.0.4.1-all-languages.tar.gz found' || wget http://iweb.dl.sourceforge.net/project/phpmyadmin/phpMyAdmin/4.0.4.1/phpMyAdmin-4.0.4.1-all-languages.tar.gz 
# check source packages
for src in `cat ./lnmp_install.sh | grep found.*wget | awk '{print $3}' | grep gz`
do
        if [ ! -f "/root/lnmp/source/$src" ];then
                echo -e "\033[31m$src no found! \033[0m"
                exit 1
        fi
done
}

function Install_MySQL()
{
cd /root/lnmp/source
useradd -M -s /sbin/nologin mysql
mkdir -p /data/mysql;chown mysql.mysql -R /data/mysql
tar xzf cmake-2.8.11.2.tar.gz 
cd cmake-2.8.11.2
./configure
make &&  make install
cd ..
tar zxf mysql-5.6.12.tar.gz
cd mysql-5.6.12
cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql/ \
-DMYSQL_UNIX_ADDR=/data/mysql/mysqld.sock \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_MEMORY_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_MEMORY_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DMYSQL_DATADIR=/data/mysql  \
-DMYSQL_USER=mysql \
-DMYSQL_TCP_PORT=3306 \
-DEXTRA_CHARSETS=all \
-DWITH_DEBUG=0
make && make install

if [ -d "/usr/local/mysql" ];then
        echo -e "\033[32mMySQL install successfully! \033[0m"
else
        echo -e "\033[31mMySQL install failed,Please Contact Author! \033[0m"
        exit 1
fi

/bin/cp support-files/my-default.cnf /etc/my.cnf
cp support-files/mysql.server /etc/init.d/mysqld 
chmod 755 /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig mysqld on
cd ..

# my.cf
cat > /etc/my.cnf << EOF
[mysqld]
basedir = /usr/local/mysql
datadir = /data/mysql
socket = /data/mysql/mysql.sock
character-set-server=utf8
collation-server=utf8_general_ci
user=mysql
port = 3306
default_storage_engine = InnoDB
server_id = 1
log_bin=mysql-bin
binlog_format=mixed
expire_logs_days = 7

# name-resolve
#skip-name-resolve
#skip-host-cache

#lower_case_table_names = 1
ft_min_word_len=1
query_cache_size=64M
query_cache_type=1

skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K

# LOG
log_error = /data/mysql/mysql-error.log
long_query_time = 1
slow_query_log
slow_query_log_file = /data/mysql/mysql-slow.log

# Oher
explicit_defaults_for_timestamp=true
#max_connections = 1000
open_files_limit = 65535
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES

[client]
port = 3306
socket = /data/mysql/mysql.sock
EOF

/usr/local/mysql/scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql/ --datadir=/data/mysql

chown mysql.mysql -R /data/mysql
/sbin/service mysqld start
export PATH=$PATH:/usr/local/mysql/bin
echo 'export PATH=$PATH:/usr/local/mysql/bin' >> /etc/profile
source /etc/profile

/usr/local/mysql/bin/mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"$mysqlrootpwd\" with grant option;"
/usr/local/mysql/bin/mysql -e "grant all privileges on *.* to root@'localhost' identified by \"$mysqlrootpwd\" with grant option;"
/usr/local/mysql/bin/mysql -uroot -p$mysqlrootpwd -e "delete from mysql.user where Password='';"
/usr/local/mysql/bin/mysql -uroot -p$mysqlrootpwd -e "drop database test;"
[ "$(hostname -i)" != "127.0.0.1" ] && sed -i "s@^127.0.0.1\(.*\)@127.0.0.1   `hostname` \1@" /etc/hosts 
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
/usr/local/mysql/lib
EOF
/sbin/ldconfig
ln -s /usr/local/bin/libmcrypt-config /usr/bin/libmcrypt-config
ln -s /usr/local/mysql/include/* /usr/local/include/
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
--with-fpm-user=www --with-fpm-group=www --enable-opcache --enable-fpm \
--with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config \
--with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib \
--with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop \
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
        exit 1
fi
#wget http://pear.php.net/go-pear.phar
#/usr/local/php/bin/php go-pear.phar

cp php.ini-production /usr/local/php/etc/php.ini

#php-fpm Init Script
cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
chkconfig --add php-fpm
chkconfig php-fpm on
cd ../

tar xzf memcache-2.2.7.tgz
cd memcache-2.2.7
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../

tar xzf PDO_MYSQL-1.0.2.tgz
cd PDO_MYSQL-1.0.2
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --with-pdo-mysql=/usr/local/mysql
make && make install
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
sed -i '730a extension_dir = "/usr/local/php/lib/php/extensions/no-debug-non-zts-20121212/"' /usr/local/php/etc/php.ini 
sed -i '731a extension = "memcache.so"' /usr/local/php/etc/php.ini 
sed -i '732a extension = "pdo_mysql.so"' /usr/local/php/etc/php.ini 
sed -i '733a extension = "imagick.so"' /usr/local/php/etc/php.ini 
sed -i '734a extension = "http.so"' /usr/local/php/etc/php.ini 
sed -i '242a output_buffering = On' /usr/local/php/etc/php.ini 
sed -i 's@^;cgi.fix_pathinfo.*@cgi.fix_pathinfo=0@' /usr/local/php/etc/php.ini 
sed -i 's@^short_open_tag = Off@short_open_tag = On@' /usr/local/php/etc/php.ini
sed -i 's@^expose_php = On@expose_php = Off@' /usr/local/php/etc/php.ini
sed -i 's@^request_order.*@request_order = "CGP"@' /usr/local/php/etc/php.ini
sed -i 's@^;date.timezone.*@date.timezone = Asia/Shanghai@' /usr/local/php/etc/php.ini
sed -i 's@^post_max_size.*@post_max_size = 50M@' /usr/local/php/etc/php.ini
sed -i 's@^upload_max_filesize.*@upload_max_filesize = 50M@' /usr/local/php/etc/php.ini
sed -i 's@^max_execution_time.*@max_execution_time = 300@' /usr/local/php/etc/php.ini
sed -i 's@^disable_functions.*@disable_functions = passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket@' /usr/local/php/etc/php.ini
sed -i 's@#sendmail_path.*@#sendmail_path = /usr/sbin/sendmail -t@' /usr/local/php/etc/php.ini

sed -i '1863a zend_extension=opcache.so' /usr/local/php/etc/php.ini 
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
sed -i "s@/home/wwwroot@$home_dir@" nginx.conf
cp init.d.nginx /etc/init.d/nginx
chmod 755 /etc/init.d/nginx
chkconfig --add nginx
chkconfig nginx on
mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf_bk
cp nginx.conf /usr/local/nginx/conf/nginx.conf

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
    [ -f /usr/local/nginx/logs/nginx.pid ] && kill -USR1 `cat /usr/local/nginx/logs/nginx.pid`
endscript
}' > /etc/logrotate.d/nginx

service nginx restart
}

function Install_Pureftp()
{
cd /root/lnmp/source
tar xzf pure-ftpd-1.0.36.tar.gz
cd pure-ftpd-1.0.36
./configure --prefix=/usr/local/pureftpd CFLAGS=-O2 --with-mysql=/usr/local/mysql --with-quotas --with-cookie --with-virtualhosts --with-virtualchroot --with-diraliases --with-sysquotas --with-ratios --with-altlog --with-paranoidmsg --with-shadow --with-welcomemsg  --with-throttling --with-uploadscript --with-language=english 
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
/usr/local/mysql/bin/mysql -uroot -p$mysqlrootpwd< script.mysql
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
tar xzf /root/lnmp/source/phpMyAdmin-4.0.4.1-all-languages.tar.gz
mv phpMyAdmin-4.0.4.1-all-languages phpMyAdmin
sed -i 's@localhost@127.0.0.1@' phpMyAdmin/libraries/config.default.php
}

function TEST()
{
echo '<?php
phpinfo()
?>' > $home_dir/phpinfo.php
cp /root/lnmp/conf/index.html $home_dir
cp /root/lnmp/conf/tz.php $home_dir
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
Install_MySQL 2>&1 | tee -a /root/lnmp/lnmp_install.log 
Install_PHP 2>&1 | tee -a /root/lnmp/lnmp_install.log 
Install_Nginx 2>&1 | tee -a /root/lnmp/lnmp_install.log 

if [ $FTP_yn == 'y' ];then
	Install_Pureftp 2>&1 | tee -a /root/lnmp/lnmp_install.log 
	Iptables 2>&1 | tee -a /root/lnmp/lnmp_install.log 
fi

if [ $phpMyAdmin_yn == 'y' ];then
	Install_phpMyAdmin 2>&1 | tee -a /root/lnmp/lnmp_install.log
fi
TEST 2>&1 | tee -a /root/lnmp/lnmp_install.log 

echo "################Congratulations####################"
echo "The path of some dirs:"
echo -e "Nginx dir:                     \033[32m/usr/local/nginx\033[0m"
echo -e "MySQL dir:                     \033[32m/usr/local/mysql\033[0m"
echo -e "PHP dir:                       \033[32m/usr/local/php\033[0m"
echo -e "MySQL User:                    \033[32mroot\033[0m"
echo -e "MySQL Password:                \033[32m${mysqlrootpwd}\033[0m"
echo -e "Manager url:                   \033[32mhttp://$IP/\033[0m"
echo "###################################################"
