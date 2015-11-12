#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       http://oneinstack.com
#       https://github.com/lj2007331/oneinstack

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#######################################################################
#       OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+      #
#       upgrade Web,Database,PHP,Redis,phpMyAdmin for OneinStack      # 
#       For more information please visit http://oneinstack.com       #
#######################################################################
"
# get pwd
sed -i "s@^oneinstack_dir.*@oneinstack_dir=`pwd`@" ./options.conf

. ./options.conf
. ./include/color.sh
. ./include/check_os.sh
. ./include/check_db.sh
. ./include/download.sh
. ./include/get_char.sh
. ./include/upgrade_web.sh
. ./include/upgrade_db.sh
. ./include/upgrade_php.sh
. ./include/upgrade_redis.sh
. ./include/upgrade_phpmyadmin.sh

# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; } 

# get the IP information 
PUBLIC_IPADDR=`./include/get_public_ipaddr.py`
[ "`./include/get_ipaddr_state.py $PUBLIC_IPADDR`" == '\u4e2d\u56fd' ] && IPADDR_STATE=CN

Usage(){
printf "
Usage: $0 [ ${CMSG}web${CEND} | ${CMSG}db${CEND} | ${CMSG}php${CEND} | ${CMSG}redis${CEND} | ${CMSG}phpmyadmin${CEND} ]
${CMSG}web${CEND}            --->Upgrade Nginx/Tengine
${CMSG}db${CEND}             --->Upgrade MySQL/MariaDB/Percona
${CMSG}php${CEND}            --->Upgrade PHP
${CMSG}redis${CEND}          --->Upgrade Redis
${CMSG}phpmyadmin${CEND}     --->Upgrade phpMyAdmin

"
}

Menu(){
while :
do
    printf "
What Are You Doing?
\t${CMSG}1${CEND}. Upgrade Nginx/Tengine
\t${CMSG}2${CEND}. Upgrade MySQL/MariaDB/Percona
\t${CMSG}3${CEND}. Upgrade PHP
\t${CMSG}4${CEND}. Upgrade Redis
\t${CMSG}5${CEND}. Upgrade phpMyAdmin
\t${CMSG}q${CEND}. Exit
"
    echo
    read -p "Please input the correct option: " Number
    if [[ ! $Number =~ ^[1-5,q]$ ]];then
        echo "${CWARNING}input error! Please only input 1,2,3,4,5 and q${CEND}"
    else
        case "$Number" in
        1)
            if [ -e "$nginx_install_dir/sbin/nginx" ];then
                Upgrade_Nginx
            elif [ -e "$tengine_install_dir/sbin/nginx" ];then
                Upgrade_Tengine
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
            Upgrade_phpMyAdmin
            ;;

        q)
            exit
            ;;
        esac
    fi
done
}

if [ $# == 0 ];then
    Menu
elif [ $# == 1 ];then
    case $1 in
    web)
        if [ -e "$nginx_install_dir/sbin/nginx" ];then
            Upgrade_Nginx
        elif [ -e "$tengine_install_dir/sbin/nginx" ];then
            Upgrade_Tengine
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
    
    phpmyadmin)
        Upgrade_phpMyAdmin
        ;;
    
    *)
        Usage
        ;;
    esac
else
    Usage
fi
