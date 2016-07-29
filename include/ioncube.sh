#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_ionCube() {
cd $oneinstack_dir/src

PHP_version=`$php_install_dir/bin/php -r 'echo PHP_VERSION;'`
PHP_main_version=${PHP_version%.*}

if [ "$OS_BIT" == '64' ] ;then
    src_url=http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz && Download_src
    tar xzf ioncube_loaders_lin_x86-64.tar.gz
else
    src_url=http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86.tar.gz && Download_src
    tar xzf ioncube_loaders_lin_x86.tar.gz
fi

[ ! -d "`$php_install_dir/bin/php-config --extension-dir`" ] && mkdir -p `$php_install_dir/bin/php-config --extension-dir`
if [ "$PHP_main_version" == '5.6' ];then
    /bin/cp ioncube/ioncube_loader_lin_5.6.so `$php_install_dir/bin/php-config --extension-dir`
    zend_extension="`$php_install_dir/bin/php-config --extension-dir`/ioncube_loader_lin_5.6.so"
elif [ "$PHP_main_version" == '5.5' ];then
    /bin/cp ioncube/ioncube_loader_lin_5.5.so `$php_install_dir/bin/php-config --extension-dir`
    zend_extension="`$php_install_dir/bin/php-config --extension-dir`/ioncube_loader_lin_5.5.so"
elif [ "$PHP_main_version" == '5.4' ];then
    /bin/cp ioncube/ioncube_loader_lin_5.4.so `$php_install_dir/bin/php-config --extension-dir`
    zend_extension="`$php_install_dir/bin/php-config --extension-dir`/ioncube_loader_lin_5.4.so"
elif [ "$PHP_main_version" == '5.3' ];then
    /bin/cp ioncube/ioncube_loader_lin_5.3.so `$php_install_dir/bin/php-config --extension-dir`
    zend_extension="`$php_install_dir/bin/php-config --extension-dir`/ioncube_loader_lin_5.3.so"
else
    exit 1
fi

rm -rf ioncube
cat > $php_install_dir/etc/php.d/ext-0ioncube.ini << EOF
[ionCube Loader]
zend_extension=$zend_extension
EOF
[ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
cd ..
}
