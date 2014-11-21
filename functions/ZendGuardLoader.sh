#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_ZendGuardLoader()
{
cd $lnmp_dir/src
. ../functions/download.sh
. ../options.conf

php_version=`$php_install_dir/bin/php -r 'echo PHP_VERSION;'`
PHP_version=${php_version%.*}

[ ! -e "$php_install_dir/lib/php/extensions/" ] && mkdir $php_install_dir/lib/php/extensions/
if [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 64 ] ;then
	if [ "$PHP_version" == '5.4' ];then
		src_url=http://blog.linuxeye.com/lnmp/src/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz && Download_src
		tar xzf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
		/bin/cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64/php-5.4.x/ZendGuardLoader.so $php_install_dir/lib/php/extensions/
		/bin/rm -rf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64
	fi

	if [ "$PHP_version" == '5.3' ];then
		src_url=http://blog.linuxeye.com/lnmp/src/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz && Download_src
		tar xzf ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
		/bin/cp ZendGuardLoader-php-5.3-linux-glibc23-x86_64/php-5.3.x/ZendGuardLoader.so $php_install_dir/lib/php/extensions/
		/bin/rm -rf ZendGuardLoader-php-5.3-linux-glibc23-x86_64
	fi
else
        if [ "$PHP_version" == '5.4' ];then
		src_url=http://blog.linuxeye.com/lnmp/src/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz && Download_src
		tar xzf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz
		/bin/cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386/php-5.4.x/ZendGuardLoader.so $php_install_dir/lib/php/extensions/
		/bin/rm -rf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386
        fi

        if [ "$PHP_version" == '5.3' ];then
		src_url=http://blog.linuxeye.com/lnmp/src/ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz && Download_src
		tar xzf ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz
		/bin/cp ZendGuardLoader-php-5.3-linux-glibc23-i386/php-5.3.x/ZendGuardLoader.so $php_install_dir/lib/php/extensions/
		/bin/rm -rf ZendGuardLoader-php-5.3-linux-glibc23-i386
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
        [ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
else
        echo -e "\033[31meZendGuardLoader module install failed, Please contact the author! \033[0m"
fi
cd ../
}
