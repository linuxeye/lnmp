#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_pecl_http()
{
cd $lnmp_dir/src
. ../functions/download.sh
. ../options.conf

src_url=http://pecl.php.net/get/raphf-1.0.4.tgz && Download_src
src_url=http://pecl.php.net/get/propro-1.0.0.tgz && Download_src
src_url=http://pecl.php.net/get/pecl_http-2.0.6.tgz && Download_src
tar xzf raphf-1.0.4.tgz
cd raphf-1.0.4
$php_install_dir/bin/phpize
./configure --with-php-config=$php_install_dir/bin/php-config
make && make install
cd ..

tar xzf propro-1.0.0.tgz
cd propro-1.0.0
$php_install_dir/bin/phpize
./configure --with-php-config=$php_install_dir/bin/php-config
make && make install
cd ..

tar xzf pecl_http-2.0.6.tgz
cd pecl_http-2.0.6
make clean
$php_install_dir/bin/phpize
./configure --with-php-config=$php_install_dir/bin/php-config
make && make install
if [ -f "$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions | grep zts`/http.so" ];then
	[ -z "`cat $php_install_dir/etc/php.ini | grep '^extension_dir'`" ] && sed -i "s@extension_dir = \"ext\"@extension_dir = \"ext\"\nextension_dir = \"$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions | grep zts`\"@" $php_install_dir/etc/php.ini
        sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "raphf.so"\nextension = "propro.so"\nextension = "http.so"@' $php_install_dir/etc/php.ini
        [ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
else
        echo -e "\033[31mPHP pecl_http module install failed, Please contact the author! \033[0m"
fi
cd ../../
}
