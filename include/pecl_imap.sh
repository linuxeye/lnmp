#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 7+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_pecl_imap() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    if [ "${PM}" == 'yum' ]; then
      yum -y install libc-client-devel
      [ "${OS_BIT}" == '64' -a ! -e /usr/lib/libc-client.so ] && ln -s /usr/lib64/libc-client.so /usr/lib/libc-client.so
    else
      apt-get -y install libc-client2007e-dev
    fi
    phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
    PHP_detail_ver=$(${php_install_dir}/bin/php-config --version)
    src_url=https://secure.php.net/distributions/php-${PHP_detail_ver}.tar.gz && Download_src
    tar xzf php-${PHP_detail_ver}.tar.gz
    pushd php-${PHP_detail_ver}/ext/imap > /dev/null
    ${php_install_dir}/bin/phpize
    ./configure --with-php-config=${php_install_dir}/bin/php-config --with-kerberos --with-imap --with-imap-ssl
    make -j ${THREAD} && make install
    popd > /dev/null
    if [ -f "${phpExtensionDir}/imap.so" ]; then
      echo 'extension=imap.so' > ${php_install_dir}/etc/php.d/04-imap.ini
      echo "${CSUCCESS}PHP imap module installed successfully! ${CEND}"
      rm -rf php-${PHP_detail_ver}
    else
      echo "${CFAILURE}PHP imap module install failed, Please contact the author! ${CEND}"
    fi
    popd > /dev/null
  fi
}

Uninstall_pecl_imap() {
  if [ -e "${php_install_dir}/etc/php.d/04-imap.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/04-imap.ini
    echo; echo "${CMSG}PHP imap module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP imap module does not exist! ${CEND}"
  fi
}
