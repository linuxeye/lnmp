#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_ImageMagick()
{
cd $lnmp_dir/src
. ../functions/download.sh
. ../options.conf

src_url=http://blog.linuxeye.com/lnmp/src/ImageMagick-6.8.7-5.tar.gz && Download_src
src_url=http://pecl.php.net/get/imagick-3.1.2.tgz && Download_src

tar xzf ImageMagick-6.8.7-5.tar.gz
cd ImageMagick-6.8.7-5
./configure
make && make install
cd ../
ln -s /usr/local/include/ImageMagick-6 /usr/local/include/ImageMagick

tar xzf imagick-3.1.2.tgz
cd imagick-3.1.2
make clean
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
$php_install_dir/bin/phpize
./configure --with-php-config=$php_install_dir/bin/php-config
make && make install
cd ../

if [ -f "$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions`/imagick.so" ];then
	sed -i "s@extension_dir = \"ext\"@extension_dir = \"ext\"\nextension_dir = \"$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions/`\"\nextension = \"imagick.so\"@" $php_install_dir/etc/php.ini
        [ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
else
        echo -e "\033[31mPHP imagick module install failed, Please contact the author! \033[0m"
fi

cd ../
}
