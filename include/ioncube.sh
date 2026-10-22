#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com

Install_ionCube() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${current_dir}/src > /dev/null
    PHP_detail_ver=`${php_install_dir}/bin/php-config --version`
    PHP_main_ver=${PHP_detail_ver%.*}
    phpExtensionDir=`${php_install_dir}/bin/php-config --extension-dir`
    [ ! -d "${phpExtensionDir}" ] && mkdir -p ${phpExtensionDir}
    [ -e "ioncube_loaders_lin_${SYS_ARCH_i}.tar.gz" ] && tar xzf ioncube_loaders_lin_${SYS_ARCH_i}.tar.gz
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
