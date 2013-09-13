#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_GraphicsMagick()
{
cd $lnmp_dir/src
. ../functions/download.sh
. ../options.conf

src_url=http://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick/1.3.18/GraphicsMagick-1.3.18.tar.gz && Download_src
src_url=http://pecl.php.net/get/gmagick-1.1.2RC1.tgz && Download_src

tar xzf GraphicsMagick-1.3.18.tar.gz 
cd GraphicsMagick-1.3.18
./configure --enable-shared
make && make install
cd ../

tar xzf gmagick-1.1.2RC1.tgz 
cd gmagick-1.1.2RC1
make clean
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
$php_install_dir/bin/phpize
./configure --with-php-config=$php_install_dir/bin/php-config
make && make install
cd ../

if [ -f "$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions`/gmagick.so" ];then
	if [ -z "`cat $php_install_dir/etc/php.ini | grep ^extension_dir`" ];then
		sed -i "s@extension_dir = \"ext\"@extension_dir = \"ext\"\nextension_dir = \"$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions/`\"\nextension = \"gmagick.so\"@" $php_install_dir/etc/php.ini
	else
		sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "gmagick.so"@' $php_install_dir/etc/php.ini
	fi
        service php-fpm restart
else
        echo -e "\033[31mPHP Gmagick module install failed, Please contact the author! \033[0m"
fi

cd ../
}
