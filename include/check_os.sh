#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 7+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

if [ -e "/usr/bin/yum" ]; then
  PM=yum
  command -v lsb_release >/dev/null 2>&1 || { yum -y install redhat-lsb-core; clear; }
elif [ -e "/usr/bin/apt-get" ]; then
  PM=apt
  command -v lsb_release >/dev/null 2>&1 || { apt-get -y update; apt-get -y install lsb-release; clear; }
fi

command -v lsb_release >/dev/null 2>&1 || { echo "${CFAILURE}${PM} source failed! ${CEND}"; kill -9 $$; }

if [ -e /etc/redhat-release ]; then
  OS=CentOS
  CentOS_ver=$(lsb_release -sr | awk -F. '{print $1}')
  [ "${CentOS_ver}" == '17' ] && CentOS_ver=7
  [ "$(lsb_release -is)" == 'Fedora' ] && [ ${CentOS_ver} -ge 19 >/dev/null 2>&1 ] && { CentOS_ver=7; Fedora_ver=$(lsb_release -rs); }
elif [ -n "$(grep 'Amazon Linux' /etc/issue)" ]; then
  OS=CentOS
  CentOS_ver=7
elif [ -n "$(grep 'bian' /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == "Debian" ]; then
  OS=Debian
  Debian_ver=$(lsb_release -sr | awk -F. '{print $1}')
elif [ -n "$(grep 'Deepin' /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == "Deepin" ]; then
  OS=Debian
  Debian_ver=8
elif [ -n "$(grep -w 'Kali' /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == "Kali" ]; then
  OS=Debian
  if [ -n "$(grep 'VERSION="2016.*"' /etc/os-release)" ]; then
    Debian_ver=8
  elif [ -n "$(grep 'VERSION="2017.*"' /etc/os-release)" ]; then
    Debian_ver=9
  elif [ -n "$(grep 'VERSION="2018.*"' /etc/os-release)" ]; then
    Debian_ver=9
  fi
elif [ -n "$(grep 'Ubuntu' /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == "Ubuntu" -o -n "$(grep 'Linux Mint' /etc/issue)" ]; then
  OS=Ubuntu
  Ubuntu_ver=$(lsb_release -sr | awk -F. '{print $1}')
  [ -n "$(grep 'Linux Mint 18' /etc/issue)" ] && Ubuntu_ver=16
elif [ -n "$(grep 'elementary' /etc/issue)" -o "$(lsb_release -is 2>/dev/null)" == 'elementary' ]; then
  OS=Ubuntu
  Ubuntu_ver=16
else
  echo "${CFAILURE}Does not support this OS, Please contact the author! ${CEND}"
  kill -9 $$
fi

if [ "$(uname -r | awk -F- '{print $3}' 2>/dev/null)" == "Microsoft" ]; then
  Wsl=true
fi

if [ "$(getconf WORD_BIT)" == "32" ] && [ "$(getconf LONG_BIT)" == "64" ]; then
  OS_BIT=64
  SYS_BIT_j=x64 #jdk
  SYS_BIT_a=x86_64 #mariadb
  SYS_BIT_b=x86_64 #mariadb
  SYS_BIT_c=x86_64 #ZendGuardLoader
  SYS_BIT_d=x86-64 #ioncube
else
  OS_BIT=32
  SYS_BIT_j=i586
  SYS_BIT_a=x86
  SYS_BIT_b=i686
  SYS_BIT_c=i386
  SYS_BIT_d=x86
fi

LIBC_YN=$(awk -v A=$(getconf -a | grep GNU_LIBC_VERSION | awk '{print $NF}') -v B=2.14 'BEGIN{print(A>=B)?"0":"1"}')
[ ${LIBC_YN} == '0' ] && GLIBC_FLAG=linux-glibc_214 || GLIBC_FLAG=linux

if uname -m | grep -Eqi "arm"; then
  armplatform="y"
  if uname -m | grep -Eqi "armv7"; then
    TARGET_ARCH="armv7"
  elif uname -m | grep -Eqi "armv8"; then
    TARGET_ARCH="arm64"
  else
    TARGET_ARCH="unknown"
  fi
fi

THREAD=$(grep 'processor' /proc/cpuinfo | sort -u | wc -l)

# Percona binary: https://www.percona.com/doc/percona-server/5.7/installation.html#installing-percona-server-from-a-binary-tarball
if [ ${Debian_ver} -lt 9 >/dev/null 2>&1 ] || [ ${Ubuntu_ver} -lt 14 >/dev/null 2>&1 ]; then
  sslLibVer=ssl100
elif [[ "${CentOS_ver}" =~ ^[6-7]$ ]] && [ "$(lsb_release -is)" != 'Fedora' ]; then
  sslLibVer=ssl101
elif [ ${Debian_ver} -ge 9 >/dev/null 2>&1 ] || [ ${Ubuntu_ver} -ge 14 >/dev/null 2>&1 ]; then
  sslLibVer=ssl102
elif [ ${Fedora_ver} -ge 27 >/dev/null 2>&1 ]; then
  sslLibVer=ssl102
else
  sslLibVer=unknown
fi
