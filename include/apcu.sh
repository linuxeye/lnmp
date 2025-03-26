#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com

Install_APCU() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${current_dir}/src > /dev/null
    phpExtensionDir=`${php_install_dir}/bin/php-config --extension-dir`
    if [ "`${php_install_dir}/bin/php-config --version | awk -F. '{print $1}'`" == '5' ]; then
      tar xzf apcu-4.0.11.tgz
      pushd apcu-4.0.11 > /dev/null
    else
      tar xzf apcu-${apcu_ver}.tgz
      pushd apcu-${apcu_ver} > /dev/null
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
      popd > /dev/null
      echo "${CSUCCESS}PHP apcu module installed successfully! ${CEND}"
      rm -rf apcu-${apcu_ver} apcu-4.0.11 package.xml
    else
      echo "${CFAILURE}PHP apcu module install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
    fi
    popd > /dev/null
  fi
}

Uninstall_APCU() {
  if [ -e "${php_install_dir}/etc/php.d/02-apcu.ini" ]; then
    rm -rf ${php_install_dir}/etc/php.d/02-apcu.ini ${wwwroot_dir}/default/apc.php
    echo; echo "${CMSG}PHP apcu module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP apcu module does not exist! ${CEND}"
  fi
}
