#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com

Install_pecl_phalcon() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${current_dir}/src > /dev/null
    PHP_detail_ver=$(${php_install_dir}/bin/php-config --version)
    PHP_main_ver=${PHP_detail_ver%.*}
    phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
    if [[ "${PHP_main_ver}" =~ ^7.[2-4]$|^8.3$ ]]; then
      src_url=https://pecl.php.net/get/phalcon-${phalcon_ver}.tgz && Download_src
      tar xzf phalcon-${phalcon_ver}.tgz
      pushd phalcon-${phalcon_ver} > /dev/null
      ${php_install_dir}/bin/phpize
      echo "${CMSG}It may take a few minutes... ${CEND}"
      ./configure --with-php-config=${php_install_dir}/bin/php-config
      make -j ${THREAD} && make install
      popd > /dev/null
    elif [[ "${PHP_main_ver}" =~ ^5.[5-6]$|^7.[0-1]$ ]]; then
      src_url=${mirror_link}/src/cphalcon-3.4.5.tar.gz && Download_src
      tar xzf cphalcon-3.4.5.tar.gz
      pushd cphalcon-3.4.5/build > /dev/null
      echo "${CMSG}It may take a few minutes... ${CEND}"
      ./install --phpize ${php_install_dir}/bin/phpize --php-config ${php_install_dir}/bin/php-config --arch 64bits
      popd > /dev/null
    else
      echo "${CWARNING}Your php ${PHP_detail_ver} does not support phalcon! ${CEND}"
    fi
    if [ -f "${phpExtensionDir}/phalcon.so" ]; then
      echo 'extension=phalcon.so' > ${php_install_dir}/etc/php.d/04-phalcon.ini
      echo "${CSUCCESS}PHP phalcon module installed successfully! ${CEND}"
      rm -rf cphalcon-3.4.5 phalcon-${phalcon_ver}
    else
      echo "${CFAILURE}PHP phalcon module install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
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
