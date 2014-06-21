#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_XCache()
{
cd $lnmp_dir/src
. ../functions/download.sh
. ../options.conf

src_url=http://xcache.lighttpd.net/pub/Releases/3.1.0/xcache-3.1.0.tar.gz && Download_src
tar xzf xcache-3.1.0.tar.gz 
cd xcache-3.1.0
make clean
$php_install_dir/bin/phpize
./configure --enable-xcache --enable-xcache-coverager --enable-xcache-optimizer --with-php-config=$php_install_dir/bin/php-config
make && make install
if [ -f "$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions | grep zts`/xcache.so" ];then
	/bin/cp -R htdocs $home_dir/default/xcache
	chown -R www.www $home_dir/default/xcache
	touch /tmp/xcache;chown www.www /tmp/xcache

        Memtatol=`free -m | grep 'Mem:' | awk '{print $2}'`
        if [ $Memtatol -le 512 ];then
		xcache_size=40M
        elif [ $Memtatol -gt 512 -a $Memtatol -le 1024 ];then
		xcache_size=80M
        elif [ $Memtatol -gt 1024 -a $Memtatol -le 1500 ];then
		xcache_size=100M
        elif [ $Memtatol -gt 1500 -a $Memtatol -le 2500 ];then
		xcache_size=160M
        elif [ $Memtatol -gt 2500 -a $Memtatol -le 3500 ];then
		xcache_size=180M
        elif [ $Memtatol -gt 3500 ];then
		xcache_size=200M
        fi

	cat >> $php_install_dir/etc/php.ini << EOF
[xcache-common]
extension = "xcache.so"
[xcache.admin]
xcache.admin.enable_auth = On
xcache.admin.user = "admin"
xcache.admin.pass = "$xcache_admin_md5_pass"

[xcache]
xcache.size  = $xcache_size 
xcache.count = $(expr `cat /proc/cpuinfo | grep -c processor` + 1) 
xcache.slots = 8K
xcache.ttl = 3600
xcache.gc_interval = 300
xcache.var_size = $xcache_size 
xcache.var_count = $(expr `cat /proc/cpuinfo | grep -c processor` + 1) 
xcache.var_slots = 8K
xcache.var_ttl = 0
xcache.var_maxttl = 0
xcache.var_gc_interval = 300
xcache.test = Off
xcache.readonly_protection = Off
xcache.shm_scheme = "mmap"
xcache.mmap_path = "/tmp/xcache"
xcache.coredump_directory = ""
xcache.cacher = On
xcache.stat = On
xcache.optimizer = Off

[xcache.coverager]
; enabling this feature will impact performance
; enable only if xcache.coverager == On && xcache.coveragedump_directory == "non-empty-value"
; enable coverage data collecting and xcache_coverager_start/stop/get/clean() functions
xcache.coverager = Off
xcache.coverager_autostart = On
xcache.coveragedump_directory = ""
EOF
	[ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
else
        echo -e "\033[31meXcache module install failed, Please contact the author! \033[0m"
fi
cd ..
/bin/rm -rf xcache-3.1.0
cd ..
}
