#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       http://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_ZendGuardLoader()
{
cd $oneinstack_dir/src

PHP_version=`$php_install_dir/bin/php -r 'echo PHP_VERSION;'`
PHP_main_version=${PHP_version%.*}

[ ! -e "$php_install_dir/lib/php/extensions/" ] && mkdir $php_install_dir/lib/php/extensions/
if [ "$OS_BIT" == '64' ] ;then
    if [ "$PHP_main_version" == '5.6' ];then
        src_url=http://mirrors.linuxeye.com/oneinstack/src/zend-loader-php5.6-linux-x86_64.tar.gz && Download_src
        tar xzf zend-loader-php5.6-linux-x86_64.tar.gz 
        /bin/cp zend-loader-php5.6-linux-x86_64/ZendGuardLoader.so $php_install_dir/lib/php/extensions/
        rm -rf zend-loader-php5.6-linux-x86_64 
    fi

    if [ "$PHP_main_version" == '5.5' ];then
        src_url=http://mirrors.linuxeye.com/oneinstack/src/zend-loader-php5.5-linux-x86_64.tar.gz && Download_src
        tar xzf zend-loader-php5.5-linux-x86_64.tar.gz 
        /bin/cp zend-loader-php5.5-linux-x86_64/ZendGuardLoader.so $php_install_dir/lib/php/extensions/
        rm -rf zend-loader-php5.5-linux-x86_64 
    fi

    if [ "$PHP_main_version" == '5.4' ];then
        src_url=http://mirrors.linuxeye.com/oneinstack/src/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz && Download_src
        tar xzf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
        /bin/cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64/php-5.4.x/ZendGuardLoader.so $php_install_dir/lib/php/extensions/
        rm -rf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64
    fi

    if [ "$PHP_main_version" == '5.3' ];then
        src_url=http://mirrors.linuxeye.com/oneinstack/src/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz && Download_src
        tar xzf ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
        /bin/cp ZendGuardLoader-php-5.3-linux-glibc23-x86_64/php-5.3.x/ZendGuardLoader.so $php_install_dir/lib/php/extensions/
        rm -rf ZendGuardLoader-php-5.3-linux-glibc23-x86_64
    fi
else
    if [ "$PHP_main_version" == '5.6' ];then
        src_url=http://mirrors.linuxeye.com/oneinstack/src/zend-loader-php5.6-linux-i386.tar.gz && Download_src
        tar xzf zend-loader-php5.6-linux-i386.tar.gz 
        /bin/cp zend-loader-php5.6-linux-i386/ZendGuardLoader.so $php_install_dir/lib/php/extensions/
        rm -rf zend-loader-php5.6-linux-i386 
    fi

    if [ "$PHP_main_version" == '5.5' ];then
        src_url=http://mirrors.linuxeye.com/oneinstack/src/zend-loader-php5.5-linux-i386.tar.gz && Download_src
        tar xzf zend-loader-php5.5-linux-i386.tar.gz
        /bin/cp zend-loader-php5.5-linux-i386/ZendGuardLoader.so $php_install_dir/lib/php/extensions/
        rm -rf zend-loader-php5.5-linux-x386
    fi

    if [ "$PHP_main_version" == '5.4' ];then
        src_url=http://mirrors.linuxeye.com/oneinstack/src/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz && Download_src
    	tar xzf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz
    	/bin/cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386/php-5.4.x/ZendGuardLoader.so $php_install_dir/lib/php/extensions/
    	rm -rf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386
    fi

    if [ "$PHP_main_version" == '5.3' ];then
        src_url=http://mirrors.linuxeye.com/oneinstack/src/ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz && Download_src
    	tar xzf ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
    	/bin/cp ZendGuardLoader-php-5.3-linux-glibc23-i386/php-5.3.x/ZendGuardLoader.so $php_install_dir/lib/php/extensions/
    	rm -rf ZendGuardLoader-php-5.3-linux-glibc23-i386
    fi
fi

if [ -f "$php_install_dir/lib/php/extensions/ZendGuardLoader.so" ];then
    cat >> $php_install_dir/etc/php.ini << EOF
[Zend Guard Loader]
zend_extension="/usr/local/php/lib/php/extensions/ZendGuardLoader.so"
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
EOF
    echo "${CSUCCESS}ZendGuardLoader module install successfully! ${CEND}"
    [ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
else
    echo "${CFAILURE}ZendGuardLoader module install failed, Please contact the author! ${CEND}" 
fi
cd ..
}
