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
[ ! -d "${db_install_dir}" ] && { echo "${CFAILURE}Database is not installed on your system! ${CEND}"; exit 1; }

showhelp() {
  echo "Usage: $0  command ...[parameters]....
  -h,  --help                  print this help.
  -q,  --quiet                 quiet operation.
  -f,  --force                 Lost Database Password? Forced reset password.
  -p,  --password [pass]       DB super password.
  "
}

New_dbrootpwd="`< /dev/urandom tr -dc A-Za-z0-9 | head -c8`"
TEMP=`getopt -o hqfp: --long help,quiet,force,password: -- "$@" 2>/dev/null`
[ $? != 0 ] && echo "${CWARNING}ERROR: unknown argument! ${CEND}" && showhelp && exit 1
eval set -- "${TEMP}"
while :; do
  [ -z "$1" ] && break;
  case "$1" in
    -h|--help)
      showhelp; exit 0
      ;;
    -q|--quiet)
      quiet_yn=y; shift 1
      ;;
    -f|--force)
      force_yn=y; shift 1
      ;;
    -p|--password)
      New_dbrootpwd=$2; shift 2
      password_flag=y
      ;;
    --)
      shift
      ;;
    *)
      echo "${CWARNING}ERROR: unknown argument! ${CEND}" && showhelp && exit 1
      ;;
  esac
done

Input_dbrootpwd() {
  while :; do echo
    read -p "Please input the root password of database: " New_dbrootpwd
    [ -n "`echo ${New_dbrootpwd} | grep '[+|&]'`" ] && { echo "${CWARNING}input error,not contain a plus sign (+) and &${CEND}"; continue; }
    (( ${#New_dbrootpwd} >= 5 )) && break || echo "${CWARNING}database root password least 5 characters! ${CEND}"
  done
}

Reset_Interaction_dbrootpwd() {
  ${db_install_dir}/bin/mysqladmin -uroot -p"${dbrootpwd}" password "${New_dbrootpwd}" -h localhost > /dev/null 2>&1
  status_Localhost=`echo $?`
  ${db_install_dir}/bin/mysqladmin -uroot -p"${dbrootpwd}" password "${New_dbrootpwd}" -h 127.0.0.1 > /dev/null 2>&1
  status_127=`echo $?`
  if [ ${status_Localhost} == '0' -a ${status_127} == '0' ]; then
    sed -i "s+^dbrootpwd.*+dbrootpwd='${New_dbrootpwd}'+" ./options.conf
    echo
    echo "Password reset succesfully! "
    echo "The new password: ${CMSG}${New_dbrootpwd}${CEND}"
    echo
  else
    echo "${CFAILURE}Reset Database root password failed! ${CEND}"
  fi
}

Reset_force_dbrootpwd() {
  DB_Ver="`${db_install_dir}/bin/mysql_config --version`"
  echo "${CMSG}Stopping MySQL...${CEND}"
  /etc/init.d/mysqld stop > /dev/null 2>&1
  while [ -n "`ps -ef | grep mysql | grep -v grep | awk '{print $2}'`" ]; do
    sleep 1
  done
  echo "${CMSG}skip grant tables...${CEND}"
  ${db_install_dir}/bin/mysqld_safe --skip-grant-tables > /dev/null 2>&1 &
  while [ -z "`ps -ef | grep 'mysqld ' | grep -v grep | awk '{print $2}'`" ]; do
    sleep 1
  done
  if echo "${DB_Ver}" | grep -Eqi '^8.0.|^5.7.|^10.2.'; then
    ${db_install_dir}/bin/mysql -uroot -hlocalhost << EOF
flush privileges;
alter user 'root'@'localhost' identified by "${New_dbrootpwd}";
alter user 'root'@'127.0.0.1' identified by "${New_dbrootpwd}";
EOF
  else
    ${db_install_dir}/bin/mysql -uroot -hlocalhost << EOF
update mysql.user set password = Password("${New_dbrootpwd}") where User = 'root';
EOF
  fi
  if [ $? -eq 0 ]; then
    killall mysqld
    while [ -n "`ps -ef | grep mysql | grep -v grep | awk '{print $2}'`" ]; do
      sleep 1
    done
    [ -n "`ps -ef | grep mysql | grep -v grep | awk '{print $2}'`" ] && ps -ef | grep mysql | grep -v grep | awk '{print $2}' | xargs kill -9 > /dev/null 2>&1
    /etc/init.d/mysqld start > /dev/null 2>&1
    sed -i "s+^dbrootpwd.*+dbrootpwd='${New_dbrootpwd}'+" ./options.conf
    echo
    echo "Password reset succesfully! "
    echo "The new password: ${CMSG}${New_dbrootpwd}${CEND}"
    echo
  fi
}

[ "${password_flag}" == 'y' ] && quiet_yn=y
if [ "${quiet_yn}" == 'y' ]; then
  if [ "${force_yn}" == 'y' ]; then
    Reset_force_dbrootpwd
  else
    sleep 2 && [ ! -e /tmp/mysql.sock ] && /etc/init.d/mysqld start
    Reset_Interaction_dbrootpwd
    [ $? -eq 0 ] && [ -n "`grep reset_db_root_password /etc/rc.local`" ] && sed -i '/reset_db_root_password/d' /etc/rc.d/rc.local > /dev/null 2>&1
  fi
else
  Input_dbrootpwd
  if [ "${force_yn}" == 'y' ]; then
    Reset_force_dbrootpwd
  else
    Reset_Interaction_dbrootpwd
  fi
fi
popd > /dev/null
