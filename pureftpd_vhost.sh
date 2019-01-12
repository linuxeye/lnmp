#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 7+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
clear
printf "
#######################################################################
#       OneinStack for CentOS/RedHat 6+ Debian 7+ and Ubuntu 12+      #
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
[ -z "`grep ^PureDB ${FTP_conf}`" ] && { echo "${CFAILURE}pure-ftpd is not own password database${CEND}" ; exit 1; }

ARG_NUM=$#
Show_Help() {
  echo
  echo "Usage: $0  command ...[parameters]....
  --help, -h                          Show this help message
  --useradd,--add                     Add username
  --usermod                           Modify directory
  --passwd                            Modify password
  --userdel,--delete                  Delete User
  --listalluser,--list                List all User
  --showuser                          List User details
  --username,-u     [ftp username]    Ftp username
  --password,-p     [ftp password]    Ftp password
  --directory,-d,-D [ftp directory]   Ftp home directory
  "
}

TEMP=`getopt -o hu:p:d:D: --long help,useradd,add,usermod,passwd,userdel,delete,listalluser,list,showuser,username:,password:,directory: -- "$@" 2>/dev/null`
[ $? != 0 ] && echo "${CWARNING}ERROR: unknown argument! ${CEND}" && Show_Help && exit 1
eval set -- "${TEMP}"
while :; do
  [ -z "$1" ] && break;
  case "$1" in
    -h|--help)
      Show_Help; exit 0
      ;;
    --add|--useradd)
      useradd_flag=y; shift 1
      ;;
    --usermod)
      usermod_flag=y; shift 1
      ;;
    --passwd)
      passwd_flag=y; shift 1
      ;;
    --delete|--userdel)
      userdel_flag=y; shift 1
      ;;
    --list|--listalluser)
      listalluser_flag=y; shift 1
      ;;
    --showuser)
      showuser_flag=y; shift 1
      ;;
    -u|--username)
      username_flag=y; User=$2; shift 2
      ;;
    -p|--password)
      password_flag=y; Password=$2; shift 2
      ;;
    -d|-D|--directory)
      directory_flag=y; Directory=$2; shift 2
      ;;
    --)
      shift
      ;;
    *)
      echo "${CWARNING}ERROR: unknown argument! ${CEND}" && Show_Help && exit 1
      ;;
  esac
done

USER() {
  while :; do
    if [ "${username_flag}" != 'y' ]; then
      echo
      read -e -p "Please input a username: " User
    fi
    if [ -z "${User}" ]; then
      echo "${CWARNING}username can't be NULL! ${CEND}"
    else
      break
    fi
  done
}

