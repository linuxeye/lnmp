#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 8+ and Ubuntu 14+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_pecl_yaf() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    PHP_detail_ver=$(${php_install_dir}/bin/php-config --version)
    PHP_main_ver=${PHP_detail_ver%.*}
    if [[ "${PHP_main_ver}" =~ ^7.[0-3]$ ]]; then
      phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
      src_url=http://mirrors.linuxeye.com/oneinstack/src/yaf-${yaf_ver}.tar.gz && Download_src
      tar xzf yaf-${yaf_ver}.tar.gz
      pushd yaf-${yaf_ver} > /dev/null
      ${php_install_dir}/bin/phpize
      ./configure --with-php-config=${php_install_dir}/bin/php-config
      make -j ${THREAD} && make install
      popd > /dev/null
      if [ -f "${phpExtensionDir}/yaf.so" ]; then
        echo 'extension=yaf.so' > ${php_install_dir}/etc/php.d/04-yaf.ini
        echo "${CSUCCESS}PHP yaf module installed successfully! ${CEND}"
        rm -rf yaf-${yaf_ver}
      else
        echo "${CFAILURE}PHP yaf module install failed, Please contact the author! ${CEND}" && lsb_release -a
      fi
    else
      echo "${CWARNING}Your php ${PHP_detail_ver} does not support yaf! ${CEND}";
    fi
    popd > /dev/null
  fi
}

Uninstall_pecl_yaf() {
  if [ -e "${php_install_dir}/etc/php.d/04-yaf.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/04-yaf.ini
    echo; echo "${CMSG}PHP yaf module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP yaf module does not exist! ${CEND}"
  fi
}
