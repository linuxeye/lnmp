#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com

Install_pecl_ldap() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${current_dir}/src > /dev/null
    phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
    PHP_detail_ver=$(${php_install_dir}/bin/php-config --version)
    src_url=https://secure.php.net/distributions/php-${PHP_detail_ver}.tar.gz && Download_src
    tar xzf php-${PHP_detail_ver}.tar.gz
    pushd php-${PHP_detail_ver}/ext/ldap > /dev/null
    if [ "${PM}" == 'yum' ]; then
      yum -y install openldap-devel
    else
      apt-get -y install libldap2-dev
      ln -s /usr/lib/${ARCH}-linux-gnu/libldap.so /usr/lib/
      ln -s /usr/lib/${ARCH}-linux-gnu/liblber.so /usr/lib/
    fi
    ${php_install_dir}/bin/phpize
    if [ "${PM}" == 'yum' ]; then
      ./configure --with-php-config=${php_install_dir}/bin/php-config --with-ldap --with-libdir=lib64
    else
      ./configure --with-php-config=${php_install_dir}/bin/php-config --with-ldap --with-libdir=lib/x86_64-linux-gnu
    fi
    make -j ${THREAD} && make install
    popd > /dev/null
    if [ -f "${phpExtensionDir}/ldap.so" ]; then
      echo 'extension=ldap.so' > ${php_install_dir}/etc/php.d/04-ldap.ini
      echo "${CSUCCESS}PHP ldap module installed successfully! ${CEND}"
      rm -rf php-${PHP_detail_ver}
    else
      echo "${CFAILURE}PHP ldap module install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
    fi
    popd > /dev/null
  fi
}

Uninstall_pecl_ldap() {
  if [ -e "${php_install_dir}/etc/php.d/04-ldap.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/04-ldap.ini
    echo; echo "${CMSG}PHP ldap module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP ldap module does not exist! ${CEND}"
  fi
}