PASSWORD() {
  while :; do
    if [ "${password_flag}" != 'y' ]; then
      echo
      read -e -p "Please input the password: " Password
    fi
    [ -n "`echo ${Password} | grep '[+|&]'`" ] && { echo "${CWARNING}input error,not contain a plus sign (+) and &${CEND}"; continue; }
    if (( ${#Password} >= 5 )); then
      echo -e "${Password}\n${Password}" > ${FTP_tmp_passfile}
      break
    else
      echo "${CWARNING}Ftp password least 5 characters! ${CEND}"
    fi
  done
}

DIRECTORY() {
  while :; do
    if [ "${directory_flag}" != 'y' ]; then
      echo
      read -e -p "Please input the directory(Default directory: ${wwwroot_dir}): " Directory
    fi
    Directory=${Directory:-${wwwroot_dir}}
    if [ ! -d "${Directory}" ]; then
      echo "${CWARNING}The directory does not exist${CEND}"
    else
      break
    fi
  done
}

UserAdd() {
  USER
  [ -e "${Passwdfile}" ] && [ -n "`grep ^${User}: ${Passwdfile}`" ] && { echo "${CQUESTION}[${User}] is already existed! ${CEND}"; exit 1; }
  PASSWORD;DIRECTORY
  ${FTP_bin} useradd ${User} -f ${Passwdfile} -u ${run_user} -g ${run_user} -d ${Directory} -m < ${FTP_tmp_passfile}
  ${FTP_bin} mkdb ${Puredbfile} -f ${Passwdfile} > /dev/null 2>&1
  echo "#####################################"
  echo
  echo "[${User}] create successful! "
  echo
  echo "You user name is : ${CMSG}${User}${CEND}"
  echo "You Password is : ${CMSG}${Password}${CEND}"
  echo "You directory is : ${CMSG}${Directory}${CEND}"
  echo
}

UserMod() {
  USER
  [ -e "${Passwdfile}" ] && [ -z "`grep ^${User}: ${Passwdfile}`" ] && { echo "${CQUESTION}[${User}] was not existed! ${CEND}"; exit 1; }
  DIRECTORY
  ${FTP_bin} usermod ${User} -f ${Passwdfile} -d ${Directory} -m
  ${FTP_bin} mkdb ${Puredbfile} -f ${Passwdfile} > /dev/null 2>&1
  echo "#####################################"
  echo
  echo "[${User}] modify a successful! "
  echo
  echo "You user name is : ${CMSG}${User}${CEND}"
  echo "You new directory is : ${CMSG}${Directory}${CEND}"
  echo
}

UserPasswd() {
  USER
  [ -e "${Passwdfile}" ] && [ -z "`grep ^${User}: ${Passwdfile}`" ] && { echo "${CQUESTION}[${User}] was not existed! ${CEND}"; exit 1; }
  PASSWORD
  ${FTP_bin} passwd ${User} -f ${Passwdfile} -m < ${FTP_tmp_passfile}
  ${FTP_bin} mkdb ${Puredbfile} -f ${Passwdfile} > /dev/null 2>&1
  echo "#####################################"
  echo
  echo "[${User}] Password changed successfully! "
  echo
  echo "You user name is : ${CMSG}${User}${CEND}"
  echo "You new password is : ${CMSG}${Password}${CEND}"
  echo
}

UserDel() {
  if [ ! -e "${Passwdfile}" ]; then
    echo "${CQUESTION}User was not existed! ${CEND}"
  else
    ${FTP_bin} list
  fi

  USER
  [ -e "${Passwdfile}" ] && [ -z "`grep ^${User}: ${Passwdfile}`" ] && { echo "${CQUESTION}[${User}] was not existed! ${CEND}"; exit 1; }
  ${FTP_bin} userdel ${User} -f ${Passwdfile} -m
  ${FTP_bin} mkdb ${Puredbfile} -f ${Passwdfile} > /dev/null 2>&1
  echo
  echo "[${User}] have been deleted! "
}

ListAllUser() {
  if [ ! -e "${Passwdfile}" ]; then
    echo "${CQUESTION}User was not existed! ${CEND}"
  else
    ${FTP_bin} list
  fi
}

ShowUser() {
  USER
  [ -e "${Passwdfile}" ] && [ -z "`grep ^${User}: ${Passwdfile}`" ] && { echo "${CQUESTION}[${User}] was not existed! ${CEND}"; exit 1; }
  ${FTP_bin} show ${User}
}

Menu() {
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
    read -e -p "Please input the correct option: " Number
    if [[ ! ${Number} =~ ^[1-6,q]$ ]]; then
      echo "${CFAILURE}input error! Please only input 1~6 and q${CEND}"
    else
      case "${Number}" in
      1)
        UserAdd
        ;;
      2)
        UserMod
        ;;
      3)
        UserPasswd
        ;;
      4)
        UserDel
        ;;
      5)
        ListAllUser
        ;;
      6)
        ShowUser
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
  [ "${useradd_flag}" == 'y' ] && UserAdd
  [ "${usermod_flag}" == 'y' ] && UserMod
  [ "${passwd_flag}" == 'y' ] && UserPasswd
  [ "${userdel_flag}" == 'y' ] && UserDel
  [ "${listalluser_flag}" == 'y' ] && ListAllUser
  [ "${showuser_flag}" == 'y' ] && ShowUser
fi
