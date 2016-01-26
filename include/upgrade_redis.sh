#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       http://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Upgrade_Redis() {
cd $oneinstack_dir/src
[ ! -d "$redis_install_dir" ] && echo "${CWARNING}The Redis is not installed on your system! ${CEND}" && exit 1
OLD_Redis_version=`$redis_install_dir/bin/redis-cli --version | awk '{print $2}'`
echo "Current Redis Version: ${CMSG}$OLD_Redis_version${CEND}"
while :
do
    echo
    read -p "Please input upgrade Redis Version(example: 3.0.5): " NEW_Redis_version
    if [ "$NEW_Redis_version" != "$OLD_Redis_version" ];then
        [ ! -e "redis-$NEW_Redis_version.tar.gz" ] && wget --no-check-certificate -c http://download.redis.io/releases/redis-$NEW_Redis_version.tar.gz > /dev/null 2>&1
        if [ -e "redis-$NEW_Redis_version.tar.gz" ];then
            echo "Download [${CMSG}redis-$NEW_Redis_version.tar.gz${CEND}] successfully! "
            break
        else
            echo "${CWARNING}Redis version does not exist! ${CEND}"
        fi
    else
        echo "${CWARNING}input error! The upgrade Redis version is the same as the old version${CEND}"
    fi
done

if [ -e "redis-$NEW_Redis_version.tar.gz" ];then
    echo "[${CMSG}redis-$NEW_Redis_version.tar.gz${CEND}] found"
    echo "Press Ctrl+c to cancel or Press any key to continue..."
    char=`get_char`
    tar xzf redis-$NEW_Redis_version.tar.gz
    cd redis-$NEW_Redis_version
    make clean
    if [ "$OS_BIT" == '32' ];then
        sed -i '1i\CFLAGS= -march=i686' src/Makefile
        sed -i 's@^OPT=.*@OPT=-O2 -march=i686@' src/.make-settings
    fi

    make

    if [ -f "src/redis-server" ];then
        echo "Restarting Redis..."
        service redis-server stop
        /bin/cp src/{redis-benchmark,redis-check-aof,redis-check-dump,redis-cli,redis-sentinel,redis-server} $redis_install_dir/bin/
        service redis-server start
        echo "You have ${CMSG}successfully${CEND} upgrade from ${CWARNING}$OLD_Redis_version${CEND} to ${CWARNING}$NEW_Redis_version${CEND}"
    else
        echo "${CFAILURE}Upgrade Redis failed! ${CEND}" 
    fi
    cd ..
fi
cd ..
}
