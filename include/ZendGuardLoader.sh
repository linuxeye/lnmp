#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_ZendGuardLoader() {
  pushd ${oneinstack_dir}/src > /dev/null
  PHP_detail_ver=$(${php_install_dir}/bin/php -r 'echo PHP_VERSION;')
  PHP_main_ver=${PHP_detail_ver%.*}
  phpExtensionDir=`${php_install_dir}/bin/php-config --extension-dir`
  [ ! -d "${phpExtensionDir}" ] && mkdir -p ${phpExtensionDir}
  if [ -n "`echo $phpExtensionDir | grep 'non-zts'`" ]; then
    case "${PHP_main_ver}" in
      5.6)
        tar xzf zend-loader-php5.6-linux-${SYS_BIT_c}.tar.gz
        /bin/cp zend-loader-php5.6-linux-${SYS_BIT_c}/ZendGuardLoader.so ${phpExtensionDir}
        rm -rf zend-loader-php5.6-linux-${SYS_BIT_c}
        ;;
      5.5)
        tar xzf zend-loader-php5.5-linux-${SYS_BIT_c}.tar.gz
        /bin/cp zend-loader-php5.5-linux-${SYS_BIT_c}/ZendGuardLoader.so ${phpExtensionDir}
        rm -rf zend-loader-php5.5-linux-${SYS_BIT_c}
        ;;
      5.4)
        tar xzf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-${SYS_BIT_c}.tar.gz
        /bin/cp ZendGuardLoader-70429-PHP-5.4-linux-glibc23-${SYS_BIT_c}/php-5.4.x/ZendGuardLoader.so ${phpExtensionDir}
        rm -rf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-${SYS_BIT_c}
        ;;
      5.3)
        tar xzf ZendGuardLoader-php-5.3-linux-glibc23-${SYS_BIT_c}.tar.gz
        /bin/cp ZendGuardLoader-php-5.3-linux-glibc23-${SYS_BIT_c}/php-5.3.x/ZendGuardLoader.so ${phpExtensionDir}
        rm -rf ZendGuardLoader-php-5.3-linux-glibc23-${SYS_BIT_c}
        ;;
      *)
        echo "Error! Your PHP ${PHP_detail_ver} does not support ZendGuardLoader!"
        ;;
    esac

    if [ -f "${phpExtensionDir}/ZendGuardLoader.so" ]; then
      cat > ${php_install_dir}/etc/php.d/01-ZendGuardLoader.ini<< EOF
[Zend Guard Loader]
zend_extension=${phpExtensionDir}/ZendGuardLoader.so
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
EOF
      echo "${CSUCCESS}PHP ZendGuardLoader module installed successfully! ${CEND}"
    fi
  else
    echo "Error! Your Apache's prefork or PHP already enable thread safety! "
  fi
  popd
}
