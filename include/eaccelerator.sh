#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_eAccelerator() {
  pushd ${oneinstack_dir}/src
  phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
  case "${PHP_version}" in
    1)
      tar jxf eaccelerator-${eaccelerator_version}.tar.bz2
      pushd eaccelerator-${eaccelerator_version}
      ;;
    2)
      /bin/mv master eaccelerator-eaccelerator-42067ac.tar.gz
      tar xzf eaccelerator-eaccelerator-42067ac.tar.gz
      pushd eaccelerator-eaccelerator-42067ac
      ;;
    *)
      echo "${CWARNING}Your php does not support eAccelerator! ${CEND}"
      kill -9 $$
  esac
  ${php_install_dir}/bin/phpize
  ./configure --enable-eaccelerator=shared --with-php-config=${php_install_dir}/bin/php-config
  make -j ${THREAD} && make install
  popd
  if [ -f "${phpExtensionDir}/eaccelerator.so" ]; then
    mkdir /var/eaccelerator_cache;chown -R ${run_user}.${run_user} /var/eaccelerator_cache
    cat > ${php_install_dir}/etc/php.d/ext-eaccelerator.ini << EOF
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
    echo "${CSUCCESS}Accelerator module installed successfully! ${CEND}"
    [ -z "$(grep 'kernel.shmmax = 67108864' /etc/sysctl.conf)" ] && echo "kernel.shmmax = 67108864" >> /etc/sysctl.conf
    sysctl -p
    rm -rf eaccelerator-${eaccelerator_version} eaccelerator-eaccelerator-42067ac
  else
    echo "${CFAILURE}Accelerator module install failed, Please contact the author! ${CEND}"
  fi
  popd
}
