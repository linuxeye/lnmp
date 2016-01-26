#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       http://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_eAccelerator-0-9() {
cd $oneinstack_dir/src
src_url=https://github.com/downloads/eaccelerator/eaccelerator/eaccelerator-0.9.6.1.tar.bz2 && Download_src

tar jxf eaccelerator-0.9.6.1.tar.bz2
cd eaccelerator-0.9.6.1
make clean
$php_install_dir/bin/phpize
./configure --enable-eaccelerator=shared --with-php-config=$php_install_dir/bin/php-config
make && make install

if [ -f "`$php_install_dir/bin/php-config --extension-dir`/eaccelerator.so" ];then
    mkdir /var/eaccelerator_cache;chown -R ${run_user}.$run_user /var/eaccelerator_cache
    cat >> $php_install_dir/etc/php.ini << EOF
[eaccelerator]
zend_extension="`$php_install_dir/bin/php-config --extension-dir`/eaccelerator.so"
eaccelerator.shm_size="64"
eaccelerator.cache_dir="/var/eaccelerator_cache"
eaccelerator.enable="1"
eaccelerator.optimizer="1"
eaccelerator.check_mtime="1"
eaccelerator.debug="0"
eaccelerator.filter=""
eaccelerator.shm_max="0"
eaccelerator.shm_ttl="0"
eaccelerator.shm_prune_period="0"
eaccelerator.shm_only="0"
eaccelerator.compress="0"
eaccelerator.compress_level="9"
eaccelerator.keys = "disk_only"
eaccelerator.sessions = "disk_only"
eaccelerator.content = "disk_only"
EOF
    echo "${CSUCCESS}Accelerator module install successfully! ${CEND}"
    cd ..
    [ -z "`grep 'kernel.shmmax = 67108864' /etc/sysctl.conf`" ] && echo 'kernel.shmmax = 67108864' >> /etc/sysctl.conf
    sysctl -p
    [ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
else
    echo "${CFAILURE}Accelerator module install failed, Please contact the author! ${CEND}"
fi
cd ..
}
