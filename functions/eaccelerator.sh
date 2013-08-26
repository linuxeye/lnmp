#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_eAccelerator()
{
cd $lnmp_dir/src
. ../functions/download.sh
. ../functions/check_os.sh
. ../options.conf

src_url=https://github.com/downloads/eaccelerator/eaccelerator/eaccelerator-0.9.6.1.tar.bz2 && Download_src
tar jxf eaccelerator-0.9.6.1.tar.bz2
cd eaccelerator-0.9.6.1
make clean
$php_install_dir/bin/phpize
./configure --enable-eaccelerator=shared --with-php-config=$php_install_dir/bin/php-config
make && make install
cd ../

mkdir /var/eaccelerator_cache;chown -R www.www /var/eaccelerator_cache 
cat >> $php_install_dir/etc/php.ini << EOF
[eaccelerator]
zend_extension="$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions`/eaccelerator.so"
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

service php-fpm restart
}
