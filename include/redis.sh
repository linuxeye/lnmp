#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       http://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_redis-server() {
cd $oneinstack_dir/src
src_url=http://download.redis.io/releases/redis-$redis_version.tar.gz && Download_src

tar xzf redis-$redis_version.tar.gz
cd redis-$redis_version
if [ "$OS_BIT" == '32' ];then
    sed -i '1i\CFLAGS= -march=i686' src/Makefile
    sed -i 's@^OPT=.*@OPT=-O2 -march=i686@' src/.make-settings
fi

make

if [ -f "src/redis-server" ];then
    mkdir -p $redis_install_dir/{bin,etc,var}
    /bin/cp src/{redis-benchmark,redis-check-aof,redis-check-dump,redis-cli,redis-sentinel,redis-server} $redis_install_dir/bin/
    /bin/cp redis.conf $redis_install_dir/etc/
    ln -s $redis_install_dir/bin/* /usr/local/bin/
    sed -i 's@pidfile.*@pidfile /var/run/redis.pid@' $redis_install_dir/etc/redis.conf
    sed -i "s@logfile.*@logfile $redis_install_dir/var/redis.log@" $redis_install_dir/etc/redis.conf
    sed -i "s@^dir.*@dir $redis_install_dir/var@" $redis_install_dir/etc/redis.conf
    sed -i 's@daemonize no@daemonize yes@' $redis_install_dir/etc/redis.conf
    sed -i "s@^# bind 127.0.0.1@bind 127.0.0.1@" $redis_install_dir/etc/redis.conf
    redis_maxmemory=`expr $Mem / 8`000000
    [ -z "`grep ^maxmemory $redis_install_dir/etc/redis.conf`" ] && sed -i "s@maxmemory <bytes>@maxmemory <bytes>\nmaxmemory `expr $Mem / 8`000000@" $redis_install_dir/etc/redis.conf
    echo "${CSUCCESS}Redis-server install successfully! ${CEND}"
    cd ..
    rm -rf redis-$redis_version
    [ "$OS" == 'CentOS' ] && { /bin/cp ../init.d/Redis-server-init-CentOS /etc/init.d/redis-server; chkconfig --add redis-server; chkconfig redis-server on; } 
    [[ $OS =~ ^Ubuntu$|^Debian$ ]] && { useradd -M -s /sbin/nologin redis; chown -R redis:redis $redis_install_dir/var/; /bin/cp ../init.d/Redis-server-init-Ubuntu /etc/init.d/redis-server; update-rc.d redis-server defaults; } 
    sed -i "s@/usr/local/redis@$redis_install_dir@g" /etc/init.d/redis-server
    #[ -z "`grep 'vm.overcommit_memory' /etc/sysctl.conf`" ] && echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
    #sysctl -p
    service redis-server start
else
    rm -rf $redis_install_dir
    echo "${CFAILURE}Redis-server install failed, Please contact the author! ${CEND}"
    kill -9 $$
fi
cd ..
}

Install_php-redis() {
cd $oneinstack_dir/src
if [ -e "$php_install_dir/bin/phpize" ];then
    if [ "`$php_install_dir/bin/php -r 'echo PHP_VERSION;' | awk -F. '{print $1}'`" == '7' ];then
        #git clone -b php7 https://github.com/phpredis/phpredis.git
        #cd phpredis
        src_url=http://mirrors.linuxeye.com/oneinstack/src/phpredis-php7.tgz && Download_src
        tar xzf phpredis-php7.tgz
        cd phpredis-php7
    else
        src_url=http://pecl.php.net/get/redis-$redis_pecl_version.tgz && Download_src
        tar xzf redis-$redis_pecl_version.tgz
        cd redis-$redis_pecl_version
    fi
    make clean
    $php_install_dir/bin/phpize
    ./configure --with-php-config=$php_install_dir/bin/php-config
    make && make install
    if [ -f "`$php_install_dir/bin/php-config --extension-dir`/redis.so" ];then
        [ -z "`grep '^extension_dir' $php_install_dir/etc/php.ini`" ] && sed -i "s@extension_dir = \"ext\"@extension_dir = \"ext\"\nextension_dir = \"`$php_install_dir/bin/php-config --extension-dir`\"@" $php_install_dir/etc/php.ini
        [ -z "`grep 'redis.so' $php_install_dir/etc/php.ini`" ] && sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "redis.so"@' $php_install_dir/etc/php.ini
        echo "${CSUCCESS}PHP Redis module install successfully! ${CEND}"
        cd ..
        rm -rf redis-$redis_pecl_version
        [ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
    else
        echo "${CFAILURE}PHP Redis module install failed, Please contact the author! ${CEND}"
    fi
fi
cd ..
}
