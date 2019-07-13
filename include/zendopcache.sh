#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 8+ and Ubuntu 14+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_ZendOPcache() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
    PHP_detail_ver=$(${php_install_dir}/bin/php-config --version)
    PHP_main_ver=${PHP_detail_ver%.*}
    if [[ "${PHP_main_ver}" =~ ^5.[3-4]$ ]]; then
      tar xzf zendopcache-${zendopcache_ver}.tgz
      pushd zendopcache-${zendopcache_ver} > /dev/null
    else
      src_url=https://secure.php.net/distributions/php-${PHP_detail_ver}.tar.gz && Download_src
      tar xzf php-${PHP_detail_ver}.tar.gz
      pushd php-${PHP_detail_ver}/ext/opcache > /dev/null
    fi

    ${php_install_dir}/bin/phpize
    ./configure --with-php-config=${php_install_dir}/bin/php-config
    make -j ${THREAD} && make install
    popd > /dev/null
    if [ -f "${phpExtensionDir}/opcache.so" ]; then
      # write opcache configs
      if [[ "${PHP_main_ver}" =~ ^5.[3-4]$ ]]; then
        # For php 5.3 5.4
        cat > ${php_install_dir}/etc/php.d/02-opcache.ini << EOF
[opcache]
zend_extension=${phpExtensionDir}/opcache.so
opcache.enable=1
opcache.memory_consumption=${Memory_limit}
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
;opcache.save_comments=0
opcache.fast_shutdown=1
opcache.enable_cli=1
;opcache.optimization_level=0
EOF
        rm -rf zendopcache-${zendopcache_ver}
      else
        # For php 5.5+
        cat > ${php_install_dir}/etc/php.d/02-opcache.ini << EOF
[opcache]
zend_extension=opcache.so
opcache.enable=1
opcache.enable_cli=1
opcache.memory_consumption=${Memory_limit}
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=100000
opcache.max_wasted_percentage=5
opcache.use_cwd=1
opcache.validate_timestamps=1
opcache.revalidate_freq=60
;opcache.save_comments=0
opcache.fast_shutdown=1
opcache.consistency_checks=0
;opcache.optimization_level=0
EOF
      fi

      echo "${CSUCCESS}PHP opcache module installed successfully! ${CEND}"
      rm -rf php-${PHP_detail_ver}
    else
      echo "${CFAILURE}PHP opcache module install failed, Please contact the author! ${CEND}"
    fi
    popd > /dev/null
  fi
}

Uninstall_ZendOPcache() {
  if [ -e "${php_install_dir}/etc/php.d/02-opcache.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/02-opcache.ini
    echo; echo "${CMSG}PHP opcache module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP opcache module does not exist! ${CEND}"
  fi
}
