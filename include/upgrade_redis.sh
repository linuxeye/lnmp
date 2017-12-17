#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Upgrade_Redis() {
  pushd ${oneinstack_dir}/src > /dev/null
  [ ! -d "$redis_install_dir" ] && echo "${CWARNING}Redis is not installed on your system! ${CEND}" && exit 1
  OLD_Redis_version=`$redis_install_dir/bin/redis-cli --version | awk '{print $2}'`
  Latest_Redis_version=`curl -s http://download.redis.io/redis-stable/00-RELEASENOTES | awk '/Released/{print $2}' | head -1`
  [ -z "$Latest_Redis_version" ] && Latest_Redis_version=4.2.8
  echo "Current Redis Version: ${CMSG}$OLD_Redis_version${CEND}"
  while :; do echo
    read -p "Please input upgrade Redis Version(default: $Latest_Redis_version): " NEW_Redis_version
    [ -z "$NEW_Redis_version" ] && NEW_Redis_version=$Latest_Redis_version
    if [ "$NEW_Redis_version" != "$OLD_Redis_version" ]; then
      [ ! -e "redis-$NEW_Redis_version.tar.gz" ] && wget --no-check-certificate -c http://download.redis.io/releases/redis-$NEW_Redis_version.tar.gz > /dev/null 2>&1
      if [ -e "redis-$NEW_Redis_version.tar.gz" ]; then
        echo "Download [${CMSG}redis-$NEW_Redis_version.tar.gz${CEND}] successfully! "
        break
      else
        echo "${CWARNING}Redis version does not exist! ${CEND}"
      fi
    else
      echo "${CWARNING}input error! Upgrade Redis version is the same as the old version${CEND}"
    fi
  done

  if [ -e "redis-$NEW_Redis_version.tar.gz" ]; then
    echo "[${CMSG}redis-$NEW_Redis_version.tar.gz${CEND}] found"
    echo "Press Ctrl+c to cancel or Press any key to continue..."
    char=`get_char`
    tar xzf redis-$NEW_Redis_version.tar.gz
    pushd redis-$NEW_Redis_version
    make clean
    if [ "$OS_BIT" == '32' ]; then
      sed -i '1i\CFLAGS= -march=i686' src/Makefile
      sed -i 's@^OPT=.*@OPT=-O2 -march=i686@' src/.make-settings
    fi

    make -j ${THREAD}

    if [ -f "src/redis-server" ]; then
      echo "Restarting Redis..."
      service redis-server stop
      /bin/cp src/{redis-benchmark,redis-check-aof,redis-check-rdb,redis-cli,redis-sentinel,redis-server} $redis_install_dir/bin/
      service redis-server start
      popd > /dev/null
      echo "You have ${CMSG}successfully${CEND} upgrade from ${CWARNING}$OLD_Redis_version${CEND} to ${CWARNING}$NEW_Redis_version${CEND}"
      rm -rf redis-$NEW_Redis_version
    else
      echo "${CFAILURE}Upgrade Redis failed! ${CEND}"
    fi
  fi
  popd > /dev/null
}
