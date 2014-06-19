#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_GraphicsMagick()
{
cd $lnmp_dir/src
. ../functions/download.sh
. ../options.conf

src_url=http://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick/1.3.19/GraphicsMagick-1.3.19.tar.gz && Download_src

tar xzf GraphicsMagick-1.3.19.tar.gz 
cd GraphicsMagick-1.3.19
./configure --enable-shared
make && make install
cd ../
/bin/rm -rf GraphicsMagick-1.3.19

if [ -e "$php_install_dir/bin/phpize" ];then
	src_url=http://pecl.php.net/get/gmagick-1.1.7RC2.tgz && Download_src
	tar xzf gmagick-1.1.7RC2.tgz 
	cd gmagick-1.1.7RC2
	make clean
	export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
	$php_install_dir/bin/phpize
	./configure --with-php-config=$php_install_dir/bin/php-config
	make && make install
	cd ../
	/bin/rm -rf gmagick-1.1.7RC2

	if [ -f "$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions | grep zts`/gmagick.so" ];then
		[ -z "`cat $php_install_dir/etc/php.ini | grep '^extension_dir'`" ] && sed -i "s@extension_dir = \"ext\"@extension_dir = \"ext\"\nextension_dir = \"$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions | grep zts`\"@" $php_install_dir/etc/php.ini
		sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "gmagick.so"@' $php_install_dir/etc/php.ini
	        [ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
	else
	        echo -e "\033[31mPHP Gmagick module install failed, Please contact the author! \033[0m"
	fi
fi
cd ../
}
