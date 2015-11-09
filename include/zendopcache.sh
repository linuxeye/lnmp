#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       http://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_ZendOPcache()
{
cd $oneinstack_dir/src
src_url=https://pecl.php.net/get/zendopcache-$zendopcache_version.tgz && Download_src

tar xzf zendopcache-$zendopcache_version.tgz 
cd zendopcache-$zendopcache_version 
make clean
$php_install_dir/bin/phpize
./configure --with-php-config=$php_install_dir/bin/php-config
make && make install
if [ -f "`$php_install_dir/bin/php-config --extension-dir`/opcache.so" ];then
    cat >> $php_install_dir/etc/php.ini << EOF
[opcache]
zend_extension="`$php_install_dir/bin/php-config --extension-dir`/opcache.so"
opcache.memory_consumption=$Memory_limit
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.save_comments=0
opcache.fast_shutdown=1
opcache.enable_cli=1
;opcache.optimization_level=0
EOF
    echo "${CSUCCESS}Zend OPcache module install successfully! ${CEND}"
    cd ..
    rm -rf zendopcache-$zendopcache_version
    [ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
else
    echo "${CFAILURE}Zend OPcache module install failed, Please contact the author! ${CEND}"
fi
cd ..
}
