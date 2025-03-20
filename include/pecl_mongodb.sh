#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com

Install_pecl_mongodb() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${current_dir}/src > /dev/null
    phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
    if [[ "$(${php_install_dir}/bin/php-config --version | awk -F. '{print $1$2}')" =~ ^5[3-6]$ ]]; then
      src_url=https://pecl.php.net/get/mongo-1.6.16.tgz && Download_src
      tar xzf mongo-1.6.16.tgz
      pushd mongo-1.6.16 > /dev/null
      ${php_install_dir}/bin/phpize
      ./configure --with-php-config=${php_install_dir}/bin/php-config
      make -j ${THREAD} && make install
      popd > /dev/null
      if [ -f "${phpExtensionDir}/mongo.so" ]; then
        echo 'extension=mongo.so' > ${php_install_dir}/etc/php.d/07-mongo.ini
        rm -rf mongo-1.6.16
        echo "${CSUCCESS}PHP mongo module installed successfully! ${CEND}"
      else
        echo "${CFAILURE}PHP mongo module install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
      fi
    else
      if [[ "$(${php_install_dir}/bin/php-config --version | awk -F. '{print $1$2}')" =~ ^70$ ]]; then
        src_url=https://pecl.php.net/get/mongodb-1.9.2.tgz && Download_src
        tar xzf mongodb-1.9.2.tgz
        pushd mongodb-1.9.2 > /dev/null
      elif [[ "$(${php_install_dir}/bin/php-config --version | awk -F. '{print $1$2}')" =~ ^7[1-3]$ ]]; then
        src_url=https://pecl.php.net/get/mongodb-1.16.2.tgz && Download_src
        tar xzf mongodb-1.16.2.tgz
        pushd mongodb-1.16.2 > /dev/null
      elif [[ "$(${php_install_dir}/bin/php-config --version | awk -F. '{print $1$2}')" =~ ^74|80$ ]]; then
        src_url=https://pecl.php.net/get/mongodb-1.20.1.tgz && Download_src
        tar xzf mongodb-1.20.1.tgz
        pushd mongodb-1.20.1 > /dev/null
      else
        src_url=https://pecl.php.net/get/mongodb-${pecl_mongodb_ver}.tgz && Download_src
        tar xzf mongodb-${pecl_mongodb_ver}.tgz
        pushd mongodb-${pecl_mongodb_ver} > /dev/null
      fi
      ${php_install_dir}/bin/phpize
      ./configure --with-php-config=${php_install_dir}/bin/php-config
      make -j ${THREAD} && make install
      popd > /dev/null
      if [ -f "${phpExtensionDir}/mongodb.so" ]; then
        echo 'extension=mongodb.so' > ${php_install_dir}/etc/php.d/07-mongodb.ini
        echo "${CSUCCESS}PHP mongodb module installed successfully! ${CEND}"
        rm -rf mongodb-1.9.2 mongodb-1.16.2 mongodb-${pecl_mongodb_ver}
      else
        echo "${CFAILURE}PHP mongodb module install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
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
