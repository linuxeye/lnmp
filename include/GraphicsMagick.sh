#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       http://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_GraphicsMagick() {
cd $oneinstack_dir/src
src_url=http://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick/$GraphicsMagick_version/GraphicsMagick-$GraphicsMagick_version.tar.gz && Download_src

tar xzf GraphicsMagick-$GraphicsMagick_version.tar.gz 
cd GraphicsMagick-$GraphicsMagick_version
./configure --prefix=/usr/local/graphicsmagick --enable-shared --enable-static
make && make install
cd ..
rm -rf GraphicsMagick-$GraphicsMagick_version
cd ..
}

Install_php-gmagick() {
cd $oneinstack_dir/src
if [ -e "$php_install_dir/bin/phpize" ];then
    if [ "`$php_install_dir/bin/php -r 'echo PHP_VERSION;' | awk -F. '{print $1}'`" == '7' ];then
        src_url=https://pecl.php.net/get/gmagick-2.0.2RC1.tgz && Download_src
        tar xzf gmagick-2.0.2RC1.tgz 
        cd gmagick-2.0.2RC1
    else
        src_url=http://pecl.php.net/get/gmagick-$gmagick_version.tgz && Download_src
        tar xzf gmagick-$gmagick_version.tgz 
        cd gmagick-$gmagick_version
    fi
    make clean
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
    $php_install_dir/bin/phpize
    ./configure --with-php-config=$php_install_dir/bin/php-config --with-gmagick=/usr/local/graphicsmagick
    make && make install
    cd ..
    rm -rf gmagick-$gmagick_version

    if [ -f "`$php_install_dir/bin/php-config --extension-dir`/gmagick.so" ];then
        [ -z "`grep '^extension_dir' $php_install_dir/etc/php.ini`" ] && sed -i "s@extension_dir = \"ext\"@extension_dir = \"ext\"\nextension_dir = \"`$php_install_dir/bin/php-config --extension-dir`\"@" $php_install_dir/etc/php.ini
        sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "gmagick.so"@' $php_install_dir/etc/php.ini
        [ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
    else
        echo "${CFAILURE}PHP Gmagick module install failed, Please contact the author! ${CEND}"
    fi
fi
cd ..
}
