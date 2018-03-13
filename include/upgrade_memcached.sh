#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Upgrade_Memcached() {
  pushd ${oneinstack_dir}/src > /dev/null
  [ ! -e "${memcached_install_dir}/bin/memcached" ] && echo "${CWARNING}Memcached is not installed on your system! ${CEND}" && exit 1
  OLD_memcached_ver=`${memcached_install_dir}/bin/memcached -V | awk '{print $2}'`
  Latest_memcached_ver=`curl -s https://github.com/memcached/memcached/wiki/ReleaseNotes | grep 'internal present.*ReleaseNotes' |  grep -oE "[0-9]\.[0-9]\.[0-9]+" | head -1`
  [ -z "${Latest_memcached_ver}" ] && Latest_memcached_ver=1.6.8
  echo "Current Memcached Version: ${CMSG}${OLD_memcached_ver}${CEND}"
  while :; do echo
    read -p "Please input upgrade Memcached Version(default: ${Latest_memcached_ver}): " NEW_memcached_ver
    [ -z "${NEW_memcached_ver}" ] && NEW_memcached_ver=${Latest_memcached_ver}
    if [ "${NEW_memcached_ver}" != "${OLD_memcached_ver}" ]; then
      [ "$IPADDR_COUNTRY"x == "CN"x ] && DOWN_ADDR=http://mirrors.linuxeye.com/oneinstack/src || DOWN_ADDR=http://www.memcached.org/files
      [ ! -e "memcached-${NEW_memcached_ver}.tar.gz" ] && wget --no-check-certificate -c ${DOWN_ADDR}/memcached-${NEW_memcached_ver}.tar.gz > /dev/null 2>&1
      if [ -e "memcached-${NEW_memcached_ver}.tar.gz" ]; then
        echo "Download [${CMSG}memcached-${NEW_memcached_ver}.tar.gz${CEND}] successfully! "
        break
      else
        echo "${CWARNING}Memcached version does not exist! ${CEND}"
      fi
    else
      echo "${CWARNING}input error! Upgrade Memcached version is the same as the old version${CEND}"
    fi
  done

  if [ -e "memcached-${NEW_memcached_ver}.tar.gz" ]; then
    echo "[${CMSG}memcached-${NEW_memcached_ver}.tar.gz${CEND}] found"
    echo "Press Ctrl+c to cancel or Press any key to continue..."
    char=`get_char`
    tar xzf memcached-${NEW_memcached_ver}.tar.gz
    pushd memcached-${NEW_memcached_ver}
    make clean
    [ "${OS}" == "CentOS" ] && libevent_arg='--with-libevent=/usr/local'
    ./configure --prefix=${memcached_install_dir} ${libevent_arg}
    make -j ${THREAD}

    if [ -e "memcached" ]; then
      echo "Restarting Memcached..."
      service memcached stop
      make install
      service memcached start
      popd > /dev/null
      echo "You have ${CMSG}successfully${CEND} upgrade from ${CWARNING}${OLD_memcached_ver}${CEND} to ${CWARNING}${NEW_memcached_ver}${CEND}"
      rm -rf memcached-${NEW_memcached_ver}
    else
      echo "${CFAILURE}Upgrade Memcached failed! ${CEND}"
    fi
  fi
  popd > /dev/null
}
