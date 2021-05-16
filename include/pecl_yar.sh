#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_pecl_yar() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    PHP_detail_ver=$(${php_install_dir}/bin/php-config --version)
    PHP_main_ver=${PHP_detail_ver%.*}
    if [[ "${PHP_main_ver}" =~ ^7.[0-4]$|^8.0$ ]]; then
      phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
      src_url=https://pecl.php.net/get/yar-${yar_ver}.tgz && Download_src
      tar xzf yar-${yar_ver}.tgz
      pushd yar-${yar_ver} > /dev/null
      ${php_install_dir}/bin/phpize
      ./configure --with-php-config=${php_install_dir}/bin/php-config --with-curl=${curl_install_dir}
      make -j ${THREAD} && make install
      popd > /dev/null
      if [ -f "${phpExtensionDir}/yar.so" ]; then
        echo 'extension=yar.so' > ${php_install_dir}/etc/php.d/04-yar.ini
        echo "${CSUCCESS}PHP yar module installed successfully! ${CEND}"
        rm -rf yar-${yar_ver}
      else
        echo "${CFAILURE}PHP yar module install failed, Please contact the author! ${CEND}" && lsb_release -a
      fi
    else
      echo "${CWARNING}Your php ${PHP_detail_ver} does not support yar! ${CEND}";
    fi
    popd > /dev/null
  fi
}

Uninstall_pecl_yar() {
  if [ -e "${php_install_dir}/etc/php.d/04-yar.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/04-yar.ini
    echo; echo "${CMSG}PHP yar module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP yar module does not exist! ${CEND}"
  fi
}
