#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

# Check if user is root
[ $(id -u) != "0" ] && { echo -e "\033[31mError: You must be root to run this script\033[0m"; exit 1; }
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#######################################################################
#    LNMP/LAMP/LANMP for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+    #
#   upgrade Nginx/Tengine,PHP,Redis,phpMyAdmin for LNMP/LAMP/LANMP    #
# For more information please visit http://blog.linuxeye.com/31.html  #
#######################################################################
"
. ./options.conf
. ./functions/upgrade_web.sh
. ./functions/upgrade_php.sh
. ./functions/upgrade_redis.sh
. ./functions/upgrade_phpmyadmin.sh

get_char()
{
SAVEDSTTY=`stty -g`
stty -echo
stty cbreak
dd if=/dev/tty bs=1 count=1 2> /dev/null
stty -raw
stty echo
stty $SAVEDSTTY
}

Usage(){
echo
echo -e $"\033[035mUsage:\033[0m \033[032m $0 [ web | php | redis | phpmyadmin ]\033[0m"
echo -e "-------------------------------------------------------"
echo -e "\033[032mweb\033[0m             --->Upgrade Nginx/Tengine"
echo -e "\033[032mphp\033[0m             --->Upgrade PHP"
echo -e "\033[032mredis\033[0m           --->Upgrade Redis"
echo -e "\033[032mphpmyadmin\033[0m      --->Upgrade phpMyAdmin"
echo
}

Menu(){
while :
do
        echo
        echo -e "What Are You Doing?
\t\033[32m1\033[0m. Upgrade Nginx/Tengine
\t\033[32m2\033[0m. Upgrade PHP
\t\033[32m3\033[0m. Upgrade Redis
\t\033[32m4\033[0m. Upgrade phpMyAdmin
\t\033[32mq\033[0m. Exit"
        read -p "Please input the correct option: " Number
        if [ "$Number" != '1' -a "$Number" != '2' -a "$Number" != '3' -a "$Number" != '4' -a "$Number" != 'q' ];then
                echo -e "\033[31minput error! Please only input 1 ~ 4 and q\033[0m"
        else
        	case "$Number" in
	        1)
	        if [ ! -e "$web_install_dir/sbin/dso_tool" ];then
	                Upgrade_Nginx
	        elif [ -e "$web_install_dir/sbin/dso_tool" ];then
	                Upgrade_Tengine
	        fi
	        ;;
	        2)
		Upgrade_PHP
	        ;;
	        3)
		Upgrade_Redis
	        ;;
	        4)
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
	if [ ! -e "$web_install_dir/sbin/dso_tool" ];then
	        Upgrade_Nginx
	elif [ -e "$web_install_dir/sbin/dso_tool" ];then
	        Upgrade_Tengine
	fi
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
