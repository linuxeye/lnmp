#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com

Install_pecl_swoole() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${current_dir}/src > /dev/null
    phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
    PHP_detail_ver=$(${php_install_dir}/bin/php-config --version)
    PHP_main_ver=${PHP_detail_ver%.*}
    if [[ "${PHP_main_ver}" =~ ^5.[3-6]$ ]]; then
      src_url=https://pecl.php.net/get/swoole-1.10.5.tgz && Download_src
      tar xzf swoole-1.10.5.tgz
      pushd swoole-1.10.5 > /dev/null
      ${php_install_dir}/bin/phpize
      ./configure --with-php-config=${php_install_dir}/bin/php-config --enable-openssl --with-openssl-dir=${openssl_install_dir}
    elif [[ "${PHP_main_ver}" =~ ^7.[0-1]$ ]]; then
      src_url=https://pecl.php.net/get/swoole-4.5.2.tgz && Download_src
      tar xzf swoole-4.5.2.tgz
      pushd swoole-4.5.2 > /dev/null
      ${php_install_dir}/bin/phpize
      ./configure --with-php-config=${php_install_dir}/bin/php-config --enable-openssl --with-openssl-dir=${openssl_install_dir}
    elif [[ "${PHP_main_ver}" =~ ^7.[2-4]$ ]]; then
      src_url=https://pecl.php.net/get/swoole-4.8.12.tgz && Download_src
      tar xzf swoole-4.8.12.tgz
      pushd swoole-4.8.12 > /dev/null
      ${php_install_dir}/bin/phpize
      ./configure --with-php-config=${php_install_dir}/bin/php-config --enable-openssl --with-openssl-dir=${openssl_install_dir} --enable-http2 --enable-swoole-json --enable-swoole-curl
    else
      src_url=https://pecl.php.net/get/swoole-${swoole_ver}.tgz && Download_src
      tar xzf swoole-${swoole_ver}.tgz
      pushd swoole-${swoole_ver} > /dev/null
      ${php_install_dir}/bin/phpize
      ./configure --with-php-config=${php_install_dir}/bin/php-config --enable-openssl --with-openssl-dir=${openssl_install_dir} --enable-http2 --enable-swoole-json --enable-swoole-curl
    fi
    make -j ${THREAD} && make install
    popd > /dev/null
    if [ -f "${phpExtensionDir}/swoole.so" ]; then
      echo 'extension=swoole.so' > ${php_install_dir}/etc/php.d/06-swoole.ini
      echo "${CSUCCESS}PHP swoole module installed successfully! ${CEND}"
      rm -rf swoole-${swoole_ver} swoole-4.8.12 swoole-1.10.5 swoole-4.5.2
    else
      echo "${CFAILURE}PHP swoole module install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
    fi
    popd > /dev/null
  fi
}

Uninstall_pecl_swoole() {
  if [ -e "${php_install_dir}/etc/php.d/06-swoole.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/06-swoole.ini
    echo; echo "${CMSG}PHP swoole module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP swoole module does not exist! ${CEND}"
  fi
}
