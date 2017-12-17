#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Upgrade_Memcached() {
  pushd ${oneinstack_dir}/src > /dev/null
  [ ! -e "${memcached_install_dir}/bin/memcached" ] && echo "${CWARNING}Memcached is not installed on your system! ${CEND}" && exit 1
  OLD_Memcached_version=`$memcached_install_dir/bin/memcached -V | awk '{print $2}'`
  Latest_Memcached_version=`curl -s http://memcached.org/downloads | awk -F'>|<' '/\/files\/memcached/{print $3}' | grep -oE "[0-9]\.[0-9]\.[0-9]+"`
  [ -z "$Latest_Memcached_version" ] && Latest_Memcached_version=1.6.8
  echo "Current Memcached Version: ${CMSG}$OLD_Memcached_version${CEND}"
  while :; do echo
    read -p "Please input upgrade Memcached Version(default: $Latest_Memcached_version): " NEW_Memcached_version
    [ -z "$NEW_Memcached_version" ] && NEW_Memcached_version=$Latest_Memcached_version
    if [ "${NEW_Memcached_version}" != "$OLD_Memcached_version" ]; then
      [ ! -e "memcached-${NEW_Memcached_version}.tar.gz" ] && wget --no-check-certificate -c http://www.memcached.org/files/memcached-${NEW_Memcached_version}.tar.gz > /dev/null 2>&1
      if [ -e "memcached-${NEW_Memcached_version}.tar.gz" ]; then
        echo "Download [${CMSG}memcached-${NEW_Memcached_version}.tar.gz${CEND}] successfully! "
        break
      else
        echo "${CWARNING}Memcached version does not exist! ${CEND}"
      fi
    else
      echo "${CWARNING}input error! Upgrade Memcached version is the same as the old version${CEND}"
    fi
  done

  if [ -e "memcached-${NEW_Memcached_version}.tar.gz" ]; then
    echo "[${CMSG}memcached-${NEW_Memcached_version}.tar.gz${CEND}] found"
    echo "Press Ctrl+c to cancel or Press any key to continue..."
    char=`get_char`
    tar xzf memcached-${NEW_Memcached_version}.tar.gz
    pushd memcached-${NEW_Memcached_version}
    make clean
    ./configure --prefix=${memcached_install_dir}
    make -j ${THREAD}

    if [ -e "memcached" ]; then
      echo "Restarting Memcached..."
      service memcached stop
      make install
      service memcached start
      popd > /dev/null
      echo "You have ${CMSG}successfully${CEND} upgrade from ${CWARNING}$OLD_Memcached_version${CEND} to ${CWARNING}${NEW_Memcached_version}${CEND}"
      rm -rf memcached-${NEW_Memcached_version}
    else
      echo "${CFAILURE}Upgrade Memcached failed! ${CEND}"
    fi
  fi
  popd > /dev/null
}
