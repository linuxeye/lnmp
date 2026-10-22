#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com

Install_pecl_imap() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${current_dir}/src > /dev/null
    if [ "${PM}" == 'yum' ]; then
      if [ "${RHEL_ver}" == '9' ]; then
        cat > /etc/yum.repos.d/remi.repo << EOF
[remi]
name=Remi's RPM repository for Enterprise Linux 9 - \$basearch
mirrorlist=http://cdn.remirepo.net/enterprise/9/remi/\$basearch/mirror
enabled=0
gpgcheck=0
EOF
        dnf -y --enablerepo=remi install uw-imap-devel
      else
        yum -y install libc-client-devel
        [ ! -e /usr/lib/libc-client.so ] && ln -s /usr/lib64/libc-client.so /usr/lib/libc-client.so
      fi
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
      echo "${CFAILURE}PHP imap module install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
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
