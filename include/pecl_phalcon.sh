#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 7+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_pecl_phalcon() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    PHP_detail_ver=$(${php_install_dir}/bin/php -r 'echo PHP_VERSION;')
    PHP_main_ver=${PHP_detail_ver%.*}
    if [[ "${PHP_main_ver}" =~ ^5.[5-6]$|^7.[0-3]$ ]]; then
      phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
      src_url=http://mirrors.linuxeye.com/oneinstack/src/cphalcon-${phalcon_ver}.tar.gz && Download_src
      tar xzf cphalcon-${phalcon_ver}.tar.gz
      pushd cphalcon-${phalcon_ver}/build > /dev/null
      echo "${CMSG}It may take a few minutes... ${CEND}"
      ./install --phpize ${php_install_dir}/bin/phpize --php-config ${php_install_dir}/bin/php-config --arch ${OS_BIT}bits
      popd > /dev/null
      if [ -f "${phpExtensionDir}/phalcon.so" ]; then
        echo 'extension=phalcon.so' > ${php_install_dir}/etc/php.d/04-phalcon.ini
        echo "${CSUCCESS}PHP phalcon module installed successfully! ${CEND}"
        rm -rf cphalcon-${phalcon_ver}
      else
        echo "${CFAILURE}PHP phalcon module install failed, Please contact the author! ${CEND}"
      fi
    else
      echo "${CWARNING}Your php ${PHP_detail_ver} does not support phalcon! ${CEND}";
    fi
    popd > /dev/null
  fi
}

Uninstall_pecl_phalcon() {
  if [ -e "${php_install_dir}/etc/php.d/04-phalcon.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/04-phalcon.ini
    echo; echo "${CMSG}PHP phalcon module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP phalcon module does not exist! ${CEND}"
  fi
}
