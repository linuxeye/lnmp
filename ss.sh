#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 7+ and Ubuntu 12+
#        Install SS Server
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
clear
printf "
#######################################################################
#       OneinStack for CentOS/RedHat 6+ Debian 7+ and Ubuntu 12+      #
#                         Install SS Server                           #
#       For more information please visit https://oneinstack.com      #
#######################################################################
"
# Check if user is root
[ $(id -u) != '0' ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

oneinstack_dir=$(dirname "`readlink -f $0`")
pushd ${oneinstack_dir}/src > /dev/null
. ../options.conf
. ../versions.txt
. ../include/color.sh
. ../include/check_os.sh
. ../include/download.sh
. ../include/python.sh

PUBLIC_IPADDR=$(../include/get_public_ipaddr.py)

Show_Help() {
  echo
  echo "Usage: $0  command ...[parameters]....
  --help, -h                  Show this help message
  --quiet, -q                 quiet operation
  --install, -i               Install
  --uninstall, -u             Uninstall
  --libev                     shadowsocks-libev
  --python                    shadowsocks-python
  --adduser                   Add shadowsocks account
  --password [password]       shadowsocks password
  --port [port]               shadowsocks port
  "
}
ARG_NUM=$#
TEMP=`getopt -o hqiu --long help,quiet,install,uninstall,libev,python,adduser,password:,port: -- "$@" 2>/dev/null`
[ $? != 0 ] && echo "${CWARNING}ERROR: unknown argument! ${CEND}" && Show_Help && exit 1
eval set -- "${TEMP}"
while :; do
  [ -z "$1" ] && break;
  case "$1" in
    -h|--help)
      Show_Help; exit 0
      ;;
    -q|--quiet)
      quiet_flag=y; shift 1
      ;;
    -i|--install)
      install_flag=y; shift 1
      ;;
    -u|--uninstall)
      uninstall_flag=y; shift 1
      ;;
    --libev)
      libev_queit=y; ss_option=1; shift 1
      ;;
    --python)
      python_queit=y; ss_option=2; shift 1
      ;;
    --adduser)
      adduser_flag=y; shift 1
      ;;
    --password)
      password_queit=y; SS_password=$2; shift 2
      ;;
    --port)
      port_queit=y; SS_port=$2; shift 2
      ;;
    --)
      shift
      ;;
    *)
      echo "${CWARNING}ERROR: unknown argument! ${CEND}" && Show_Help && exit 1
      ;;
  esac
done

[ "${CentOS_ver}" == '5' ] && { echo "${CWARNING}SS only support CentOS6,7 or Debian or Ubuntu! ${CEND}"; exit 1; }

Check_SS() {
  [ -f /usr/local/bin/ss-server ] && ss_option=1
  [ -f ${python_install_dir}/bin/ssserver ] && ss_option=2
}

