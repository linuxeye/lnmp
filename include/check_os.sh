#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com

if [ -e "/etc/os-release" ]; then
  . /etc/os-release
else
  echo "${CFAILURE}/etc/os-release does not exist! ${CEND}"
  kill -9 $$; exit 1;
fi

# Get OS Version
Platform=${ID,,}
VERSION_MAIN_ID=${VERSION_ID%%.*}
ARCH=$(arch)
if [[ "${Platform}" =~ ^centos$|^rhel$|^almalinux$|^rocky$|^fedora$|^amzn$|^ol$|^alinux$|^anolis$|^tencentos$|^opencloudos$|^euleros$|^openeuler$|^kylin$|^uos$|^kylinsecos$ ]]; then
  PM=yum
  Family=rhel
  RHEL_ver=${VERSION_MAIN_ID}
  if [[ "${Platform}" =~ ^centos$ ]]; then
    if [ "${VERSION_MAIN_ID}" == '6' ]; then
      sed -i "s@centos/\$releasever@centos-vault/6.10@g" /etc/yum.repos.d/CentOS-Base.repo
      sed -i 's@centos/RPM-GPG@centos-vault/RPM-GPG@g' /etc/yum.repos.d/CentOS-Base.repo
      [ -e /etc/yum.repos.d/epel.repo ] && rm -f /etc/yum.repos.d/epel.repo
    fi
  elif [[ "${Platform}" =~ ^fedora$ ]]; then
    Fedora_ver=${VERSION_MAIN_ID}
    [ ${VERSION_MAIN_ID} -ge 19 ] && [ ${VERSION_MAIN_ID} -lt 28 ] && RHEL_ver=7
    [ ${VERSION_MAIN_ID} -ge 28 ] && [ ${VERSION_MAIN_ID} -lt 34 ] && RHEL_ver=8
    [ ${VERSION_MAIN_ID} -ge 34 ] && RHEL_ver=9
  elif [[ "${Platform}" =~ ^amzn$|^alinux$|^tencentos$|^euleros$ ]]; then
    [[ "${VERSION_MAIN_ID}" =~ ^2$ ]] && RHEL_ver=7
    [[ "${VERSION_MAIN_ID}" =~ ^3$ ]] && RHEL_ver=8
    [[ "${VERSION_MAIN_ID}" =~ ^4$ ]] && RHEL_ver=9
  elif [[ "${Platform}" =~ ^openeuler$ ]]; then
    [[ "${RHEL_ver}" =~ ^20$ ]] && RHEL_ver=7
    [[ "${RHEL_ver}" =~ ^2[1,2]$ ]] && RHEL_ver=8
  elif [[ "${Platform}" =~ ^kylin$ ]]; then
    [[ "${RHEL_ver}" =~ ^V10$ ]] && RHEL_ver=7
  elif [[ "${Platform}" =~ ^uos$ ]]; then
    [[ "${RHEL_ver}" =~ ^20$ ]] && RHEL_ver=8
  elif [[ "${Platform}" =~ ^kylinsecos$ ]]; then
    [[ "${VERSION_ID}" =~ ^3.4 ]] && RHEL_ver=7
    [[ "${VERSION_ID}" =~ ^3.5 ]] && RHEL_ver=8
  fi
elif [[ "${Platform}" =~ ^debian$|^deepin$|^kali$ ]]; then
  PM=apt-get
  Family=debian
  Debian_ver=${VERSION_MAIN_ID}
  if [[ "${Platform}" =~ ^deepin$ ]]; then
    [[ "${Debian_ver}" =~ ^20$ ]] && Debian_ver=10
    [[ "${Debian_ver}" =~ ^23$ ]] && Debian_ver=11
  elif [[ "${Platform}" =~ ^kali$ ]]; then
    [[ "${Debian_ver}" =~ ^202 ]] && Debian_ver=10
  fi
elif [[ "${Platform}" =~ ^ubuntu$|^linuxmint$|^elementary$ ]]; then
  PM=apt-get
  Family=ubuntu
  Ubuntu_ver=${VERSION_MAIN_ID}
  if [[ "${Platform}" =~ ^linuxmint$ ]]; then
    [[ "${VERSION_MAIN_ID}" =~ ^18$ ]] && Ubuntu_ver=16
    [[ "${VERSION_MAIN_ID}" =~ ^19$ ]] && Ubuntu_ver=18
    [[ "${VERSION_MAIN_ID}" =~ ^20$ ]] && Ubuntu_ver=20
    [[ "${VERSION_MAIN_ID}" =~ ^21$ ]] && Ubuntu_ver=22
  elif [[ "${Platform}" =~ ^elementary$ ]]; then
    [[ "${VERSION_MAIN_ID}" =~ ^5$ ]] && Ubuntu_ver=18
    [[ "${VERSION_MAIN_ID}" =~ ^6$ ]] && Ubuntu_ver=20
    [[ "${VERSION_MAIN_ID}" =~ ^7$ ]] && Ubuntu_ver=22
  fi
else
  echo "${CFAILURE}Does not support this OS ${CEND}"
  kill -9 $$; exit 1;
fi

# Check OS Version
if [ ${RHEL_ver} -lt 7 >/dev/null 2>&1 ] || [ ${Debian_ver} -lt 9 >/dev/null 2>&1 ] || [ ${Ubuntu_ver} -lt 16 >/dev/null 2>&1 ]; then
  echo "${CFAILURE}Does not support this OS, Please install CentOS 7+,Debian 9+,Ubuntu 16+ ${CEND}"
  kill -9 $$; exit 1;
fi

command -v gcc > /dev/null 2>&1 || $PM -y install gcc
gcc_ver=$(gcc -dumpversion | awk -F. '{print $1}')

[ ${gcc_ver} -lt 5 >/dev/null 2>&1 ] && redis_ver=6.2.14

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

# Percona binary: https://docs.percona.com/percona-server/5.7/installation/binary-tarball.html
if [ ${Debian_ver} -lt 9 >/dev/null 2>&1 ]; then
  sslLibVer=ssl100
elif [ "${RHEL_ver}" == '7' ] && [ "${Platform}" != 'fedora' ]; then
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

[ -e ~/.oneinstack ] && /bin/mv ~/.oneinstack ~/.lnmp
