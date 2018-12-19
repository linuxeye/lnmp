#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 7+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_SourceGuardian() {
  pushd ${oneinstack_dir}/src > /dev/null
  PHP_detail_ver=`${php_install_dir}/bin/php -r 'echo PHP_VERSION;'`
  PHP_main_ver=${PHP_detail_ver%.*}
  phpExtensionDir=`${php_install_dir}/bin/php-config --extension-dir`
  [ ! -e sourceguardian ] && mkdir sourceguardian
  if  [ "${TARGET_ARCH}" == "armv8" ]; then
    tar xzf loaders.linux-aarch64.tar.gz -C sourceguardian
  else
    tar xzf loaders.linux-${SYS_BIT_c}.tar.gz -C sourceguardian
  fi
  [ ! -d "${phpExtensionDir}" ] && mkdir -p ${phpExtensionDir}
  if [ -z "`echo ${phpExtensionDir} | grep 'non-zts'`" ]; then
    /bin/cp sourceguardian/ixed.${PHP_main_ver}ts.lin ${phpExtensionDir}
    extension="ixed.${PHP_main_ver}ts.lin"
  else
    /bin/cp sourceguardian/ixed.${PHP_main_ver}.lin ${phpExtensionDir}
    extension="ixed.${PHP_main_ver}.lin"
  fi

  if [ -f "${phpExtensionDir}/ixed.${PHP_main_ver}.lin" ]; then
    echo "extension=${extension}" > ${php_install_dir}/etc/php.d/02-sourceguardian.ini
    rm -rf sourceguardian
  fi
  popd > /dev/null
}
