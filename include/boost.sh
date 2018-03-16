#!/bin/bash
# Author:  Alpha Eva <kaneawk AT gmail.com>
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

installBoost() {
  pushd ${oneinstack_dir}/src > /dev/null
  if [ ! -e "/usr/local/lib/libboost_system.so" ]; then
    boostVersion2=$(echo ${boost_ver} | awk -F. '{print $1}')_$(echo ${boost_ver} | awk -F. '{print $2}')_$(echo ${boost_ver} | awk -F. '{print $3}')
    tar xzf boost_${boostVersion2}.tar.gz
    pushd boost_${boostVersion2}
    ./bootstrap.sh
    ./bjam --prefix=/usr/local
    ./b2 install
    popd
  fi
  if [ -e "/usr/local/lib/libboost_system.so" ]; then
    echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
    ldconfig
    echo "${CSUCCESS}Boost installed successfully! ${CEND}"
    rm -rf boost_${boostVersion2}
  else
    echo "${CFAILURE}Boost installed failed, Please contact the author! ${CEND}"
  fi
  popd
}
