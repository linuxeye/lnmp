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
#              Reset Database root password for OneinStack            #
#       For more information please visit http://oneinstack.com       #
#######################################################################
"

. ./options.conf
. ./include/color.sh
. ./include/check_db.sh

# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; } 

Reset_db_root_password()
{
[ ! -d "$db_install_dir" ] && { echo "${CFAILURE}The Database is not installed on your system! ${CEND}"; exit 1; }
while :
do
    echo
    read -p "Please input the root password of database: " New_dbrootpwd
    [ -n "`echo $New_dbrootpwd | grep '[+|&]'`" ] && { echo "${CWARNING}input error,not contain a plus sign (+) and &${CEND}"; continue; }
    (( ${#New_dbrootpwd} >= 5 )) && break || echo "${CWARNING}database root password least 5 characters! ${CEND}"
done

$db_install_dir/bin/mysqladmin -uroot -p"$dbrootpwd" password "$New_dbrootpwd" -h localhost > /dev/null 2>&1
status_Localhost=`echo $?`
$db_install_dir/bin/mysqladmin -uroot -p"$dbrootpwd" password "$New_dbrootpwd" -h 127.0.0.1 > /dev/null 2>&1
status_127=`echo $?`
if [ $status_Localhost == '0' -a $status_127 == '0' ]; then
    sed -i "s+^dbrootpwd.*+dbrootpwd='$New_dbrootpwd'+" ./options.conf
    echo
    echo "Password reset succesfully! "
    echo "The new password: ${CMSG}${New_dbrootpwd}${CEND}"
    echo
else
	echo "${CFAILURE}Reset Database root password failed! ${CEND}"
fi
}
Reset_db_root_password
