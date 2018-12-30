#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 7+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_ionCube() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    PHP_detail_ver=`${php_install_dir}/bin/php -r 'echo PHP_VERSION;'`
    PHP_main_ver=${PHP_detail_ver%.*}
    phpExtensionDir=`${php_install_dir}/bin/php-config --extension-dir`
    if  [ "${TARGET_ARCH}" == "armv7" ]; then
      tar xzf ioncube_loaders_lin_armv7l.tar.gz
    else
      tar xzf ioncube_loaders_lin_${SYS_BIT_d}.tar.gz
    fi

    [ -e "${php_install_dir}/bin/phpize" ] && [ ! -d "${phpExtensionDir}" ] && mkdir -p ${phpExtensionDir}
    case "${PHP_main_ver}" in
      7.3)
        if [ -z "`echo $phpExtensionDir | grep 'non-zts'`" ]; then
          /bin/mv ioncube/ioncube_loader_lin_7.3_ts.so ${phpExtensionDir}
          zend_extension="${phpExtensionDir}/ioncube_loader_lin_7.3_ts.so"
        else
          /bin/mv ioncube/ioncube_loader_lin_7.3.so ${phpExtensionDir}
          zend_extension="${phpExtensionDir}/ioncube_loader_lin_7.3.so"
        fi
        ;;
      7.2)
        if [ -z "`echo $phpExtensionDir | grep 'non-zts'`" ]; then
          /bin/mv ioncube/ioncube_loader_lin_7.2_ts.so ${phpExtensionDir}
          zend_extension="${phpExtensionDir}/ioncube_loader_lin_7.2_ts.so"
        else
          /bin/mv ioncube/ioncube_loader_lin_7.2.so ${phpExtensionDir}
          zend_extension="${phpExtensionDir}/ioncube_loader_lin_7.2.so"
        fi
        ;;
      7.1)
        if [ -z "`echo $phpExtensionDir | grep 'non-zts'`" ]; then
          /bin/mv ioncube/ioncube_loader_lin_7.1_ts.so ${phpExtensionDir}
          zend_extension="${phpExtensionDir}/ioncube_loader_lin_7.1_ts.so"
        else
          /bin/mv ioncube/ioncube_loader_lin_7.1.so ${phpExtensionDir}
          zend_extension="${phpExtensionDir}/ioncube_loader_lin_7.1.so"
        fi
        ;;
      7.0)
        if [ -z "`echo $phpExtensionDir | grep 'non-zts'`" ]; then
          /bin/mv ioncube/ioncube_loader_lin_7.0_ts.so ${phpExtensionDir}
          zend_extension="${phpExtensionDir}/ioncube_loader_lin_7.0_ts.so"
        else
          /bin/mv ioncube/ioncube_loader_lin_7.0.so ${phpExtensionDir}
          zend_extension="${phpExtensionDir}/ioncube_loader_lin_7.0.so"
        fi
        ;;
      5.6)
        if [ -z "`echo $phpExtensionDir | grep 'non-zts'`" ]; then
          /bin/mv ioncube/ioncube_loader_lin_5.6_ts.so ${phpExtensionDir}
          zend_extension="${phpExtensionDir}/ioncube_loader_lin_5.6_ts.so"
        else
          /bin/mv ioncube/ioncube_loader_lin_5.6.so ${phpExtensionDir}
          zend_extension="${phpExtensionDir}/ioncube_loader_lin_5.6.so"
        fi
        ;;
      5.5)
        if [ -z "`echo $phpExtensionDir | grep 'non-zts'`" ]; then
          /bin/mv ioncube/ioncube_loader_lin_5.5_ts.so ${phpExtensionDir}
          zend_extension="${phpExtensionDir}/ioncube_loader_lin_5.5_ts.so"
        else
          /bin/mv ioncube/ioncube_loader_lin_5.5.so ${phpExtensionDir}
          zend_extension="${phpExtensionDir}/ioncube_loader_lin_5.5.so"
        fi
       ;;
      5.4)
        if [ -z "`echo $phpExtensionDir | grep 'non-zts'`" ]; then
          /bin/mv ioncube/ioncube_loader_lin_5.4_ts.so ${phpExtensionDir}
          zend_extension="${phpExtensionDir}/ioncube_loader_lin_5.4_ts.so"
        else
          /bin/mv ioncube/ioncube_loader_lin_5.4.so ${phpExtensionDir}
          zend_extension="${phpExtensionDir}/ioncube_loader_lin_5.4.so"
        fi
        ;;
      5.3)
        if [ -z "`echo $phpExtensionDir | grep 'non-zts'`" ]; then
          /bin/mv ioncube/ioncube_loader_lin_5.3_ts.so ${phpExtensionDir}
          zend_extension="${phpExtensionDir}/ioncube_loader_lin_5.3_ts.so"
        else
          /bin/mv ioncube/ioncube_loader_lin_5.3.so ${phpExtensionDir}
          zend_extension="${phpExtensionDir}/ioncube_loader_lin_5.3.so"
        fi
        ;;
      *)
        echo "${CWARNING}Your php ${PHP_detail_ver} does not support ionCube! ${CEND}";
        ;;
    esac

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
