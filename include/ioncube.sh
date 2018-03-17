#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_ionCube() {
  pushd ${oneinstack_dir}/src > /dev/null
  PHP_detail_ver=`${php_install_dir}/bin/php -r 'echo PHP_VERSION;'`
  PHP_main_ver=${PHP_detail_ver%.*}
  phpExtensionDir=`${php_install_dir}/bin/php-config --extension-dir`
  if  [ "${TARGET_ARCH}" == "armv7" ]; then
    tar xzf ioncube_loaders_lin_armv7l.tar.gz
  else
    tar xzf ioncube_loaders_lin_${SYS_BIT_d}.tar.gz
  fi

  [ ! -d "${phpExtensionDir}" ] && mkdir -p ${phpExtensionDir}
  case "${PHP_main_ver}" in
    7.2)
      if [ -z "`echo $phpExtensionDir | grep 'non-zts'`" ]; then
        /bin/cp ioncube/ioncube_loader_lin_7.2_ts.so ${phpExtensionDir}
        zend_extension="${phpExtensionDir}/ioncube_loader_lin_7.2_ts.so"
      else
        /bin/cp ioncube/ioncube_loader_lin_7.2.so ${phpExtensionDir}
        zend_extension="${phpExtensionDir}/ioncube_loader_lin_7.2.so"
      fi
      ;;
    7.1)
      if [ -z "`echo $phpExtensionDir | grep 'non-zts'`" ]; then
        /bin/cp ioncube/ioncube_loader_lin_7.1_ts.so ${phpExtensionDir}
        zend_extension="${phpExtensionDir}/ioncube_loader_lin_7.1_ts.so"
      else
        /bin/cp ioncube/ioncube_loader_lin_7.1.so ${phpExtensionDir}
        zend_extension="${phpExtensionDir}/ioncube_loader_lin_7.1.so"
      fi
      ;;
    7.0)
      if [ -z "`echo $phpExtensionDir | grep 'non-zts'`" ]; then
        /bin/cp ioncube/ioncube_loader_lin_7.0_ts.so ${phpExtensionDir}
        zend_extension="${phpExtensionDir}/ioncube_loader_lin_7.0_ts.so"
      else
        /bin/cp ioncube/ioncube_loader_lin_7.0.so ${phpExtensionDir}
        zend_extension="${phpExtensionDir}/ioncube_loader_lin_7.0.so"
      fi
      ;;
    5.6)
      if [ -z "`echo $phpExtensionDir | grep 'non-zts'`" ]; then
        /bin/cp ioncube/ioncube_loader_lin_5.6_ts.so ${phpExtensionDir}
        zend_extension="${phpExtensionDir}/ioncube_loader_lin_5.6_ts.so"
      else
        /bin/cp ioncube/ioncube_loader_lin_5.6.so ${phpExtensionDir}
        zend_extension="${phpExtensionDir}/ioncube_loader_lin_5.6.so"
      fi
      ;;
    5.5)
      if [ -z "`echo $phpExtensionDir | grep 'non-zts'`" ]; then
        /bin/cp ioncube/ioncube_loader_lin_5.5_ts.so ${phpExtensionDir}
        zend_extension="${phpExtensionDir}/ioncube_loader_lin_5.5_ts.so"
      else
        /bin/cp ioncube/ioncube_loader_lin_5.5.so ${phpExtensionDir}
        zend_extension="${phpExtensionDir}/ioncube_loader_lin_5.5.so"
      fi
     ;;
    5.4)
      if [ -z "`echo $phpExtensionDir | grep 'non-zts'`" ]; then
        /bin/cp ioncube/ioncube_loader_lin_5.4_ts.so ${phpExtensionDir}
        zend_extension="${phpExtensionDir}/ioncube_loader_lin_5.4_ts.so"
      else
        /bin/cp ioncube/ioncube_loader_lin_5.4.so ${phpExtensionDir}
        zend_extension="${phpExtensionDir}/ioncube_loader_lin_5.4.so"
      fi
      ;;
    5.3)
      if [ -z "`echo $phpExtensionDir | grep 'non-zts'`" ]; then
        /bin/cp ioncube/ioncube_loader_lin_5.3_ts.so ${phpExtensionDir}
        zend_extension="${phpExtensionDir}/ioncube_loader_lin_5.3_ts.so"
      else
        /bin/cp ioncube/ioncube_loader_lin_5.3.so ${phpExtensionDir}
        zend_extension="${phpExtensionDir}/ioncube_loader_lin_5.3.so"
      fi
      ;;
    *)
      echo "Error! Your PHP ${PHP_detail_ver} does not support ionCube!"
      exit 1
      ;;
  esac

  echo "zend_extension=${zend_extension}" > ${php_install_dir}/etc/php.d/00-ioncube.ini
  rm -rf ioncube
  popd
}
