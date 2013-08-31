#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_ZendOPcache()
{
cd $lnmp_dir/src
. ../functions/download.sh
. ../options.conf

src_url=https://github.com/zendtech/ZendOptimizerPlus/tarball/master && Download_src
/bin/mv master zendtech-ZendOptimizerPlus.tar.gz 
tar xzf zendtech-ZendOptimizerPlus.tar.gz 
cd zendtech-ZendOptimizerPlus*
make clean
$php_install_dir/bin/phpize
./configure --with-php-config=$php_install_dir/bin/php-config
make && make install
if [ -f "$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions`/opcache.so" ];then
        cat >> $php_install_dir/etc/php.ini << EOF
zend_extension="$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions`/opcache.so"
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.fast_shutdown=1
opcache.enable_cli=1
EOF
        service php-fpm restart
else
        echo -e "\033[31meZend OPcache module install failed, Please contact the author! \033[0m"
fi
cd ../../
}
