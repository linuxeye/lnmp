#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_APCU() {
  pushd ${oneinstack_dir}/src > /dev/null
  phpExtensionDir=`${php_install_dir}/bin/php-config --extension-dir`
  if [ "`${php_install_dir}/bin/php -r 'echo PHP_VERSION;' | awk -F. '{print $1}'`" == '7' ]; then
    tar xzf apcu-${apcu_for_php7_ver}.tgz
    pushd apcu-${apcu_for_php7_ver}
  else
    tar xzf apcu-${apcu_ver}.tgz
    pushd apcu-${apcu_ver}
  fi

  ${php_install_dir}/bin/phpize
  ./configure --with-php-config=${php_install_dir}/bin/php-config
  make -j ${THREAD} && make install
  if [ -f "${phpExtensionDir}/apcu.so" ]; then
    cat > ${php_install_dir}/etc/php.d/02-apcu.ini << EOF
[apcu]
extension=apcu.so
apc.enabled=1
apc.shm_size=32M
apc.ttl=7200
apc.enable_cli=1
EOF
    /bin/cp apc.php ${wwwroot_dir}/default
    echo "${CSUCCESS}APCU module installed successfully! ${CEND}"
    popd
    rm -rf apcu-${apcu_for_php7_ver} apcu-${apcu_ver} package.xml
  else
    echo "${CFAILURE}APCU module install failed, Please contact the author! ${CEND}"
  fi
  popd
}
