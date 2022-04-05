#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

if [ -e "/usr/bin/yum" ]; then
  PM=yum
  if [ -e /etc/yum.repos.d/CentOS-Base.repo ] && grep -Eqi "release 6." /etc/redhat-release; then
    sed -i "s@centos/\$releasever@centos-vault/6.10@g" /etc/yum.repos.d/CentOS-Base.repo
    sed -i 's@centos/RPM-GPG@centos-vault/RPM-GPG@g' /etc/yum.repos.d/CentOS-Base.repo
    [ -e /etc/yum.repos.d/epel.repo ] && rm -f /etc/yum.repos.d/epel.repo
  fi
  if ! command -v lsb_release >/dev/null 2>&1; then
    if [ -e "/etc/euleros-release" ]; then
      yum -y install euleros-lsb
    elif [ -e "/etc/openEuler-release" -o -e "/etc/openeuler-release" ]; then
      yum -y install openeuler-lsb
    else
      yum -y install redhat-lsb-core
    fi
    clear
  fi
fi

if [ -e "/usr/bin/apt-get" ]; then
  PM=apt-get
  command -v lsb_release >/dev/null 2>&1 || { apt-get -y update > /dev/null; apt-get -y install lsb-release; clear; }
fi

command -v lsb_release >/dev/null 2>&1 || { echo "${CFAILURE}${PM} source failed! ${CEND}"; kill -9 $$; exit 1; }
[ -e "/etc/anolis-release" ] && { command -v lsb_release >/dev/null 2>&1 || yum -y install system-lsb-core; }

# Get OS Version
OS=$(lsb_release -is)
ARCH=$(arch)
if [[ "${OS}" =~ ^CentOS$|^CentOSStream$|^RedHat$|^Rocky$|^AlmaLinux$|^Fedora$|^Amazon$|^AlibabaCloud$|^AlibabaCloud\(AliyunLinux\)$|^AnolisOS$|^EulerOS$|^openEuler$|^Oracle$ ]]; then
  LikeOS=RHEL
  RHEL_ver=$(lsb_release -rs | awk -F. '{print $1}' | awk '{print $1}')
  [[ "${OS}" =~ ^Fedora$ ]] && [ ${RHEL_ver} -ge 19 >/dev/null 2>&1 ] && { RHEL_ver=7; Fedora_ver=$(lsb_release -rs); }
  [[ "${OS}" =~ ^Amazon$|^EulerOS$|^openEuler$ ]] && RHEL_ver=7
  [[ "${OS}" =~ ^openEuler$ ]] && [[ "${RHEL_ver}" =~ ^21$ ]] && RHEL_ver=8
  [[ "${OS}" =~ ^AlibabaCloud$|^AlibabaCloud\(AliyunLinux\)$ ]] && [[ "${RHEL_ver}" =~ ^2$ ]] && RHEL_ver=7
  [[ "${OS}" =~ ^AlibabaCloud$|^AlibabaCloud\(AliyunLinux\)$ ]] && [[ "${RHEL_ver}" =~ ^3$ ]] && RHEL_ver=8
elif [[ "${OS}" =~ ^Debian$|^Deepin$|^Uos$|^Kali$ ]]; then
  LikeOS=Debian
  Debian_ver=$(lsb_release -rs | awk -F. '{print $1}' | awk '{print $1}')
  [[ "${OS}" =~ ^Deepin$|^Uos$ ]] && [[ "${Debian_ver}" =~ ^20$ ]] && Debian_ver=10
  [[ "${OS}" =~ ^Kali$ ]] && [[ "${Debian_ver}" =~ ^202 ]] && Debian_ver=10
elif [[ "${OS}" =~ ^Ubuntu$|^LinuxMint$|^elementary$ ]]; then
  LikeOS=Ubuntu
  Ubuntu_ver=$(lsb_release -rs | awk -F. '{print $1}' | awk '{print $1}')
  if [[ "${OS}" =~ ^LinuxMint$ ]]; then
    [[ "${Ubuntu_ver}" =~ ^18$ ]] && Ubuntu_ver=16
    [[ "${Ubuntu_ver}" =~ ^19$ ]] && Ubuntu_ver=18
    [[ "${Ubuntu_ver}" =~ ^20$ ]] && Ubuntu_ver=20
  fi
  if [[ "${OS}" =~ ^elementary$ ]]; then
    [[ "${Ubuntu_ver}" =~ ^5$ ]] && Ubuntu_ver=18
    [[ "${Ubuntu_ver}" =~ ^6$ ]] && Ubuntu_ver=20
  fi
fi

# Check OS Version
if [ ${RHEL_ver} -lt 7 >/dev/null 2>&1 ] || [ ${Debian_ver} -lt 8 >/dev/null 2>&1 ] || [ ${Ubuntu_ver} -lt 16 >/dev/null 2>&1 ]; then
  echo "${CFAILURE}Does not support this OS, Please install CentOS 7+,Debian 8+,Ubuntu 16+ ${CEND}"
  kill -9 $$; exit 1;
fi

command -v gcc > /dev/null 2>&1 || $PM -y install gcc
gcc_ver=$(gcc -dumpversion | awk -F. '{print $1}')

[ ${gcc_ver} -lt 5 >/dev/null 2>&1 ] && redis_ver=${redis_oldver}

if uname -m | grep -Eqi "arm|aarch64"; then
  armplatform="y"
  if uname -m | grep -Eqi "armv7"; then
    TARGET_ARCH="armv7"
  elif uname -m | grep -Eqi "armv8"; then
    TARGET_ARCH="arm64"
  elif uname -m | grep -Eqi "aarch64"; then
    TARGET_ARCH="aarch64"
  else
    TARGET_ARCH="unknown"
  fi
fi

if [ "$(uname -r | awk -F- '{print $3}' 2>/dev/null)" == "Microsoft" ]; then
  Wsl=true
fi

if [ "$(getconf WORD_BIT)" == "32" ] && [ "$(getconf LONG_BIT)" == "64" ]; then
  if [ "${TARGET_ARCH}" == 'aarch64' ]; then
    SYS_ARCH=arm64
    SYS_ARCH_i=aarch64
    SYS_ARCH_n=arm64
  else
    SYS_ARCH=amd64 #openjdk
    SYS_ARCH_i=x86-64 #ioncube
    SYS_ARCH_n=x64 #nodejs
  fi
else
  echo "${CWARNING}32-bit OS are not supported! ${CEND}"
  kill -9 $$; exit 1;
fi

THREAD=$(grep 'processor' /proc/cpuinfo | sort -u | wc -l)

# Percona binary: https://www.percona.com/doc/percona-server/5.7/installation.html#installing-percona-server-from-a-binary-tarball
if [ ${Debian_ver} -lt 9 >/dev/null 2>&1 ]; then
  sslLibVer=ssl100
elif [ "${RHEL_ver}" == '7' ] && [ "${OS}" != 'Fedora' ]; then
  sslLibVer=ssl101
elif [ ${Debian_ver} -ge 9 >/dev/null 2>&1 ] || [ ${Ubuntu_ver} -ge 16 >/dev/null 2>&1 ]; then
  sslLibVer=ssl102
elif [ ${Fedora_ver} -ge 27 >/dev/null 2>&1 ]; then
  sslLibVer=ssl102
elif [ "${RHEL_ver}" == '8' ]; then
  sslLibVer=ssl1:111
else
  sslLibVer=unknown
fi
