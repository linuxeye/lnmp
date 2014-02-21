#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_ZendOPcache()
{
cd $lnmp_dir/src
. ../options.conf

rm -rf ZendOptimizerPlus-master*
wget -c --no-check-certificate -O ZendOptimizerPlus-master.zip https://github.com/zendtech/ZendOptimizerPlus/archive/master.zip 
unzip -q ZendOptimizerPlus-master.zip 
cd ZendOptimizerPlus-master 
make clean
$php_install_dir/bin/phpize
./configure --with-php-config=$php_install_dir/bin/php-config
make && make install
if [ -f "$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions`/opcache.so" ];then
        cat >> $php_install_dir/etc/php.ini << EOF
[opcache]
zend_extension="$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions`/opcache.so"
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.save_comments=0
opcache.fast_shutdown=1
opcache.enable_cli=1
opcache.optimization_level=0
EOF
        [ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
else
        echo -e "\033[31meZend OPcache module install failed, Please contact the author! \033[0m"
fi
cd ../../
}
