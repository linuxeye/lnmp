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
#              Reset Database root password for OneinStack            #
#       For more information please visit https://oneinstack.com      #
#######################################################################
"
oneinstack_dir=$(dirname "`readlink -f $0`")
pushd ${oneinstack_dir} > /dev/null
. ./options.conf
. ./include/color.sh
. ./include/check_dir.sh

Input_db_root_password() {
  [ ! -d "${db_install_dir}" ] && { echo "${CFAILURE}Database is not installed on your system! ${CEND}"; exit 1; }
  while :; do echo
    read -p "Please input the root password of database: " New_dbrootpwd
    [ -n "`echo $New_dbrootpwd | grep '[+|&]'`" ] && { echo "${CWARNING}input error,not contain a plus sign (+) and &${CEND}"; continue; }
    (( ${#New_dbrootpwd} >= 5 )) && break || echo "${CWARNING}database root password least 5 characters! ${CEND}"
  done
}

Reset_db_root_password() {
  ${db_install_dir}/bin/mysqladmin -uroot -p"$dbrootpwd" password "$New_dbrootpwd" -h localhost > /dev/null 2>&1
  status_Localhost=`echo $?`
  ${db_install_dir}/bin/mysqladmin -uroot -p"$dbrootpwd" password "$New_dbrootpwd" -h 127.0.0.1 > /dev/null 2>&1
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

if [ "$1" == 'quiet' ]; then
  New_dbrootpwd="`< /dev/urandom tr -dc A-Za-z0-9 | head -c8`"
  sleep 2 && [ ! -e /tmp/mysql.sock ] && /etc/init.d/mysqld start
  Reset_db_root_password
  [ $? -eq 0 ] && sed -i '/reset_db_root_password/d' /etc/rc.d/rc.local
else
  Input_db_root_password
  Reset_db_root_password
fi
popd > /dev/null
