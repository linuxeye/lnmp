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
#                  Reset Database root password                       #
# For more information please visit http://blog.linuxeye.com/31.html  #
#######################################################################
"
. ./options.conf

Reset_db_root_password()
{
[ ! -d "$db_install_dir" ] && echo -e "\033[31mThe Database is not installed on your system!\033[0m " && exit 1
while :
do
	echo
        read -p "Please input the root password of database: " New_dbrootpwd
        [ -n "`echo $New_dbrootpwd | grep '[+|&]'`" ] && { echo -e "\033[31minput error,not contain a plus sign (+) and & \033[0m"; continue; }
        (( ${#New_dbrootpwd} >= 5 )) && break || echo -e "\033[31mdatabase root password least 5 characters! \033[0m"
done
$db_install_dir/bin/mysqladmin -uroot -p"$dbrootpwd" password "$New_dbrootpwd" -h localhost > /dev/null 2>&1
status_Localhost=`echo $?`
$db_install_dir/bin/mysqladmin -uroot -p"$dbrootpwd" password "$New_dbrootpwd" -h 127.0.0.1 > /dev/null 2>&1
status_127=`echo $?`
if [ $status_Localhost == '0' -a $status_127 == '0' ]; then
	sed -i "s+^dbrootpwd.*+dbrootpwd='$New_dbrootpwd'+" ./options.conf
	echo
	echo "Password reset succesfully! "
	echo -e "The new password: \033[32m${New_dbrootpwd}\033[0m"
	echo
else
	echo "Reset Database root password failed!"
fi
}
Reset_db_root_password
