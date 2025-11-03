#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
#

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#######################################################################
#                    Upgrade Software versions                        #
#######################################################################
"
# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

current_dir=$(dirname "`readlink -f $0`")
pushd ${current_dir} > /dev/null
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
. ./include/upgrade_script.sh

# get the out ip country
OUTIP_STATE=$(./include/ois.${ARCH} ip_state)

Show_Help() {
  echo
  echo "Usage: $0  command ...[version]....
  --help, -h                  Show this help message
  --nginx        [version]    Upgrade Nginx
  --tengine      [version]    Upgrade Tengine
  --openresty    [version]    Upgrade OpenResty
  --apache       [version]    Upgrade Apache
  --tomcat       [version]    Upgrade Tomcat
  --db           [version]    Upgrade MySQL/MariaDB/Percona
  --php          [version]    Upgrade PHP
  --redis        [version]    Upgrade Redis
  --memcached    [version]    Upgrade Memcached
  --phpmyadmin   [version]    Upgrade phpMyAdmin
  --script                    Upgrade scripts latest
  --acme.sh                   Upgrade acme.sh latest
  "
}

ARG_NUM=$#
TEMP=`getopt -o h --long help,nginx:,tengine:,openresty:,apache:,tomcat:,db:,php:,redis:,memcached:,phpmyadmin:,script,acme.sh -- "$@" 2>/dev/null`
[ $? != 0 ] && echo "${CWARNING}ERROR: unknown argument! ${CEND}" && Show_Help && exit 1
eval set -- "${TEMP}"
while :; do
  [ -z "$1" ] && break;
  case "$1" in
    -h|--help)
      Show_Help; exit 0
      ;;
    --nginx)
      nginx_flag=y; NEW_nginx_ver=$2; shift 2
      ;;
    --tengine)
      tengine_flag=y; NEW_tengine_ver=$2; shift 2
      ;;
    --openresty)
      openresty_flag=y; NEW_openresy_ver=$2; shift 2
      ;;
    --apache)
      apache_flag=y; NEW_apache_ver=$2; shift 2
      ;;
    --tomcat)
      tomcat_flag=y; NEW_tomcat_ver=$2; shift 2
      ;;
    --db)
      db_flag=y; NEW_db_ver=$2; shift 2
      ;;
    --php)
      php_flag=y; NEW_php_ver=$2; shift 2
      ;;
    --redis)
      redis_flag=y; NEW_redis_ver=$2; shift 2
      ;;
    --memcached)
      memcached_flag=y; NEW_memcached_ver=$2; shift 2
      ;;
    --phpmyadmin)
      phpmyadmin_flag=y; NEW_phpmyadmin_ver=$2; shift 2
      ;;
    --script)
      NEW_Script_ver=latest; shift 1
      ;;
    --acme.sh)
      NEW_acme_ver=latest; shift 1
      ;;
    --)
      shift
      ;;
    *)
      echo "${CWARNING}ERROR: unknown argument! ${CEND}" && Show_Help && exit 1
      ;;
  esac
done

Menu() {
  while :; do
    printf "
What Are You Doing?
\t${CMSG} 1${CEND}. Upgrade Nginx/Tengine/OpenResty
\t${CMSG} 2${CEND}. Upgrade Apache
\t${CMSG} 3${CEND}. Upgrade Tomcat
\t${CMSG} 4${CEND}. Upgrade MySQL/MariaDB/Percona
\t${CMSG} 5${CEND}. Upgrade PHP
\t${CMSG} 6${CEND}. Upgrade Redis
\t${CMSG} 7${CEND}. Upgrade Memcached
\t${CMSG} 8${CEND}. Upgrade phpMyAdmin
\t${CMSG} 9${CEND}. Upgrade scripts latest
\t${CMSG}10${CEND}. Upgrade acme.sh latest
\t${CMSG} q${CEND}. Exit
"
    echo
    read -e -p "Please input the correct option: " Upgrade_flag
    if [[ ! "${Upgrade_flag}" =~ ^[1-9,q]$|^10$ ]]; then
      echo "${CWARNING}input error! Please only input 1~10 and q${CEND}"
    else
      case "${Upgrade_flag}" in
        1)
          [ -e "${nginx_install_dir}/sbin/nginx" ] && Upgrade_Nginx
          [ -e "${tengine_install_dir}/sbin/nginx" ] && Upgrade_Tengine
          [ -e "${openresty_install_dir}/nginx/sbin/nginx" ] && Upgrade_OpenResty
          ;;
        2)
          Upgrade_Apache
          ;;
        3)
          Upgrade_Tomcat
          ;;
        4)
          Upgrade_DB
          ;;
        5)
          Upgrade_PHP
          ;;
        6)
          Upgrade_Redis
          ;;
        7)
          Upgrade_Memcached
          ;;
        8)
          Upgrade_phpMyAdmin
          ;;
        9)
          Upgrade_Script
          ;;
        10)
          [ -e ~/.acme.sh/acme.sh ] && { ~/.acme.sh/acme.sh --force --upgrade; ~/.acme.sh/acme.sh --version; }
          ;;
        q)
          exit
          ;;
      esac
    fi
  done
}

if [ ${ARG_NUM} == 0 ]; then
  Menu
else
  [ "${nginx_flag}" == 'y' ] && Upgrade_Nginx
  [ "${tengine_flag}" == 'y' ] && Upgrade_Tengine
  [ "${openresty_flag}" == 'y' ] && Upgrade_OpenResty
  [ "${apache_flag}" == 'y' ] && Upgrade_Apache
  [ "${tomcat_flag}" == 'y' ] && Upgrade_Tomcat
  [ "${db_flag}" == 'y' ] && Upgrade_DB
  [ "${php_flag}" == 'y' ] && Upgrade_PHP
  [ "${redis_flag}" == 'y' ] && Upgrade_Redis
  [ "${memcached_flag}" == 'y' ] && Upgrade_Memcached
  [ "${phpmyadmin_flag}" == 'y' ] && Upgrade_phpMyAdmin
  [ "${NEW_Script_ver}" == 'latest' ] && Upgrade_Script
  [ "${NEW_acme_ver}" == 'latest' ] && [ -e ~/.acme.sh/acme.sh ] && { ~/.acme.sh/acme.sh --force --upgrade; ~/.acme.sh/acme.sh --version; }
fi
