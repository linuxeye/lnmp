#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_pecl_calendar() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
    PHP_detail_ver=$(${php_install_dir}/bin/php-config --version)
    src_url=https://secure.php.net/distributions/php-${PHP_detail_ver}.tar.gz && Download_src
    tar xzf php-${PHP_detail_ver}.tar.gz
    pushd php-${PHP_detail_ver}/ext/calendar > /dev/null
    ${php_install_dir}/bin/phpize
    ./configure --with-php-config=${php_install_dir}/bin/php-config
    make -j ${THREAD} && make install
    popd > /dev/null
    if [ -f "${phpExtensionDir}/calendar.so" ]; then
      echo 'extension=calendar.so' > ${php_install_dir}/etc/php.d/04-calendar.ini
      echo "${CSUCCESS}PHP calendar module installed successfully! ${CEND}"
      rm -rf php-${PHP_detail_ver}
    else
      echo "${CFAILURE}PHP calendar module install failed, Please contact the author! ${CEND}" && lsb_release -a
    fi
    popd > /dev/null
  fi
}

Uninstall_pecl_calendar() {
  if [ -e "${php_install_dir}/etc/php.d/04-calendar.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/04-calendar.ini
    echo; echo "${CMSG}PHP calendar module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP calendar module does not exist! ${CEND}"
  fi
}
