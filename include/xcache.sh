#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       http://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_XCache()
{
cd $oneinstack_dir/src
src_url=http://xcache.lighttpd.net/pub/Releases/$xcache_version/xcache-$xcache_version.tar.gz && Download_src

tar xzf xcache-$xcache_version.tar.gz 
cd xcache-$xcache_version
make clean
$php_install_dir/bin/phpize
./configure --enable-xcache --enable-xcache-coverager --enable-xcache-optimizer --with-php-config=$php_install_dir/bin/php-config
make && make install
if [ -f "`$php_install_dir/bin/php-config --extension-dir`/xcache.so" ];then
    /bin/cp -R htdocs $wwwroot_dir/default/xcache
    chown -R ${run_user}.$run_user $wwwroot_dir/default/xcache
    touch /tmp/xcache;chown ${run_user}.$run_user /tmp/xcache

    cat >> $php_install_dir/etc/php.ini << EOF
[xcache-common]
extension = "xcache.so"
[xcache.admin]
xcache.admin.enable_auth = On
xcache.admin.user = "admin"
xcache.admin.pass = "$xcache_admin_md5_pass"

[xcache]
xcache.size = $(expr $Memory_limit / 2)M
xcache.count = $(expr `cat /proc/cpuinfo | grep -c processor` + 1) 
xcache.slots = 8K
xcache.ttl = 3600
xcache.gc_interval = 300
xcache.var_size = 4M
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
    echo "${CSUCCESS}Xcache module install successfully! ${CEND}"
    cd ..
    rm -rf xcache-$xcache_version
    [ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
else
    echo "${CFAILURE}Xcache module install failed, Please contact the author! ${CEND}"
fi
cd ..
}
