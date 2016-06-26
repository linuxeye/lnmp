#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_memcached() {
cd $oneinstack_dir/src
src_url=http://www.memcached.org/files/memcached-$memcached_version.tar.gz && Download_src

# memcached server
id -u memcached >/dev/null 2>&1
[ $? -ne 0 ] && useradd -M -s /sbin/nologin memcached

tar xzf memcached-$memcached_version.tar.gz
cd memcached-$memcached_version
[ ! -d "$memcached_install_dir" ] && mkdir -p $memcached_install_dir
./configure --prefix=$memcached_install_dir
make -j ${THREAD} && make install
if [ -d "$memcached_install_dir/include/memcached" ];then
    echo "${CSUCCESS}memcached installed successfully! ${CEND}"
    cd ..
    rm -rf memcached-$memcached_version
    ln -s $memcached_install_dir/bin/memcached /usr/bin/memcached
    [ "$OS" == 'CentOS' ] && { /bin/cp ../init.d/Memcached-init-CentOS /etc/init.d/memcached; chkconfig --add memcached; chkconfig memcached on; }
    [[ $OS =~ ^Ubuntu$|^Debian$ ]] && { /bin/cp ../init.d/Memcached-init-Ubuntu /etc/init.d/memcached; update-rc.d memcached defaults; }
    sed -i "s@/usr/local/memcached@$memcached_install_dir@g" /etc/init.d/memcached
    [ -n "`grep 'CACHESIZE=' /etc/init.d/memcached`" ] && sed -i "s@^CACHESIZE=.*@CACHESIZE=`expr $Mem / 8`@" /etc/init.d/memcached
    [ -n "`grep 'start_instance default 256;' /etc/init.d/memcached`" ] && sed -i "s@start_instance default 256;@start_instance default `expr $Mem / 8`;@" /etc/init.d/memcached
    service memcached start
else
    rm -rf $memcached_install_dir
    echo "${CFAILURE}memcached install failed, Please contact the author! ${CEND}"
    kill -9 $$
fi
cd ..
}

Install_php-memcache() {
cd $oneinstack_dir/src
if [ -e "$php_install_dir/bin/phpize" ];then
    # php memcache extension
    if [ "`$php_install_dir/bin/php -r 'echo PHP_VERSION;' | awk -F. '{print $1}'`" == '7' ];then
        #git clone https://github.com/websupport-sk/pecl-memcache.git
        #cd pecl-memcache
        src_url=http://mirrors.linuxeye.com/oneinstack/src/pecl-memcache-php7.tgz && Download_src
        tar xzf pecl-memcache-php7.tgz
        cd pecl-memcache-php7
    else
        src_url=http://pecl.php.net/get/memcache-$memcache_pecl_version.tgz && Download_src
        tar xzf memcache-$memcache_pecl_version.tgz
        cd memcache-$memcache_pecl_version
    fi
    make clean
    $php_install_dir/bin/phpize
    ./configure --with-php-config=$php_install_dir/bin/php-config
    make -j ${THREAD} && make install
    if [ -f "`$php_install_dir/bin/php-config --extension-dir`/memcache.so" ];then
        cat > $php_install_dir/etc/php.d/ext-memcache.ini << EOF
extension=memcache.so
EOF
        [ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
        echo "${CSUCCESS}PHP memcache module installed successfully! ${CEND}"
        cd ..
        rm -rf memcache-$memcache_pecl_version
    else
        echo "${CFAILURE}PHP memcache module install failed, Please contact the author! ${CEND}"
    fi
fi
cd ..
}

Install_php-memcached() {
cd $oneinstack_dir/src
if [ -e "$php_install_dir/bin/phpize" ];then
    src_url=https://launchpad.net/libmemcached/1.0/$libmemcached_version/+download/libmemcached-$libmemcached_version.tar.gz && Download_src
    # php memcached extension
    tar xzf libmemcached-$libmemcached_version.tar.gz
    cd libmemcached-$libmemcached_version
    [ "$OS" == 'CentOS' ] && yum -y install cyrus-sasl-devel
    [[ $OS =~ ^Ubuntu$|^Debian$ ]] && sed -i "s@lthread -pthread -pthreads@lthread -lpthread -pthreads@" ./configure
    ./configure --with-memcached=$memcached_install_dir
    make -j ${THREAD} && make install
    cd ..
    rm -rf libmemcached-$libmemcached_version

    if [ "`$php_install_dir/bin/php -r 'echo PHP_VERSION;' | awk -F. '{print $1}'`" == '7' ];then
        #git clone -b php7 https://github.com/php-memcached-dev/php-memcached.git
        #cd php-memcached
        src_url=http://mirrors.linuxeye.com/oneinstack/src/php-memcached-php7.tgz && Download_src
        tar xzf php-memcached-php7.tgz
        cd php-memcached-php7
    else
        src_url=http://pecl.php.net/get/memcached-$memcached_pecl_version.tgz && Download_src
        tar xzf memcached-$memcached_pecl_version.tgz
        cd memcached-$memcached_pecl_version
    fi
    make clean
    $php_install_dir/bin/phpize
    ./configure --with-php-config=$php_install_dir/bin/php-config
    make -j ${THREAD} && make install
    if [ -f "`$php_install_dir/bin/php-config --extension-dir`/memcached.so" ];then
        cat > $php_install_dir/etc/php.d/ext-memcached.ini << EOF
extension=memcached.so
memcached.use_sasl=1
EOF
        echo "${CSUCCESS}PHP memcached module installed successfully! ${CEND}"
        cd ..
        rm -rf memcached-$memcached_pecl_version
        [ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
    else
        echo "${CFAILURE}PHP memcached module install failed, Please contact the author! ${CEND}"
    fi
fi
cd ..
}
