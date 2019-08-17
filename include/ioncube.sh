#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 8+ and Ubuntu 14+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_ionCube() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    PHP_detail_ver=`${php_install_dir}/bin/php-config --version`
    PHP_main_ver=${PHP_detail_ver%.*}
    phpExtensionDir=`${php_install_dir}/bin/php-config --extension-dir`
    [ ! -d "${phpExtensionDir}" ] && mkdir -p ${phpExtensionDir}
    [ -e "ioncube_loaders_lin_${SYS_BIT_d}.tar.gz" ] && tar xzf ioncube_loaders_lin_${SYS_BIT_d}.tar.gz
    if [ -z "`echo ${phpExtensionDir} | grep 'non-zts'`" ]; then
      /bin/mv ioncube/ioncube_loader_lin_${PHP_main_ver}_ts.so ${phpExtensionDir}
      zend_extension="${phpExtensionDir}/ioncube_loader_lin_${PHP_main_ver}_ts.so"
    else
      /bin/mv ioncube/ioncube_loader_lin_${PHP_main_ver}.so ${phpExtensionDir}
      zend_extension="${phpExtensionDir}/ioncube_loader_lin_${PHP_main_ver}.so"
    fi

    if [ -f "${zend_extension}" ]; then
      echo "zend_extension=${zend_extension}" > ${php_install_dir}/etc/php.d/00-ioncube.ini
      echo "${CSUCCESS}PHP ionCube module installed successfully! ${CEND}"
      rm -rf ioncube
    fi
    popd > /dev/null
  fi
}

Uninstall_ionCube() {
  if [ -e "${php_install_dir}/etc/php.d/00-ioncube.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/00-ioncube.ini
    echo; echo "${CMSG}PHP ionCube module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP ionCube module does not exist! ${CEND}"
  fi
}
