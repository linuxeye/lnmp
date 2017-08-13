#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_ionCube() {
  pushd ${oneinstack_dir}/src
  PHP_detail_version=`${php_install_dir}/bin/php -r 'echo PHP_VERSION;'`
  PHP_main_version=${PHP_detail_version%.*}
  phpExtensionDir=`${php_install_dir}/bin/php-config --extension-dir`
  if [ "${OS_BIT}" == '64' ]; then
      tar xzf ioncube_loaders_lin_x86-64.tar.gz
  else
    if  [ "${TARGET_ARCH}" == "armv7" ]; then
      tar xzf ioncube_loaders_lin_armv7l.tar.gz
    else
      tar xzf ioncube_loaders_lin_x86.tar.gz
    fi
  fi

  [ ! -d "${phpExtensionDir}" ] && mkdir -p ${phpExtensionDir}
  case "${PHP_main_version}" in
    7.1)
      /bin/cp ioncube/ioncube_loader_lin_7.1.so ${phpExtensionDir}
      zend_extension="${phpExtensionDir}/ioncube_loader_lin_7.1.so"
      ;;
    7.0)
      /bin/cp ioncube/ioncube_loader_lin_7.0.so ${phpExtensionDir}
      zend_extension="${phpExtensionDir}/ioncube_loader_lin_7.0.so"
      ;;
    5.6)
      /bin/cp ioncube/ioncube_loader_lin_5.6.so ${phpExtensionDir}
      zend_extension="${phpExtensionDir}/ioncube_loader_lin_5.6.so"
      ;;
    5.5)
     /bin/cp ioncube/ioncube_loader_lin_5.5.so ${phpExtensionDir}
     zend_extension="${phpExtensionDir}/ioncube_loader_lin_5.5.so"
     ;;
    5.4)
      /bin/cp ioncube/ioncube_loader_lin_5.4.so ${phpExtensionDir}
      zend_extension="${phpExtensionDir}/ioncube_loader_lin_5.4.so"
      ;;
    5.3)
      /bin/cp ioncube/ioncube_loader_lin_5.3.so ${phpExtensionDir}
      zend_extension="${phpExtensionDir}/ioncube_loader_lin_5.3.so"
      ;;
    *)
      echo "Error! Your PHP ${PHP_detail_version} does not support ionCube!"
      exit 1
      ;;
  esac

  echo "zend_extension=${zend_extension}" > ${php_install_dir}/etc/php.d/ext-0ioncube.ini
  rm -rf ioncube
  popd
}
