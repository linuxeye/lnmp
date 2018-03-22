#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_XCache() {
  pushd ${oneinstack_dir}/src > /dev/null
  phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
  tar xzf xcache-${xcache_ver}.tar.gz
  pushd xcache-${xcache_ver}
  ${php_install_dir}/bin/phpize
  ./configure --enable-xcache --enable-xcache-coverager --enable-xcache-optimizer --with-php-config=${php_install_dir}/bin/php-config
  make -j ${THREAD} && make install
  if [ -f "${phpExtensionDir}/xcache.so" ]; then
    /bin/cp -R htdocs ${wwwroot_dir}/default/xcache
    popd
    chown -R ${run_user}.${run_user} ${wwwroot_dir}/default/xcache
    touch /tmp/xcache;chown ${run_user}.${run_user} /tmp/xcache
    let xcacheCount="${CPU}+1"
    let xcacheSize="${Memory_limit}/2"
    cat > ${php_install_dir}/etc/php.d/04-xcache.ini << EOF
[xcache-common]
extension=xcache.so
[xcache.admin]
xcache.admin.enable_auth=On
xcache.admin.user=admin
xcache.admin.pass="${xcachepwd_md5}"

[xcache]
xcache.size=${xcacheSize}M
xcache.count=${xcacheCount}
xcache.slots=8K
xcache.ttl=3600
xcache.gc_interval=300
xcache.var_size=4M
xcache.var_count=${xcacheCount}
xcache.var_slots=8K
xcache.var_ttl=0
xcache.var_maxttl=0
xcache.var_gc_interval=300
xcache.test=Off
xcache.readonly_protection=Off
xcache.shm_scheme=mmap
xcache.mmap_path=/tmp/xcache
xcache.coredump_directory=
xcache.cacher=On
xcache.stat=On
xcache.optimizer=Off

[xcache.coverager]
; enabling this feature will impact performance
; enable only if xcache.coverager == On && xcache.coveragedump_directory == "non-empty-value"
; enable coverage data collecting and xcache_coverager_start/stop/get/clean() functions
xcache.coverager = Off
xcache.coverager_autostart = On
xcache.coveragedump_directory = ""
EOF
    echo "${CSUCCESS}Xcache module installed successfully! ${CEND}"
    rm -rf xcache-${xcache_ver}
  else
    echo "${CFAILURE}Xcache module install failed, Please contact the author! ${CEND}"
  fi
  popd
}
