#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_APCU() {
cd $oneinstack_dir/src
src_url=http://pecl.php.net/get/apcu-$apcu_version.tgz && Download_src

tar xzf apcu-$apcu_version.tgz
cd apcu-$apcu_version
make clean
$php_install_dir/bin/phpize
./configure --with-php-config=$php_install_dir/bin/php-config
make -j ${THREAD} && make install
if [ -f "`$php_install_dir/bin/php-config --extension-dir`/apcu.so" ];then
    cat > $php_install_dir/etc/php.d/ext-apcu.ini << EOF
[apcu]
extension=apcu.so
apc.enabled=1
apc.shm_size=32M
apc.ttl=7200
apc.enable_cli=1
EOF
    [ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
    /bin/cp apc.php $wwwroot_dir/default
    echo "${CSUCCESS}APCU module installed successfully! ${CEND}"
    cd ..
    rm -rf apcu-$apcu_version
else
    echo "${CFAILURE}APCU module install failed, Please contact the author! ${CEND}"
fi
cd ..
}
