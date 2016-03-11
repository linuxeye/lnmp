#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       http://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_ImageMagick() {
cd $oneinstack_dir/src
src_url=http://downloads.sourceforge.net/project/imagemagick/old-sources/6.x/6.8/ImageMagick-$ImageMagick_version.tar.gz && Download_src

tar xzf ImageMagick-$ImageMagick_version.tar.gz
cd ImageMagick-$ImageMagick_version
./configure --prefix=/usr/local/imagemagick --enable-shared --enable-static
make && make install
cd ..
rm -rf ImageMagick-$ImageMagick_version
cd ..
}

Install_php-imagick() {
cd $oneinstack_dir/src
if [ -e "$php_install_dir/bin/phpize" ];then
    if [ "`$php_install_dir/bin/php -r 'echo PHP_VERSION;' | awk -F. '{print $1}'`" == '7' ];then
        src_url=https://pecl.php.net/get/imagick-3.4.1.tgz && Download_src
        tar xzf imagick-3.4.1.tgz
        cd imagick-3.4.1
    else
        src_url=http://pecl.php.net/get/imagick-$imagick_version.tgz && Download_src
        tar xzf imagick-$imagick_version.tgz
        cd imagick-$imagick_version
    fi
    make clean
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
    $php_install_dir/bin/phpize
    ./configure --with-php-config=$php_install_dir/bin/php-config --with-imagick=/usr/local/imagemagick
    make && make install
    cd ..
    rm -rf imagick-$imagick_version

    if [ -f "`$php_install_dir/bin/php-config --extension-dir`/imagick.so" ];then
        [ -z "`grep '^extension_dir' $php_install_dir/etc/php.ini`" ] && sed -i "s@extension_dir = \"ext\"@extension_dir = \"ext\"\nextension_dir = \"`$php_install_dir/bin/php-config --extension-dir`\"@" $php_install_dir/etc/php.ini
        sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "imagick.so"@' $php_install_dir/etc/php.ini
        [ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
    else
        echo "${CFAILURE}PHP imagick module install failed, Please contact the author! ${CEND}"
    fi
fi
cd ..
}
