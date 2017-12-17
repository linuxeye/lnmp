#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_pecl-mongodb() {
  pushd ${oneinstack_dir}/src
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
    if [[ "$(${php_install_dir}/bin/php -r 'echo PHP_VERSION;' | awk -F. '{print $1$2}')" =~ ^5[3-4]$ ]]; then
      tar xzf mongo-${mongo_pecl_version}.tgz 
      pushd mongo-${mongo_pecl_version} 
      ${php_install_dir}/bin/phpize
      ./configure --with-php-config=${php_install_dir}/bin/php-config
      make -j ${THREAD} && make install
      popd
      if [ -f "${phpExtensionDir}/mongo.so" ]; then
        echo 'extension=mongo.so' > ${php_install_dir}/etc/php.d/ext-mongo.ini
        rm -rf mongo-${mongo_pecl_version}
        echo "${CSUCCESS}PHP mongo module installed successfully! ${CEND}"
      else
        echo "${CFAILURE}PHP mongo module install failed, Please contact the author! ${CEND}"
      fi
    else
      tar xzf mongodb-${mongodb_pecl_version}.tgz 
      pushd mongodb-${mongodb_pecl_version} 
      ${php_install_dir}/bin/phpize
      ./configure --with-php-config=${php_install_dir}/bin/php-config
      make -j ${THREAD} && make install
      popd
      if [ -f "${phpExtensionDir}/mongodb.so" ]; then
        echo 'extension=mongodb.so' > ${php_install_dir}/etc/php.d/ext-mongodb.ini
        rm -rf mongodb-${mongodb_pecl_version}
        echo "${CSUCCESS}PHP mongodb module installed successfully! ${CEND}"
      else
        echo "${CFAILURE}PHP mongodb module install failed, Please contact the author! ${CEND}"
      fi
    fi
  fi
  popd
}
