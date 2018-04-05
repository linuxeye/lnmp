#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Upgrade_OneinStack() {
  pushd ${oneinstack_dir} > /dev/null
  Latest_OneinStack_MD5=$(curl -s http://mirrors.linuxeye.com/md5sum.txt | grep oneinstack.tar.gz | awk '{print $1}')
  [ ! -e install.sh ] && install_flag=n
  if [ "$oneinstack_md5" != "$Latest_OneinStack_MD5" ]; then
    /bin/mv options.conf /tmp
    sed -i '/oneinstack_dir=/d' /tmp/options.conf
    [ -e /tmp/oneinstack.tar.gz ] && rm -rf /tmp/oneinstack.tar.gz
    wget -qc http://mirrors.linuxeye.com/oneinstack.tar.gz -O /tmp/oneinstack.tar.gz
    if [ -n "`echo ${oneinstack_dir} | grep lnmp`" ]; then
      tar xzf /tmp/oneinstack.tar.gz -C /tmp
      /bin/cp -R /tmp/oneinstack/* ${oneinstack_dir}/
      /bin/rm -rf /tmp/oneinstack
    else
      tar xzf /tmp/oneinstack.tar.gz -C ../
    fi
    IFS=$'\n'
    for L in `grep -vE '^#|^$' /tmp/options.conf`
    do
      IFS=$IFS_old
      Key="`echo ${L%%=*}`"
      Value="`echo ${L#*=}`"
      sed -i "s@^${Key}=.*@${Key}=${Value}@" ./options.conf
    done
    rm -rf /tmp/{oneinstack.tar.gz,options.conf}
    [ "${install_flag}" == 'n' ] && rm -rf install.sh LICENSE README.md
    sed -i "s@^oneinstack_md5=.*@oneinstack_md5=${Latest_OneinStack_MD5}@" ./options.conf
    echo
    echo "${CSUCCESS}Congratulations! OneinStack upgrade successful! ${CEND}"
    echo
  else
    echo "${CWARNING}Your OneinStack already has the latest version or does not need to be upgraded! ${CEND}"
  fi
  popd > /dev/null
}
