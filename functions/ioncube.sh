#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_ionCube()
{
cd $lnmp_dir/src
. ../functions/download.sh
. ../options.conf

php_version=`$php_install_dir/bin/php -r 'echo PHP_VERSION;'`
PHP_version=${php_version%.*}

if [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 64 ] ;then
	src_url=http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz && Download_src
	tar xzf ioncube_loaders_lin_x86-64.tar.gz
else
	src_url=http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86.tar.gz && Download_src
	tar xzf ioncube_loaders_lin_x86.tar.gz
fi

[ ! -e "$php_install_dir/lib/php/extensions/" ] && mkdir $php_install_dir/lib/php/extensions/
if [ "$PHP_version" == '5.5' ];then
        /bin/cp ioncube/ioncube_loader_lin_5.5.so $php_install_dir/lib/php/extensions/
	zend_extension="$php_install_dir/lib/php/extensions/ioncube_loader_lin_5.5.so"
elif [ "$PHP_version" == '5.4' ];then
        /bin/cp ioncube/ioncube_loader_lin_5.4.so $php_install_dir/lib/php/extensions/
	zend_extension="$php_install_dir/lib/php/extensions/ioncube_loader_lin_5.4.so"
elif [ "$PHP_version" == '5.3' ];then
        /bin/cp ioncube/ioncube_loader_lin_5.3.so $php_install_dir/lib/php/extensions/
	zend_extension="$php_install_dir/lib/php/extensions/ioncube_loader_lin_5.3.so"
fi

/bin/rm -rf ioncube
if [ -n "`grep '^\[opcache\]' $php_install_dir/etc/php.ini`" -a -z "`grep '^\[ionCube Loader\]' $php_install_dir/etc/php.ini`" ];then
	sed -i "s@^\[opcache\]@[ionCube Loader]\nzend_extension=\"$zend_extension\"\n[opcache]@" $php_install_dir/etc/php.ini
elif [ -z "`grep '^\[ionCube Loader\]' $php_install_dir/etc/php.ini`" ];then
	cat >> $php_install_dir/etc/php.ini << EOF
[ionCube Loader]
zend_extension="$zend_extension"
EOF
fi
[ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
cd ../
}
