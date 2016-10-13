#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_ZendOPcache() {
  pushd ${oneinstack_dir}/src
  phpExtensionDir=`${php_install_dir}/bin/php-config --extension-dir`
  tar xzf zendopcache-$zendopcache_version.tgz
  pushd zendopcache-$zendopcache_version
  ${php_install_dir}/bin/phpize
  ./configure --with-php-config=${php_install_dir}/bin/php-config
  make -j ${THREAD} && make install
  popd
  if [ -f "${phpExtensionDir}/opcache.so" ]; then
    cat > ${php_install_dir}/etc/php.d/ext-opcache.ini << EOF
[opcache]
zend_extension=${phpExtensionDir}/opcache.so
opcache.enable=1
opcache.memory_consumption=$Memory_limit
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.save_comments=0
opcache.fast_shutdown=1
opcache.enable_cli=1
;opcache.optimization_level=0
EOF
    echo "${CSUCCESS}PHP OPcache module installed successfully! ${CEND}"
    rm -rf zendopcache-${zendopcache_version}
  else
    echo "${CFAILURE}PHP OPcache module install failed, Please contact the author! ${CEND}"
  fi
  popd
}
