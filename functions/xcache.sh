#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_XCache()
{
cd $lnmp_dir/src
. ../functions/download.sh
. ../options.conf

src_url=http://xcache.lighttpd.net/pub/Releases/3.0.3/xcache-3.0.3.tar.gz && Download_src
tar xzf xcache-3.0.3.tar.gz 
cd xcache-3.0.3
make clean
$php_install_dir/bin/phpize
./configure --enable-xcache --enable-xcache-coverager --enable-xcache-optimizer --with-php-config=$php_install_dir/bin/php-config
make && make install
if [ -f "$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions`/xcache.so" ];then
	/bin/cp -R htdocs $home_dir/default/xcache
	chown -R www.www $home_dir/default/xcache
	touch /tmp/xcache;chown www.www /tmp/xcache
	cat >> $php_install_dir/etc/php.ini << EOF
[xcache-common]
extension = "xcache.so"
[xcache.admin]
xcache.admin.enable_auth = On
xcache.admin.user = "admin"
xcache.admin.pass = "$xcache_admin_md5_pass"

[xcache]
xcache.cacher = On
xcache.size  = 20M
xcache.count = `cat /proc/cpuinfo | grep -c processor` 
xcache.slots = 8K
xcache.ttl = 3600
xcache.gc_interval = 300
xcache.var_size = 4M
xcache.var_count = 1
xcache.var_slots = 8K
xcache.var_ttl = 0
xcache.var_maxttl = 0
xcache.var_gc_interval = 300
xcache.test = Off
xcache.readonly_protection = On
xcache.mmap_path = "/tmp/xcache"
xcache.coredump_directory = ""
xcache.cacher = On
xcache.stat = On
xcache.optimizer = Off

[xcache.coverager]
; enabling this feature will impact performance
; enable only if xcache.coverager == On && xcache.coveragedump_directory == "non-empty-value"
; enable coverage data collecting and xcache_coverager_start/stop/get/clean() functions
xcache.coverager = On
xcache.coveragedump_directory = ""
EOF
	service php-fpm restart
else
        echo -e "\033[31meAccelerator module install failed, Please contact the author! \033[0m"
fi
cd ../../
}
