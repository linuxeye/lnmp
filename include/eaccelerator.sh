#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 7+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_eAccelerator() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    PHP_detail_ver=$(${php_install_dir}/bin/php-config --version)
    PHP_main_ver=${PHP_detail_ver%.*}
    phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
    if [[ "${PHP_main_ver}" =~ ^5.[3-4]$ ]]; then
      if [ "${PHP_main_ver}" == '5.3' ]; then
        tar jxf eaccelerator-${eaccelerator_ver}.tar.bz2
        pushd eaccelerator-${eaccelerator_ver} > /dev/null
      elif [ "${PHP_main_ver}" == '5.4' ]; then
        /bin/mv master eaccelerator-eaccelerator-42067ac.tar.gz
        tar xzf eaccelerator-eaccelerator-42067ac.tar.gz
        pushd eaccelerator-eaccelerator-42067ac > /dev/null
      fi
      ${php_install_dir}/bin/phpize
      ./configure --enable-eaccelerator=shared --with-php-config=${php_install_dir}/bin/php-config
      make -j ${THREAD} && make install
      popd > /dev/null
      if [ -f "${phpExtensionDir}/eaccelerator.so" ]; then
        mkdir /var/eaccelerator_cache;chown -R ${run_user}.${run_user} /var/eaccelerator_cache
        cat > ${php_install_dir}/etc/php.d/02-eaccelerator.ini << EOF
[eaccelerator]
zend_extension=${phpExtensionDir}/eaccelerator.so
eaccelerator.shm_size=64
eaccelerator.cache_dir=/var/eaccelerator_cache
eaccelerator.enable=1
eaccelerator.optimizer=1
eaccelerator.check_mtime=1
eaccelerator.debug=0
eaccelerator.filter=
eaccelerator.shm_max=0
eaccelerator.shm_ttl=0
eaccelerator.shm_prune_period=0
eaccelerator.shm_only=0
eaccelerator.compress=0
eaccelerator.compress_level=9
eaccelerator.keys=disk_only
eaccelerator.sessions=disk_only
eaccelerator.content=disk_only
EOF
        [ -z "$(grep 'kernel.shmmax = 67108864' /etc/sysctl.conf)" ] && echo "kernel.shmmax = 67108864" >> /etc/sysctl.conf
        sysctl -p
        echo "${CSUCCESS}PHP eaccelerator module installed successfully! ${CEND}"
        rm -rf eaccelerator-${eaccelerator_ver} eaccelerator-eaccelerator-42067ac
      else
        echo "${CFAILURE}PHP eaccelerator module install failed, Please contact the author! ${CEND}"
      fi
    else
      echo; echo "${CWARNING}Your php ${PHP_detail_ver} does not support eAccelerator! ${CEND}";
    fi
    popd > /dev/null
  fi
}

Uninstall_eAccelerator() {
  if [ -e "${php_install_dir}/etc/php.d/02-eaccelerator.ini" ]; then
    rm -rf ${php_install_dir}/etc/php.d/02-eaccelerator.ini /var/eaccelerator_cache
    echo; echo "${CMSG}PHP eaccelerator module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP eaccelerator module does not exist! ${CEND}"
  fi
}
