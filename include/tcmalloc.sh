#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_tcmalloc() {
  pushd ${oneinstack_dir}/src
  tar xzf gperftools-$tcmalloc_version.tar.gz
  pushd gperftools-$tcmalloc_version
  ./configure --enable-frame-pointers
  make -j ${THREAD} && make install
  popd
  if [ -f "/usr/local/lib/libtcmalloc.so" ]; then
    echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
    ldconfig
    echo "${CSUCCESS}tcmalloc module installed successfully! ${CEND}"
    rm -rf gperftools-$tcmalloc_version
  else
    echo "${CFAILURE}tcmalloc module install failed, Please contact the author! ${CEND}"
    kill -9 $$
  fi
  popd
}
