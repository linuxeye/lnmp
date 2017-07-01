#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_openSSL102() {
  if [ ! -e "${openssl_install_dir}/lib/libcrypto.a" ]; then
    # install openssl-1.0.2
    pushd ${oneinstack_dir}/src
    tar xzf openssl-${openssl_version}.tar.gz
    pushd openssl-${openssl_version}
    make clean
    ./config --prefix=${openssl_install_dir} -fPIC shared zlib-dynamic
    make -j ${THREAD} && make install
    popd
    if [ -f "${openssl_install_dir}/lib/libcrypto.a" ]; then
      echo "${CSUCCESS}openssl-1.0.2 module installed successfully! ${CEND}"
      echo "${openssl_install_dir}/lib" > /etc/ld.so.conf.d/openssl.conf
      ldconfig
      rm -rf openssl-${openssl_version}
    else
      echo "${CFAILURE}openssl-1.0.2 install failed, Please contact the author! ${CEND}"
      kill -9 $$
    fi
    popd
  fi
}

Install_openSSL100() {
  if [ ! -e '/usr/local/openssl100s/lib/libcrypto.a' ]; then
    pushd ${oneinstack_dir}/src
    tar xzf openssl-1.0.0s.tar.gz
    pushd openssl-1.0.0s
    make clean
    ./config --prefix=/usr/local/openssl100s -fPIC shared zlib-dynamic
    make -j ${THREAD} && make install
    popd
    if [ -f "/usr/local/openssl100s/lib/libcrypto.a" ]; then
      echo "${CSUCCESS}openssl-1.0.0s module installed successfully! ${CEND}"
      rm -rf openssl-1.0.0s
    else
      echo "${CFAILURE}openssl-1.0.0s install failed, Please contact the author! ${CEND}"
      kill -9 $$
    fi
    popd
  fi
}
