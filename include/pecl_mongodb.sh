#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_pecl-mongodb() {
  pushd ${oneinstack_dir}/src > /dev/null
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
    if [[ "$(${php_install_dir}/bin/php -r 'echo PHP_VERSION;' | awk -F. '{print $1$2}')" =~ ^5[3-4]$ ]]; then
      tar xzf mongo-${mongo_pecl_ver}.tgz
      pushd mongo-${mongo_pecl_ver}
      ${php_install_dir}/bin/phpize
      ./configure --with-php-config=${php_install_dir}/bin/php-config
      make -j ${THREAD} && make install
      popd
      if [ -f "${phpExtensionDir}/mongo.so" ]; then
        echo 'extension=mongo.so' > ${php_install_dir}/etc/php.d/07-mongo.ini
        rm -rf mongo-${mongo_pecl_ver}
        echo "${CSUCCESS}PHP mongo module installed successfully! ${CEND}"
      else
        echo "${CFAILURE}PHP mongo module install failed, Please contact the author! ${CEND}"
      fi
    else
      tar xzf mongodb-${mongodb_pecl_ver}.tgz
      pushd mongodb-${mongodb_pecl_ver}
      ${php_install_dir}/bin/phpize
      ./configure --with-php-config=${php_install_dir}/bin/php-config
      make -j ${THREAD} && make install
      popd
      if [ -f "${phpExtensionDir}/mongodb.so" ]; then
        echo 'extension=mongodb.so' > ${php_install_dir}/etc/php.d/07-mongodb.ini
        rm -rf mongodb-${mongodb_pecl_ver}
        echo "${CSUCCESS}PHP mongodb module installed successfully! ${CEND}"
      else
        echo "${CFAILURE}PHP mongodb module install failed, Please contact the author! ${CEND}"
      fi
    fi
  fi
  popd
}
