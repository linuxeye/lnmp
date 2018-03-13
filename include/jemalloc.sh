#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_Jemalloc() {
  if [ ! -e "/usr/local/lib/libjemalloc.so" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    tar xjf jemalloc-$jemalloc_ver.tar.bz2
    pushd jemalloc-$jemalloc_ver
    LDFLAGS="${LDFLAGS} -lrt" ./configure
    make -j ${THREAD} && make install
    unset LDFLAGS
    popd
    if [ -f "/usr/local/lib/libjemalloc.so" ]; then
      if [ "${OS_BIT}" == '64' -a "$OS" == 'CentOS' ]; then
        ln -s /usr/local/lib/libjemalloc.so.2 /usr/lib64/libjemalloc.so.1
      else
        ln -s /usr/local/lib/libjemalloc.so.2 /usr/lib/libjemalloc.so.1
      fi
      echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
      ldconfig
      echo "${CSUCCESS}jemalloc module installed successfully! ${CEND}"
      rm -rf jemalloc-${jemalloc_ver}
    else
      echo "${CFAILURE}jemalloc install failed, Please contact the author! ${CEND}"
      kill -9 $$
    fi
    popd
  fi
}
