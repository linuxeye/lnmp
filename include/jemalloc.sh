#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_Jemalloc() {
  if [ ! -e "/usr/local/lib/libjemalloc.so" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    tar xjf jemalloc-${jemalloc_ver}.tar.bz2
    pushd jemalloc-${jemalloc_ver} > /dev/null
    ./configure
    make -j ${THREAD} && make install
    popd > /dev/null
    if [ -f "/usr/local/lib/libjemalloc.so" ]; then
      if [ "${OS_BIT}" == '64' -a "${LikeOS}" == 'CentOS' ]; then
        ln -s /usr/local/lib/libjemalloc.so.2 /usr/lib64/libjemalloc.so.1
      else
        ln -s /usr/local/lib/libjemalloc.so.2 /usr/lib/libjemalloc.so.1
      fi
      [ -z "`grep /usr/local/lib /etc/ld.so.conf.d/*.conf`" ] && echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
      ldconfig
      echo "${CSUCCESS}jemalloc module installed successfully! ${CEND}"
      rm -rf jemalloc-${jemalloc_ver}
    else
      echo "${CFAILURE}jemalloc install failed, Please contact the author! ${CEND}" && lsb_release -a
      kill -9 $$
    fi
    popd > /dev/null
  fi
}
