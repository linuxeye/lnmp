#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 8+ and Ubuntu 14+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_pecl_mongodb() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
    if [[ "$(${php_install_dir}/bin/php-config --version | awk -F. '{print $1$2}')" =~ ^5[3-4]$ ]]; then
      src_url=https://pecl.php.net/get/mongo-${pecl_mongo_ver}.tgz && Download_src
      tar xzf mongo-${pecl_mongo_ver}.tgz
      pushd mongo-${pecl_mongo_ver} > /dev/null
      ${php_install_dir}/bin/phpize
      ./configure --with-php-config=${php_install_dir}/bin/php-config
      make -j ${THREAD} && make install
      popd > /dev/null
      if [ -f "${phpExtensionDir}/mongo.so" ]; then
        echo 'extension=mongo.so' > ${php_install_dir}/etc/php.d/07-mongo.ini
        rm -rf mongo-${pecl_mongo_ver}
        echo "${CSUCCESS}PHP mongo module installed successfully! ${CEND}"
      else
        echo "${CFAILURE}PHP mongo module install failed, Please contact the author! ${CEND}"
      fi
    else
      src_url=https://pecl.php.net/get/mongodb-${pecl_mongodb_ver}.tgz && Download_src
      tar xzf mongodb-${pecl_mongodb_ver}.tgz
      pushd mongodb-${pecl_mongodb_ver} > /dev/null
      ${php_install_dir}/bin/phpize
      ./configure --with-php-config=${php_install_dir}/bin/php-config
      make -j ${THREAD} && make install
      popd > /dev/null
      if [ -f "${phpExtensionDir}/mongodb.so" ]; then
        echo 'extension=mongodb.so' > ${php_install_dir}/etc/php.d/07-mongodb.ini
        echo "${CSUCCESS}PHP mongodb module installed successfully! ${CEND}"
        rm -rf mongodb-${pecl_mongodb_ver}
      else
        echo "${CFAILURE}PHP mongodb module install failed, Please contact the author! ${CEND}"
      fi
    fi
    popd > /dev/null
  fi
}

Uninstall_pecl_mongodb() {
  if [ -e "${php_install_dir}/etc/php.d/07-mongo.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/07-mongo.ini
    echo; echo "${CMSG}PHP mongo module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP mongo module does not exist! ${CEND}"
  fi
  if [ -e "${php_install_dir}/etc/php.d/07-mongodb.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/07-mongodb.ini
    echo; echo "${CMSG}PHP mongodb module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP mongodb module does not exist! ${CEND}"
  fi
}
