#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_APCU()
{
cd $lnmp_dir/src
. ../functions/download.sh
. ../options.conf

src_url=http://pecl.php.net/get/apcu-4.0.6.tgz && Download_src
tar xzf apcu-4.0.6.tgz
cd apcu-4.0.6
make clean
$php_install_dir/bin/phpize
./configure --with-php-config=$php_install_dir/bin/php-config
make && make install
if [ -f "$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions | grep zts`/apcu.so" ];then
	cat >> $php_install_dir/etc/php.ini << EOF
extension = apcu.so
apc.enabled=1
apc.shm_size=32M
apc.ttl=7200
apc.enable_cli=1
EOF
	[ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
	/bin/cp apc.php $home_dir/default
else
        echo -e "\033[31meAPCU module install failed, Please contact the author! \033[0m"
fi
cd ../../
}
