#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_pecl-pgsql() {
  pushd ${oneinstack_dir}/src > /dev/null
  phpExtensionDir=`${php_install_dir}/bin/php-config --extension-dir`
  PHP_detail_ver=$(${php_install_dir}/bin/php -r 'echo PHP_VERSION;')
  tar xzf php-${PHP_detail_ver}.tar.gz
  pushd php-${PHP_detail_ver}/ext/pgsql
  ${php_install_dir}/bin/phpize
  ./configure --with-pgsql=${pgsql_install_dir} --with-php-config=${php_install_dir}/bin/php-config
  make -j ${THREAD} && make install
  popd
  pushd php-${PHP_detail_ver}/ext/pdo_pgsql
  ${php_install_dir}/bin/phpize
  ./configure --with-pdo-pgsql=${pgsql_install_dir} --with-php-config=${php_install_dir}/bin/php-config
  make -j ${THREAD} && make install
  popd
  if [ -f "${phpExtensionDir}/pgsql.so" -a -f "${phpExtensionDir}/pdo_pgsql.so" ]; then
    echo 'extension=pgsql.so' > ${php_install_dir}/etc/php.d/07-pgsql.ini
    echo 'extension=pdo_pgsql.so' >> ${php_install_dir}/etc/php.d/07-pgsql.ini
    echo "${CSUCCESS}PHP pgsql module installed successfully! ${CEND}"
    popd
    rm -rf php-${PHP_detail_ver}
  else
    echo "${CFAILURE}PHP pgsql module install failed, Please contact the author! ${CEND}"
  fi
  popd
}
