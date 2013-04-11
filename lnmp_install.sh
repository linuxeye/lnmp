#!/bin/bash
# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script, please use root to install lnmp" && exit 1

# Set password
while :
do
    read -p "Please input the root password of MySQL:" mysqlrootpwd
    read -p "Please input the manager password of Pureftpd:" ftpmanagerpwd
    if (( ${#mysqlrootpwd} >= 5 && ${#ftpmanagerpwd} >=5 ));then
        break
    else
       echo "least 5 characters"
    fi
done

yum -y install gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssl-devel nss_ldap openldap openldap-devel openldap-clients openldap-servers libxslt-devel libevent-devel ntp libtool-ltdl bison libtool vim-enhanced zip unzip

# install MySQL 
mkdir -p /root/lnmp/source
cd /root/lnmp/source
wget -c http://www.cmake.org/files/v2.8/cmake-2.8.10.2.tar.gz
wget -c http://iweb.dl.sourceforge.net/project/mysql.mirror/MySQL%205.5.30/mysql-5.5.30.tar.gz
useradd -M -s /sbin/nologin mysql
mkdir -p /data/mysql;chown mysql.mysql -R /data/mysql
tar xzf cmake-2.8.10.2.tar.gz 
cd cmake-2.8.10.2
./configure
make &&  make install
cd ..
tar zxf mysql-5.5.30.tar.gz
cd mysql-5.5.30
cmake . -DCMAKE_INSTALL_PREFIX=/usr/local/mysql/ \
-DMYSQL_DATADIR=/data/mysql  \
-DMYSQL_UNIX_ADDR=/data/mysql/mysqld.sock \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DMYSQL_TCP_PORT=3306 \
-DCMAKE_THREAD_PREFER_PTHREAD=1 \
-DEXTRA_CHARSETS=all \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DMYSQL_UNIX_ADDR=/data/mysql/mysql.sock \
-DWITH_DEBUG=0
make && make install

/bin/cp support-files/my-medium.cnf /etc/my.cnf
cp support-files/mysql.server /etc/init.d/mysqld 
chmod 755 /etc/init.d/mysqld
chkconfig --add mysqld
chkconfig mysqld on
cd ..

# Modify my.cf
sed -i '38a ##############' /etc/my.cnf
sed -i '39a skip-name-resolve' /etc/my.cnf
sed -i '40a basedir=/usr/local/mysql' /etc/my.cnf
sed -i '41a datadir=/data/mysql' /etc/my.cnf
sed -i '42a user=mysql' /etc/my.cnf
sed -i '43a #lower_case_table_names = 1' /etc/my.cnf
sed -i '44a max_connections=1000' /etc/my.cnf
sed -i '45a ft_min_word_len=1' /etc/my.cnf
sed -i '46a expire_logs_days = 7' /etc/my.cnf
sed -i '47a query_cache_size=64M' /etc/my.cnf
sed -i '48a query_cache_type=1' /etc/my.cnf
sed -i '49a ##############' /etc/my.cnf

/usr/local/mysql/scripts/mysql_install_db --user=mysql --basedir=/usr/local/mysql/ --datadir=/data/mysql

chown mysql.mysql -R /data/mysql
/sbin/service mysqld start
export PATH=$PATH:/usr/local/mysql/bin
echo 'export PATH=$PATH:/usr/local/mysql/bin' >> /etc/profile
source /etc/profile

/usr/local/mysql/bin/mysql -e "grant all privileges on *.* to root@'localhost' identified by \"$mysqlrootpwd\" with grant option;"
/usr/local/mysql/bin/mysql -uroot -p$mysqlrootpwd -e "delete from mysql.user where Password='';"
/sbin/service mysqld restart

# install PHP 
wget -c http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
tar xzf libiconv-1.14.tar.gz
cd libiconv-1.14
./configure --prefix=/usr/local
make && make install
cd ../

wget -c http://iweb.dl.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz
tar xzf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8
./configure
make && make install
/sbin/ldconfig
cd libltdl/
./configure --enable-ltdl-install
make && make install
cd ../../

wget -c http://iweb.dl.sourceforge.net/project/mhash/mhash/0.9.9.9/mhash-0.9.9.9.tar.gz
tar xzf mhash-0.9.9.9.tar.gz
cd mhash-0.9.9.9
./configure
make && make install
cd ../

if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
	ln -s /usr/local/lib/libmcrypt.la /usr/lib64/libmcrypt.la
	ln -s /usr/local/lib/libmcrypt.so /usr/lib64/libmcrypt.so
	ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib64/libmcrypt.so.4
	ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib64/libmcrypt.so.4.4.8
	ln -s /usr/local/lib/libmhash.a /usr/lib64/libmhash.a
	ln -s /usr/local/lib/libmhash.la /usr/lib64/libmhash.la
	ln -s /usr/local/lib/libmhash.so /usr/lib64/libmhash.so
	ln -s /usr/local/lib/libmhash.so.2 /usr/lib64/libmhash.so.2
	ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib64/libmhash.so.2.0.1
	ln -s /usr/local/bin/libmcrypt-config /usr/bin/libmcrypt-config
	ln -s /usr/local/mysql/lib/libmysqlclient.so.18 /lib64/libmysqlclient.so.18
        ln -s /lib64/libpcre.so.0.0.1 /lib64/libpcre.so.1
        cp -frp /usr/lib64/libldap* /usr/lib
else
	ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
	ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
	ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
	ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
	ln -s /usr/local/lib/libmhash.a /usr/lib/libmhash.a
	ln -s /usr/local/lib/libmhash.la /usr/lib/libmhash.la
	ln -s /usr/local/lib/libmhash.so /usr/lib/libmhash.so
	ln -s /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
	ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1
	ln -s /usr/local/bin/libmcrypt-config /usr/bin/libmcrypt-config
	ln -s /usr/local/mysql/lib/libmysqlclient.so.18 /lib/libmysqlclient.so.18
        ln -s /usr/local/include/ImageMagick-6 /usr/local/include/ImageMagick
        ln -s /lib/libpcre.so.0.0.1 /lib/libpcre.so.1
        export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
fi

wget -c http://vps.googlecode.com/files/mcrypt-2.6.8.tar.gz
tar xzf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8
/sbin/ldconfig
./configure
make && make install
cd ../

wget -c http://kr1.php.net/distributions/php-5.3.24.tar.gz
tar xzf php-5.3.24.tar.gz
useradd -M -s /sbin/nologin www
cd php-5.3.24
./configure  --prefix=/usr/local/php --with-mysql=/usr/local/mysql --with-mysql=/usr/local/mysql --with-mysqli=/usr/local/mysql/bin/mysql_config --with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-fpm --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-ldap --with-ldap-sasl --with-xmlrpc --enable-ftp --enable-zip --enable-soap --disable-debug
make ZEND_EXTRA_LIBS='-liconv'
make install
cp php.ini-production /usr/local/php/lib/php.ini
cd ../

wget -c http://pecl.php.net/get/memcache-2.2.5.tgz
tar xzf memcache-2.2.5.tgz
cd memcache-2.2.5
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../

wget -c  http://superb-dca2.dl.sourceforge.net/project/eaccelerator/eaccelerator/eAccelerator%200.9.6.1/eaccelerator-0.9.6.1.tar.bz2
tar xjf eaccelerator-0.9.6.1.tar.bz2
cd eaccelerator-0.9.6.1
/usr/local/php/bin/phpize
./configure --enable-eaccelerator=shared --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../

wget -c http://pecl.php.net/get/PDO_MYSQL-1.0.2.tgz
tar xzf PDO_MYSQL-1.0.2.tgz
cd PDO_MYSQL-1.0.2
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config --with-pdo-mysql=/usr/local/mysql
make && make install
cd ../

wget -c http://www.imagemagick.org/download/legacy/ImageMagick-6.8.3-10.tar.gz
tar xzf ImageMagick-6.8.3-10.tar.gz
cd ImageMagick-6.8.3-10
./configure
make && make install
cd ../

wget -c http://pecl.php.net/get/imagick-3.0.1.tgz
tar xzf imagick-3.0.1.tgz
cd imagick-3.0.1
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../

# Support HTTP request curls
wget -c http://pecl.php.net/get/pecl_http-1.7.5.tgz
tar xzf pecl_http-1.7.5.tgz
cd pecl_http-1.7.5 
/usr/local/php/bin/phpize
./configure --with-php-config=/usr/local/php/bin/php-config
make && make install
cd ../

# Modify php.ini
mkdir /tmp/eaccelerator
/bin/chown -R www.www /tmp/eaccelerator/
sed -i '808a extension_dir = "/usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/"' /usr/local/php/lib/php.ini 
sed -i '809a extension = "memcache.so"' /usr/local/php/lib/php.ini 
sed -i '810a extension = "pdo_mysql.so"' /usr/local/php/lib/php.ini 
sed -i '811a extension = "imagick.so"' /usr/local/php/lib/php.ini 
sed -i '812a extension = "http.so"' /usr/local/php/lib/php.ini 
sed -i '135a output_buffering = On' /usr/local/php/lib/php.ini 
sed -i '848a cgi.fix_pathinfo=0' /usr/local/php/lib/php.ini 
sed -i 's@short_open_tag = Off@short_open_tag = On@g' /usr/local/php/lib/php.ini
sed -i 's@expose_php = On@expose_php = Off@g' /usr/local/php/lib/php.ini
sed -i 's@;date.timezone =@date.timezone = Asia/Shanghai@g' /usr/local/php/lib/php.ini
sed -i 's@#sendmail_path.*@#sendmail_path = /usr/sbin/sendmail -t@g' /usr/local/php/lib/php.ini
echo '[eaccelerator]
zend_extension="/usr/local/php/lib/php/extensions/no-debug-non-zts-20090626/eaccelerator.so"
eaccelerator.shm_size="64"
eaccelerator.cache_dir="/tmp/eaccelerator"
eaccelerator.enable="1"
eaccelerator.optimizer="1"
eaccelerator.check_mtime="1"
eaccelerator.debug="0"
eaccelerator.filter=""
eaccelerator.shm_max="0"
eaccelerator.shm_ttl="0"
eaccelerator.shm_prune_period="0"
eaccelerator.shm_only="0"
eaccelerator.compress="0"
eaccelerator.compress_level="9"
eaccelerator.keys = "disk_only"
eaccelerator.sessions = "disk_only"
eaccelerator.content = "disk_only"' >> /usr/local/php/lib/php.ini

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

slowlog = log/$pool.log.slow
rlimit_files = 51200
rlimit_core = 0

catch_workers_output = yes
env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp
EOF

# /etc/init.d/php-fpm
mkdir ../conf
cd ../conf
wget -c https://raw.github.com/lj2007331/lnmp/master/conf/php-fpm.sh
cp php-fpm.sh /etc/init.d/php-fpm
chmod 755 /etc/init.d/php-fpm
chkconfig php-fpm on
service php-fpm start

# install Nginx
cd ../source 
wget -c  http://iweb.dl.sourceforge.net/project/pcre/pcre/8.32/pcre-8.32.tar.gz
tar xzf pcre-8.32.tar.gz
cd pcre-8.32
./configure
make && make install
cd ../

#wget -c http://labs.frickle.com/files/ngx_cache_purge-2.1.tar.gz
#tar xzf ngx_cache_purge-2.1.tar.gz 
wget -c http://nginx.org/download/nginx-1.2.8.tar.gz
tar xzf nginx-1.2.8.tar.gz
cd nginx-1.2.8

# Modify Nginx version
sed -i 's@#define NGINX_VERSION.*$@#define NGINX_VERSION      "2.2.14"@g' src/core/nginx.h 
sed -i 's@#define NGINX_VER.*NGINX_VERSION$@#define NGINX_VER          "Apache/" NGINX_VERSION@g' src/core/nginx.h 
#./configure --prefix=/usr/local/nginx --user=www --group=www --with-http_stub_status_module --with-http_ssl_module --add-module=../ngx_cache_purge-2.1
./configure --prefix=/usr/local/nginx --user=www --group=www --with-http_stub_status_module --with-http_ssl_module
make && make install
cd ../../conf
wget -c https://raw.github.com/lj2007331/lnmp/master/conf/nginx.sh
cp nginx.sh /etc/init.d/nginx
chmod 755 /etc/init.d/nginx
chkconfig --add nginx
chkconfig nginx on
mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf_bk
wget -c https://raw.github.com/lj2007331/lnmp/master/conf/nginx.conf
cp nginx.conf /usr/local/nginx/conf/nginx.conf
echo "Modify nginx.conf"
service nginx restart

# install Pureftpd and pureftpd_php_manager 
cd ../source
wget -c ftp://ftp.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-1.0.36.tar.gz
tar xzf pure-ftpd-1.0.36.tar.gz
cd pure-ftpd-1.0.36
./configure --prefix=/usr/local/pureftpd CFLAGS=-O2 --with-mysql=/usr/local/mysql --with-quotas --with-cookie --with-virtualhosts --with-virtualchroot --with-diraliases --with-sysquotas --with-ratios --with-altlog --with-paranoidmsg --with-shadow --with-welcomemsg  --with-throttling --with-uploadscript --with-language=simplified-chinese
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

cd ../../conf
wget -c https://raw.github.com/lj2007331/lnmp/master/conf/pure-ftpd.conf
wget -c https://raw.github.com/lj2007331/lnmp/master/conf/pureftpd-mysql.conf
wget -c https://raw.github.com/lj2007331/lnmp/master/conf/script.mysql 
/bin/cp pure-ftpd.conf /usr/local/pureftpd/
/bin/cp pureftpd-mysql.conf /usr/local/pureftpd/
mysqlftppwd=`cat /dev/urandom | head -1 | md5sum | head -c 8`
sed -i 's/tmppasswd/'$mysqlftppwd'/g' /usr/local/pureftpd/pureftpd-mysql.conf
sed -i 's/mysqlftppwd/'$mysqlftppwd'/g' script.mysql
sed -i 's/ftpmanagerpwd/'$ftpmanagerpwd'/g' script.mysql
/usr/local/mysql/bin/mysql -uroot -p$mysqlrootpwd< script.mysql
service pureftpd start

mkdir -p /data/admin
cd ../source
wget -c http://acelnmp.googlecode.com/files/ftp_v2.1.tar.gz
tar xzf ftp_v2.1.tar.gz
mv ftp /data/admin;chown -R www.www /data/admin
sed -i 's/tmppasswd/'$mysqlftppwd'/g' /data/admin/ftp/config.php
IP=`ifconfig | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
sed -i 's/myipaddress.com/'$IP'/g' /data/admin/ftp/config.php
sed -i 's/127.0.0.1/localhost/g' /data/admin/ftp/config.php
sed -i 's@iso-8859-1@UTF-8@' /data/admin/ftp/language/english.php
rm -rf  /data/admin/ftp/install.php
echo '<?php
phpinfo()
?>' > /data/admin/index.php
cd ../
echo "################Congratulations####################"
echo "The path of some dirs:"
echo "Nginx dir:                     /usr/local/nginx"
echo "MySQL dir:                     /usr/local/mysql"
echo "PHP dir:                       /usr/local/php"
echo "Pureftpd dir:                  /usr/local/pureftpd"
echo "Pureftp_php_manager  dir :     /data/admin"
echo "MySQL Password:                $mysqlrootpwd"
echo "Pureftp_manager  url :         http://$IP/ftp"
echo "Pureftp_manager Password:      $ftpmanagerpwd"
echo "###################################################"
