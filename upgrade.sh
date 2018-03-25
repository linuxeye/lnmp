#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 7+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
clear
printf "
#######################################################################
#       OneinStack for CentOS/RadHat 6+ Debian 7+ and Ubuntu 12+      #
#              Upgrade Software versions for OneinStack               #
#       For more information please visit https://oneinstack.com      #
#######################################################################
"
# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

oneinstack_dir=$(dirname "`readlink -f $0`")
pushd ${oneinstack_dir} > /dev/null
. ./versions.txt
. ./options.conf
. ./include/color.sh
. ./include/check_os.sh
. ./include/check_dir.sh
. ./include/download.sh
. ./include/get_char.sh
. ./include/upgrade_web.sh
. ./include/upgrade_db.sh
. ./include/upgrade_php.sh
. ./include/upgrade_redis.sh
. ./include/upgrade_memcached.sh
. ./include/upgrade_phpmyadmin.sh
. ./include/upgrade_oneinstack.sh

# get the IP information
PUBLIC_IPADDR=`./include/get_public_ipaddr.py`
IPADDR_COUNTRY=`./include/get_ipaddr_state.py $PUBLIC_IPADDR | awk '{print $1}'`

Usage(){
  printf "
Usage: $0 [ ${CMSG}web${CEND} | ${CMSG}db${CEND} | ${CMSG}php${CEND} | ${CMSG}redis${CEND} | ${CMSG}memcached${CEND} | ${CMSG}phpmyadmin${CEND} | ${CMSG}oneinstack${CEND} | ${CMSG}acme.sh${CEND} ]
${CMSG}web${CEND}            --->Upgrade Nginx/Tengine/OpenResty/Apache
${CMSG}db${CEND}             --->Upgrade MySQL/MariaDB/Percona
${CMSG}php${CEND}            --->Upgrade PHP
${CMSG}redis${CEND}          --->Upgrade Redis
${CMSG}memcached${CEND}      --->Upgrade Memcached
${CMSG}phpmyadmin${CEND}     --->Upgrade phpMyAdmin
${CMSG}oneinstack${CEND}     --->Upgrade OneinStack
${CMSG}acme.sh${CEND}        --->Upgrade acme.sh

"
}

Menu(){
  while :; do
    printf "
What Are You Doing?
\t${CMSG}1${CEND}. Upgrade Nginx/Tengine/OpenResty/Apache
\t${CMSG}2${CEND}. Upgrade MySQL/MariaDB/Percona
\t${CMSG}3${CEND}. Upgrade PHP
\t${CMSG}4${CEND}. Upgrade Redis
\t${CMSG}5${CEND}. Upgrade Memcached
\t${CMSG}6${CEND}. Upgrade phpMyAdmin
\t${CMSG}7${CEND}. Upgrade OneinStack
\t${CMSG}8${CEND}. Upgrade acme.sh
\t${CMSG}q${CEND}. Exit
"
    echo
    read -p "Please input the correct option: " Upgrade_flag
    if [[ ! ${Upgrade_flag} =~ ^[1-8,q]$ ]]; then
      echo "${CWARNING}input error! Please only input 1~8 and q${CEND}"
    else
      case "${Upgrade_flag}" in
        1)
          if [ -e "$nginx_install_dir/sbin/nginx" ]; then
            Upgrade_Nginx
          elif [ -e "$tengine_install_dir/sbin/nginx" ]; then
            Upgrade_Tengine
          elif [ -e "$openresty_install_dir/nginx/sbin/nginx" ]; then
            Upgrade_OpenResty
          elif [ -e "${apache_install_dir}/conf/httpd.conf" ]; then
            Upgrade_Apache
          fi
          ;;
        2)
          Upgrade_DB
          ;;
        3)
          Upgrade_PHP
          ;;
        4)
          Upgrade_Redis
          ;;
        5)
          Upgrade_Memcached
          ;;
        6)
          Upgrade_phpMyAdmin
          ;;
        7)
          Upgrade_OneinStack
          ;;
        8)
          [ -e ~/.acme.sh/acme.sh ] && { ~/.acme.sh/acme.sh --upgrade; ~/.acme.sh/acme.sh --version; }
          ;;
        q)
          exit
          ;;
      esac
    fi
  done
}

if [ $# == 0 ]; then
  Menu
elif [ $# == 1 ]; then
  case $1 in
    web)
      if [ -e "$nginx_install_dir/sbin/nginx" ]; then
        Upgrade_Nginx
      elif [ -e "$tengine_install_dir/sbin/nginx" ]; then
        Upgrade_Tengine
      elif [ -e "$openresty_install_dir/nginx/sbin/nginx" ]; then
        Upgrade_OpenResty
      elif [ -e "${apache_install_dir}/conf/httpd.conf" ]; then
        Upgrade_Apache
      fi
      ;;
    db)
      Upgrade_DB
      ;;
    php)
      Upgrade_PHP
      ;;
    redis)
      Upgrade_Redis
      ;;
    memcached)
      Upgrade_Memcached
      ;;
    phpmyadmin)
      Upgrade_phpMyAdmin
      ;;
    oneinstack)
      Upgrade_OneinStack
      ;;
    acme.sh)
      [ -e ~/.acme.sh/acme.sh ] && { ~/.acme.sh/acme.sh --upgrade; ~/.acme.sh/acme.sh --version; }
      ;;
    *)
      Usage
      ;;
  esac
else
  Usage
fi
