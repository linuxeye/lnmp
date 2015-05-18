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
#                 FTP virtual user account management                 #
# For more information please visit http://blog.linuxeye.com/31.html  #
#######################################################################
"

. ./options.conf
[ ! -d "$pureftpd_install_dir" ] && { echo -e "\033[31mThe ftp server does not exist! \033[0m"; exit 1; }

FTP_conf=$pureftpd_install_dir/etc/pure-ftpd.conf
FTP_tmp_passfile=$pureftpd_install_dir/etc/pureftpd_psss.tmp
Puredbfile=$pureftpd_install_dir/etc/pureftpd.pdb
Passwdfile=$pureftpd_install_dir/etc/pureftpd.passwd
FTP_bin=$pureftpd_install_dir/bin/pure-pw 
[ -z "`grep ^PureDB $FTP_conf`" ] && { echo -e "\033[31mpure-ftpd is not own password database\033[0m" ; exit 1; }

USER() {
while :
do
        echo
        read -p "Please input a username: " User
        if [ -z "$User" ]; then
                echo -e "\033[31musername can't be NULL! \033[0m"
        else
                break
        fi
done
}

PASSWORD() {
while :
do
        echo
        read -p "Please input the password: " Password 
        [ -n "`echo $Password | grep '[+|&]'`" ] && { echo -e "\033[31minput error,not contain a plus sign (+) and &\033[0m"; continue; }
        if (( ${#Password} >= 5 ));then
		echo -e "${Password}\n$Password" > $FTP_tmp_passfile
                break
        else
                echo -e "\033[31mFtp password least 5 characters! \033[0m"
        fi
done
}

DIRECTORY() {
while :
do
echo
	read -p "Please input the directory(Default directory: $home_dir): " Directory 
	if [ -z "$Directory" ]; then
	        Directory="$home_dir"
	fi
	if [ ! -d "$Directory" ];then
		echo -e "\033[31mThe directory does not exist\033[0m"
	else
		break
	fi
done
}

while :
do
	echo
	echo -e "What Are You Doing? 
\t\033[32m1\033[0m. UserAdd
\t\033[32m2\033[0m. UserMod
\t\033[32m3\033[0m. UserPasswd
\t\033[32m4\033[0m. UserDel
\t\033[32m5\033[0m. ListAllUser
\t\033[32m6\033[0m. ShowUser
\t\033[32mq\033[0m. Exit"
	read -p "Please input the correct option: " Number 
	if [ "$Number" != '1' -a "$Number" != '2' -a "$Number" != '3' -a "$Number" != '4' -a "$Number" != '5' -a "$Number" != '6' -a "$Number" != 'q' ];then
		echo -e "\033[31minput error! Please only input 1 ~ 8 and q\033[0m"
	else
	case "$Number" in
	1)
		USER
		[ -e "$Passwdfile" ] && [ -n "`grep ^${User}: $Passwdfile`" ] && { echo -e "\033[31m[$User] is already existed! \033[0m"; continue; } 
		PASSWORD;DIRECTORY
		$FTP_bin useradd $User -f $Passwdfile -u $run_user -g $run_user -d $Directory -m < $FTP_tmp_passfile
		$FTP_bin -f $Passwdfile -F $Puredbfile > /dev/null 2>&1 
                echo "#####################################"
		echo
                echo "[$User] create successful! "
		echo
                echo "You user name is : $User"
                echo "You Password is : $Password"
                echo "You directory is : $Directory"
		echo

		;;
	2)
		USER;DIRECTORY
		$FTP_bin usermod $User -f $Passwdfile -d $Directory -m 
		$FTP_bin -f $Passwdfile -F $Puredbfile > /dev/null 2>&1 
                echo "#####################################"
		echo
		echo "[$User] modify a successful! "
		echo
		echo "You user name is : $User"
		echo "You new directory is : $Directory"
		echo
                ;;
        3)
		USER
                [ -e "$Passwdfile" ] && [ -z "`grep ^${User}: $Passwdfile`" ] && { echo -e "\033[31m[$User] is not existed! \033[0m"; continue; }
		PASSWORD
		$FTP_bin passwd $User -f $Passwdfile -m < $FTP_tmp_passfile
		$FTP_bin -f $Passwdfile -F $Puredbfile > /dev/null 2>&1 
		echo "#####################################"
		echo
		echo "[$User] Password changed successfully! "
		echo
		echo "You user name is : $User"
		echo "You new password is : $Password"
		echo
                ;;
        4)
		if [ ! -e "$Passwdfile" ];then
                        echo -e "\033[31mUser is not existed\033[0m"
                else
                        $FTP_bin list
                fi

		USER
		[ -e "$Passwdfile" ] && [ -z "`grep ^${User}: $Passwdfile`" ] && { echo -e "\033[31m[$User] is not existed! \033[0m"; continue; } 
		$FTP_bin userdel $User -f $Passwdfile -m
		$FTP_bin -f $Passwdfile -F $Puredbfile > /dev/null 2>&1
		echo
		echo "[$User] have been deleted! "
                ;;
        5)
		if [ ! -e "$Passwdfile" ];then
			echo -e "\033[31mUser is not existed\033[0m"
		else
			$FTP_bin list
		fi
                ;;
        6)
		USER
		[ -e "$Passwdfile" ] && [ -z "`grep ^${User}: $Passwdfile`" ] && { echo -e "\033[31m[$User] is not existed! \033[0m"; continue; } 
		$FTP_bin show $User
                ;;
	9)
		exit
		;;
        q)
                exit
                ;;
	esac
	fi
done
