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
#                 FTP virtual user account management                 #
#       For more information please visit https://oneinstack.com      #
#######################################################################
"
# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

oneinstack_dir=$(dirname "`readlink -f $0`")
pushd ${oneinstack_dir} > /dev/null
. ./options.conf
. ./include/color.sh

[ ! -d "${pureftpd_install_dir}" ] && { echo "${CFAILURE}FTP server does not exist! ${CEND}"; exit 1; }

FTP_conf=${pureftpd_install_dir}/etc/pure-ftpd.conf
FTP_tmp_passfile=${pureftpd_install_dir}/etc/pureftpd_psss.tmp
Puredbfile=${pureftpd_install_dir}/etc/pureftpd.pdb
Passwdfile=${pureftpd_install_dir}/etc/pureftpd.passwd
FTP_bin=${pureftpd_install_dir}/bin/pure-pw
[ -z "`grep ^PureDB $FTP_conf`" ] && { echo "${CFAILURE}pure-ftpd is not own password database${CEND}" ; exit 1; }

USER() {
while :; do echo
  read -p "Please input a username: " User
  if [ -z "$User" ]; then
    echo "${CWARNING}username can't be NULL! ${CEND}"
  else
    break
  fi
done
}

PASSWORD() {
while :; do echo
  read -p "Please input the password: " Password
  [ -n "`echo $Password | grep '[+|&]'`" ] && { echo "${CWARNING}input error,not contain a plus sign (+) and &${CEND}"; continue; }
  if (( ${#Password} >= 5 ));then
    echo -e "${Password}\n$Password" > $FTP_tmp_passfile
    break
  else
    echo "${CWARNING}Ftp password least 5 characters! ${CEND}"
  fi
done
}

DIRECTORY() {
while :; do echo
  read -p "Please input the directory(Default directory: ${wwwroot_dir}): " Directory
  if [ -z "$Directory" ]; then
    Directory="${wwwroot_dir}"
  fi
  if [ ! -d "$Directory" ]; then
    echo "${CWARNING}The directory does not exist${CEND}"
  else
    break
  fi
done
}

while :; do
  printf "
What Are You Doing?
\t${CMSG}1${CEND}. UserAdd
\t${CMSG}2${CEND}. UserMod
\t${CMSG}3${CEND}. UserPasswd
\t${CMSG}4${CEND}. UserDel
\t${CMSG}5${CEND}. ListAllUser
\t${CMSG}6${CEND}. ShowUser
\t${CMSG}q${CEND}. Exit
"
  read -p "Please input the correct option: " Number
  if [[ ! $Number =~ ^[1-6,q]$ ]]; then
    echo "${CFAILURE}input error! Please only input 1~6 and q${CEND}"
  else
    case "$Number" in
    1)
      USER
      [ -e "$Passwdfile" ] && [ -n "`grep ^${User}: $Passwdfile`" ] && { echo "${CQUESTION}[$User] is already existed! ${CEND}"; continue; }
      PASSWORD;DIRECTORY
      $FTP_bin useradd $User -f $Passwdfile -u $run_user -g $run_user -d $Directory -m < $FTP_tmp_passfile
      $FTP_bin mkdb $Puredbfile -f $Passwdfile > /dev/null 2>&1
      echo "#####################################"
      echo
      echo "[$User] create successful! "
      echo
      echo "You user name is : ${CMSG}$User${CEND}"
      echo "You Password is : ${CMSG}$Password${CEND}"
      echo "You directory is : ${CMSG}$Directory${CEND}"
      echo
      ;;
    2)
      USER
      [ -e "$Passwdfile" ] && [ -z "`grep ^${User}: $Passwdfile`" ] && { echo "${CQUESTION}[$User] was not existed! ${CEND}"; continue; }
      DIRECTORY
      $FTP_bin usermod $User -f $Passwdfile -d $Directory -m
      $FTP_bin mkdb $Puredbfile -f $Passwdfile > /dev/null 2>&1
      echo "#####################################"
      echo
      echo "[$User] modify a successful! "
      echo
      echo "You user name is : ${CMSG}$User${CEND}"
      echo "You new directory is : ${CMSG}$Directory${CEND}"
      echo
      ;;
    3)
      USER
      [ -e "$Passwdfile" ] && [ -z "`grep ^${User}: $Passwdfile`" ] && { echo "${CQUESTION}[$User] was not existed! ${CEND}"; continue; }
      PASSWORD
      $FTP_bin passwd $User -f $Passwdfile -m < $FTP_tmp_passfile
      $FTP_bin mkdb $Puredbfile -f $Passwdfile > /dev/null 2>&1
      echo "#####################################"
      echo
      echo "[$User] Password changed successfully! "
      echo
      echo "You user name is : ${CMSG}$User${CEND}"
      echo "You new password is : ${CMSG}$Password${CEND}"
      echo
      ;;
    4)
      if [ ! -e "$Passwdfile" ]; then
        echo "${CQUESTION}User was not existed! ${CEND}"
      else
        $FTP_bin list
      fi

      USER
      [ -e "$Passwdfile" ] && [ -z "`grep ^${User}: $Passwdfile`" ] && { echo "${CQUESTION}[$User] was not existed! ${CEND}"; continue; }
      $FTP_bin userdel $User -f $Passwdfile -m
      $FTP_bin mkdb $Puredbfile -f $Passwdfile > /dev/null 2>&1
      echo
      echo "[$User] have been deleted! "
      ;;
    5)
      if [ ! -e "$Passwdfile" ]; then
        echo "${CQUESTION}User was not existed! ${CEND}"
      else
        $FTP_bin list
      fi
      ;;
    6)
      USER
      [ -e "$Passwdfile" ] && [ -z "`grep ^${User}: $Passwdfile`" ] && { echo "${CQUESTION}[$User] was not existed! ${CEND}"; continue; }
      $FTP_bin show $User
      ;;
    q)
      exit
      ;;
    esac
  fi
done