AddUser_SS() {
  while :; do echo
    [ "${password_queit}" != 'y' ] && read -e -p "Please input password for SS: " SS_password
    [ -n "$(echo ${SS_password} | grep '[+|&]')" ] && { echo "${CWARNING}input error,not contain a plus sign (+) and & ${CEND}"; continue; }
    (( ${#SS_password} >= 5 )) && break || echo "${CWARNING}SS password least 5 characters! ${CEND}"
  done
}

Iptables() {
  if [ -e '/etc/sysconfig/iptables' ]; then
    SS_Already_port=$(grep -oE '9[0-9][0-9][0-9]' /etc/sysconfig/iptables | head -n 1)
  elif [ -e '/etc/iptables/rules.v4' ]; then
    SS_Already_port=$(grep -oE '9[0-9][0-9][0-9]' /etc/iptables/rules.v4 | head -n 1)
  elif [ -e '/etc/iptables.up.rules' ]; then
    SS_Already_port=$(grep -oE '9[0-9][0-9][0-9]' /etc/iptables.up.rules | head -n 1)
  fi

  if [ -n "${SS_Already_port}" ]; then
    let SS_Default_port="${SS_Already_port}+1"
  else
    SS_Default_port=9001
  fi

  while :; do echo
    [ "${port_queit}" != 'y' ] && read -e -p "Please input SS port(Default: ${SS_Default_port}): " SS_port
    SS_port=${SS_port:-${SS_Default_port}}
    if [ ${SS_port} -ge 1 >/dev/null 2>&1 -a ${SS_port} -le 65535 >/dev/null 2>&1 ]; then
      [ -z "$(netstat -tpln | grep :${SS_port}$)" ] && break || echo "${CWARNING}This port is already used! ${CEND}"
    else
      echo "${CWARNING}input error! Input range: 1~65535${CEND}"
    fi
  done

  if [ "${PM}" == 'yum' ]; then
    if [ -n "`grep 'dport 80 ' /etc/sysconfig/iptables`" ] && [ -z "$(grep -E ${SS_port} /etc/sysconfig/iptables)" ]; then
      iptables -I INPUT 4 -p udp -m state --state NEW -m udp --dport ${SS_port} -j ACCEPT
      iptables -I INPUT 4 -p tcp -m state --state NEW -m tcp --dport ${SS_port} -j ACCEPT
      service iptables save
      ip6tables -I INPUT 4 -p udp -m state --state NEW -m udp --dport ${SS_port} -j ACCEPT
      ip6tables -I INPUT 4 -p tcp -m state --state NEW -m tcp --dport ${SS_port} -j ACCEPT
      service ip6tables save
    fi
  elif [ "${PM}" == 'apt-get' ]; then
    if [ -e '/etc/iptables/rules.v4' ]; then
      if [ -n "`grep 'dport 80 ' /etc/iptables/rules.v4`" ] && [ -z "$(grep -E ${SS_port} /etc/iptables/rules.v4)" ]; then
        iptables -I INPUT 4 -p udp -m state --state NEW -m udp --dport ${SS_port} -j ACCEPT
        iptables -I INPUT 4 -p tcp -m state --state NEW -m tcp --dport ${SS_port} -j ACCEPT
        iptables-save > /etc/iptables/rules.v4
        ip6tables -I INPUT 4 -p udp -m state --state NEW -m udp --dport ${SS_port} -j ACCEPT
        ip6tables -I INPUT 4 -p tcp -m state --state NEW -m tcp --dport ${SS_port} -j ACCEPT
        ip6tables-save > /etc/iptables/rules.v6
      fi
    elif [ -e '/etc/iptables.up.rules' ]; then
      if [ -n "`grep 'dport 80 ' /etc/iptables.up.rules`" ] && [ -z "$(grep -E ${SS_port} /etc/iptables.up.rules)" ]; then
        iptables -I INPUT 4 -p udp -m state --state NEW -m udp --dport ${SS_port} -j ACCEPT
        iptables -I INPUT 4 -p tcp -m state --state NEW -m tcp --dport ${SS_port} -j ACCEPT
        iptables-save > /etc/iptables.up.rules
      fi
    fi
  fi
}

Def_parameter() {
  while :; do echo
    if [ "${libev_queit}" != 'y' -a "${python_queit}" != 'y' ]; then
      echo "Please select SS server version:"
      echo -e "\t${CMSG}1${CEND}. Install SS-libev"
      echo -e "\t${CMSG}2${CEND}. Install SS-python"
      read -e -p "Please input a number:(Default 1 press Enter) " ss_option
    fi
    ss_option=${ss_option:-1}
    if [[ ! "${ss_option}" =~ ^[1-2]$ ]]; then
      echo "${CWARNING}input error! Please only input number 1~2${CEND}"
    else
      break
    fi
  done
  AddUser_SS
  Iptables
  if [ "${PM}" == 'yum' ]; then
    pkgList="wget unzip openssl-devel gcc swig autoconf libtool libevent automake make curl curl-devel zlib-devel perl perl-devel cpio expat-devel gettext-devel git asciidoc xmlto c-ares-devel pcre-devel udns-devel libev-devel"
    for Package in ${pkgList}; do
      yum -y install ${Package}
    done
  elif [ "${PM}" == 'apt-get' ]; then
    apt-get -y update
    pkgList="curl wget unzip gcc swig automake make perl cpio git libudns-dev libev-dev gettext build-essential autoconf libtool libpcre3-dev asciidoc xmlto libc-ares-dev"
    for Package in ${pkgList}; do
      apt-get -y install $Package
    done
  fi
}

Install_SS_python() {
  Install_Python
  ${python_install_dir}/bin/pip install M2Crypto
  ${python_install_dir}/bin/pip install greenlet
  ${python_install_dir}/bin/pip install gevent
  ${python_install_dir}/bin/pip install git+https://github.com/shadowsocks/shadowsocks.git@master
  if [ -f ${python_install_dir}/bin/ssserver ]; then
    if [ -e /bin/systemctl ]; then
      /bin/cp ../init.d/SS-python.service /lib/systemd/system/shadowsocks.service
      sed -i "s@/usr/local/python@${python_install_dir}@g" /lib/systemd/system/shadowsocks.service
      systemctl enable shadowsocks
    else
      /bin/cp ../init.d/SS-python-init /etc/init.d/shadowsocks
      sed -i "s@SS_bin=.*@SS_bin=${python_install_dir}/bin/ssserver@" /etc/init.d/shadowsocks
      chmod +x /etc/init.d/shadowsocks
      [ "${PM}" == 'yum' ] && { chkconfig --add shadowsocks; chkconfig shadowsocks on; }
      [ "${PM}" == 'apt-get' ] && update-rc.d shadowsocks defaults
    fi
  else
    echo
    echo "${CQUESTION}SS-python install failed! Please visit https://oneinstack.com${CEND}"
    exit 1
  fi
}

Install_SS_libev() {
  src_url=http://mirrors.linuxeye.com/oneinstack/src/shadowsocks-libev-3.2.4.tar.gz && Download_src
  src_url=http://mirrors.linuxeye.com/oneinstack/src/libsodium-${libsodium_ver}.tar.gz && Download_src
  src_url=http://mirrors.linuxeye.com/oneinstack/src/mbedtls-2.16.0-apache.tgz && Download_src
  if [ ! -e "/usr/local/lib/libsodium.la" ]; then
    tar xzf libsodium-${libsodium_ver}.tar.gz
    pushd libsodium-${libsodium_ver} > /dev/null
    ./configure --disable-dependency-tracking --enable-minimal
    make -j ${THREAD} && make install
    popd > /dev/null
    rm -rf libsodium-${libsodium_ver}
  fi
  tar xzf mbedtls-2.16.0-apache.tgz
  pushd mbedtls-2.16.0 > /dev/null
  make SHARED=1 CFLAGS=-fPIC
  make DESTDIR=/usr install
  popd > /dev/null
  tar xzf shadowsocks-libev-3.2.4.tar.gz
  pushd shadowsocks-libev-3.2.4 > /dev/null
  make clean
  ./configure
  make -j ${THREAD} && make install
  popd > /dev/null
  [ -z "`grep /usr/local/lib /etc/ld.so.conf.d/*.conf`" ] && echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
  ldconfig
  if [ -f /usr/local/bin/ss-server ]; then
    if [ -e /bin/systemctl ]; then
      /bin/cp ../init.d/SS-libev.service /lib/systemd/system/shadowsocks.service
      systemctl enable shadowsocks
    else
      if [ "${PM}" == 'yum' ]; then
        /bin/cp ../init.d/SS-libev-init-CentOS /etc/init.d/shadowsocks
        chkconfig --add shadowsocks
        chkconfig shadowsocks on
      elif [ "${PM}" == 'apt-get' ]; then
        /bin/cp ../init.d/SS-libev-init-Ubuntu /etc/init.d/shadowsocks
        update-rc.d shadowsocks defaults
      fi
    fi
  else
    echo
    echo "${CQUESTION}SS-libev install failed! Please visit https://oneinstack.com${CEND}"
    exit 1
  fi
}

Uninstall_SS() {
  while :; do echo
    [ "${quiet_flag}" != 'y' ] && read -e -p "Do you want to uninstall SS? [y/n]: " uninstall_flag
    if [[ ! "${uninstall_flag}" =~ ^[y,n]$ ]]; then
      echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
      break
    fi
  done

  if [ "${uninstall_flag}" == 'y' ]; then
    [ -n "$(ps -ef | grep -v grep | grep -iE "ssserver|ss-server")" ] && service shadowsocks stop
    [ -e /lib/systemd/system/shadowsocks.service ] && { systemctl disable shadowsocks; rm -f /lib/systemd/system/shadowsocks.service; }
    [ "${PM}" == 'yum' ] && chkconfig --del shadowsocks
    [ "${PM}" == 'apt-get' ] && update-rc.d -f shadowsocks remove
    rm -rf /etc/shadowsocks /var/run/shadowsocks.pid /etc/init.d/shadowsocks
    if [ "${ss_option}" == '1' ]; then
      rm -f /usr/local/bin/{ss-local,ss-tunnel,ss-server,ss-manager,ss-redir}
      rm -f /usr/local/lib/libshadowsocks.*
      rm -f /usr/local/include/shadowsocks.h
      rm -f /usr/local/lib/pkgconfig/shadowsocks-libev.pc
      rm -f /usr/local/share/man/man1/{ss-local.1,ss-tunnel.1,ss-server.1,ss-manager.1,ss-redir.1,shadowsocks.8}
      if [ $? -eq 0 ]; then
        echo "${CSUCCESS}SS-libev uninstall successful! ${CEND}"
      else
        echo "${CFAILURE}SS-libev uninstall failed! ${CEND}"
      fi
    elif [ "${ss_option}" == '2' ]; then
      ${python_install_dir}/bin/pip uninstall -y shadowsocks
      if [ $? -eq 0 ]; then
        echo "${CSUCCESS}SS-python uninstall successful! ${CEND}"
      else
        echo "${CFAILURE}SS-python uninstall failed! ${CEND}"
      fi
    fi
  fi
}

Config_SS() {
  [ ! -d "/etc/shadowsocks" ] && mkdir /etc/shadowsocks
  [ "${ss_option}" == '1' ] && cat > /etc/shadowsocks/config.json << EOF
{
    "server":"0.0.0.0",
    "mode":"tcp_and_udp",
    "server_port":${SS_port},
    "local_port":1080,
    "password":"${SS_password}",
    "timeout":300,
    "method":"aes-256-cfb"
}
EOF

  [ "${ss_option}" == '2' ] && cat > /etc/shadowsocks/config.json << EOF
{
    "server":"0.0.0.0",
    "local_address":"127.0.0.1",
    "local_port":1080,
    "port_password":{
    "${SS_port}":"${SS_password}"
    },
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open":false
}
EOF
}

AddUser_Config_SS() {
  [ ! -e /etc/shadowsocks/config.json ] && { echo "${CFAILURE}SS is not installed! ${CEND}"; exit 1; }
  [ -z "$(grep \"${SS_port}\" /etc/shadowsocks/config.json)" ] && sed -i "s@\"port_password\":{@\"port_password\":{\n\t\"${SS_port}\":\"${SS_password}\",@" /etc/shadowsocks/config.json || { echo "${CWARNING}This port is already in /etc/shadowsocks/config.json${CEND}"; exit 1; }
}

Print_User_SS() {
  printf "
Your Server IP: ${CMSG}${PUBLIC_IPADDR}${CEND}
Your Server Port: ${CMSG}${SS_port}${CEND}
Your Password: ${CMSG}${SS_password}${CEND}
Your Local IP: ${CMSG}127.0.0.1${CEND}
Your Local Port: ${CMSG}1080${CEND}
Your Encryption Method: ${CMSG}aes-256-cfb${CEND}
"
}

if [ "${install_flag}" == 'y' -o "${ARG_NUM}" == '0' ]; then
  Def_parameter
  [ "${ss_option}" == '1' ] && Install_SS_libev
  [ "${ss_option}" == '2' ] && Install_SS_python
  Config_SS
  service shadowsocks start
  Print_User_SS
fi

if [ "${adduser_flag}" == 'y' ]; then
  Check_SS
  if [ "${ss_option}" == '2' ]; then
    AddUser_SS
    Iptables
    AddUser_Config_SS
    service shadowsocks restart
    Print_User_SS
  elif [ "${ss_option}" == '2' ]; then
    printf "
    Sorry, we have no plan to support multi port configuration. Actually you can use multiple instances instead. For example:
    ss-server -c /etc/shadowsocks/config1.json -f /var/run/shadowsocks-server/pid1
    ss-server -c /etc/shadowsocks/config2.json -f /var/run/shadowsocks-server/pid2
    "
  fi
fi

if [ "${uninstall_flag}" == 'y' ]; then
  Check_SS
  Uninstall_SS
fi
