#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_openSSL102() {
  if [ ! -e "${openssl_install_dir}/lib/libcrypto.a" ]; then
    # install openssl-1.0.2
    pushd ${oneinstack_dir}/src > /dev/null
    tar xzf openssl-${openssl_ver}.tar.gz
    pushd openssl-${openssl_ver}
    make clean
    ./config --prefix=${openssl_install_dir} -fPIC shared zlib-dynamic
    make -j ${THREAD} && make install
    [ -z "`grep ^'export PATH=' /etc/profile`" ] && echo "export PATH=${openssl_install_dir}/bin:\$PATH" >> /etc/profile
    [ -n "`grep ^'export PATH=' /etc/profile`" -a -z "`grep ${openssl_install_dir} /etc/profile`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=${openssl_install_dir}/bin:\1@" /etc/profile
    . /etc/profile
    popd
    if [ -f "${openssl_install_dir}/lib/libcrypto.a" ]; then
      echo "${CSUCCESS}openssl-1.0.2 module installed successfully! ${CEND}"
      /bin/cp cacert.pem ${openssl_install_dir}/ssl/cert.pem
      echo "${openssl_install_dir}/lib" > /etc/ld.so.conf.d/openssl.conf
      ldconfig
      rm -rf openssl-${openssl_ver}
    else
      echo "${CFAILURE}openssl-1.0.2 install failed, Please contact the author! ${CEND}"
      kill -9 $$
    fi
    popd
  fi
}
