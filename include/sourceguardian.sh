#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 8+ and Ubuntu 14+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_SourceGuardian() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    PHP_detail_ver=`${php_install_dir}/bin/php-config --version`
    PHP_main_ver=${PHP_detail_ver%.*}
    phpExtensionDir=`${php_install_dir}/bin/php-config --extension-dir`
    if [[ "${PHP_main_ver}" =~ ^5.[3-6]$|^7.[0-2]$ ]] || [ "${TARGET_ARCH}" == "armv8" ]; then
      [ ! -e sourceguardian ] && mkdir sourceguardian
      if  [ "${TARGET_ARCH}" == "armv8" ]; then
        tar xzf loaders.linux-aarch64.tar.gz -C sourceguardian
      else
        tar xzf loaders.linux-${SYS_BIT_c}.tar.gz -C sourceguardian
      fi
      [ ! -d "${phpExtensionDir}" ] && mkdir -p ${phpExtensionDir}
      if [ -z "`echo ${phpExtensionDir} | grep 'non-zts'`" ]; then
        /bin/mv sourceguardian/ixed.${PHP_main_ver}ts.lin ${phpExtensionDir}
        extension="ixed.${PHP_main_ver}ts.lin"
      else
        /bin/mv sourceguardian/ixed.${PHP_main_ver}.lin ${phpExtensionDir}
        extension="ixed.${PHP_main_ver}.lin"
      fi

      if [ -f "${phpExtensionDir}/ixed.${PHP_main_ver}.lin" ]; then
        echo "extension=${extension}" > ${php_install_dir}/etc/php.d/02-sourceguardian.ini
        echo "${CSUCCESS}PHP SourceGuardian module installed successfully! ${CEND}"
        rm -rf sourceguardian
      fi
    else
      echo; echo "${CWARNING}Your php ${PHP_detail_ver} or platform ${TARGET_ARCH} does not support SourceGuardian! ${CEND}";
    fi
    popd > /dev/null
  fi
}

Uninstall_SourceGuardian() {
  if [ -e "${php_install_dir}/etc/php.d/02-sourceguardian.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/02-sourceguardian.ini
    echo; echo "${CMSG}PHP SourceGuardian module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP SourceGuardian module does not exist! ${CEND}"
  fi
}
