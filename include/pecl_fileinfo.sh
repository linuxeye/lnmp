#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 7+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_pecl_fileinfo() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
    PHP_detail_ver=$(${php_install_dir}/bin/php-config --version)
    src_url=http://www.php.net/distributions/php-${PHP_detail_ver}.tar.gz && Download_src
    tar xzf php-${PHP_detail_ver}.tar.gz
    pushd php-${PHP_detail_ver}/ext/fileinfo > /dev/null
    ${php_install_dir}/bin/phpize
    ./configure --with-php-config=${php_install_dir}/bin/php-config
    make -j ${THREAD} && make install
    popd > /dev/null
    if [ -f "${phpExtensionDir}/fileinfo.so" ]; then
      echo 'extension=fileinfo.so' > ${php_install_dir}/etc/php.d/04-fileinfo.ini
      echo "${CSUCCESS}PHP fileinfo module installed successfully! ${CEND}"
      rm -rf php-${PHP_detail_ver}
    else
      echo "${CFAILURE}PHP fileinfo module install failed, Please contact the author! ${CEND}"
    fi
    popd > /dev/null
  fi
}

Uninstall_pecl_fileinfo() {
  if [ -e "${php_install_dir}/etc/php.d/04-fileinfo.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/04-fileinfo.ini
    echo; echo "${CMSG}PHP fileinfo module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP fileinfo module does not exist! ${CEND}"
  fi
}
