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
#                         Uninstall OneinStack                        #
#       For more information please visit https://oneinstack.com      #
#######################################################################
"
# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

oneinstack_dir=$(dirname "`readlink -f $0`")
pushd ${oneinstack_dir} > /dev/null
. ./options.conf
. ./include/color.sh
. ./include/get_char.sh
. ./include/check_dir.sh

Usage(){
  printf "
Usage: $0 [  ${CMSG}all${CEND} | ${CMSG}web${CEND} | ${CMSG}mysql${CEND} | ${CMSG}postgresql${CEND} | ${CMSG}mongodb${CEND} | ${CMSG}php${CEND} | ${CMSG}hhvm${CEND} | ${CMSG}pureftpd${CEND} | ${CMSG}redis${CEND} | ${CMSG}memcached${CEND} ]
${CMSG}all${CEND}            --->Uninstall All
${CMSG}web${CEND}            --->Uninstall Nginx/Tengine/Apache/Tomcat
${CMSG}mysql${CEND}          --->Uninstall MySQL/MariaDB/Percona/AliSQL
${CMSG}postgresql${CEND}     --->Uninstall PostgreSQL
${CMSG}mongodb${CEND}        --->Uninstall MongoDB
${CMSG}php${CEND}            --->Uninstall PHP
${CMSG}hhvm${CEND}           --->Uninstall HHVM
${CMSG}pureftpd${CEND}       --->Uninstall PureFtpd
${CMSG}redis${CEND}          --->Uninstall Redis
${CMSG}memcached${CEND}      --->Uninstall Memcached

"
}

Uninstall_status() {
  while :; do echo
    read -p "Do you want to uninstall? [y/n]: " uninstall_yn
    echo
    if [[ ! ${uninstall_yn} =~ ^[y,n]$ ]]; then
      echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
      break
    fi
  done
}

Print_Warn() {
  echo
  echo "${CWARNING}You will uninstall OneinStack, Please backup your configure files and DB data! ${CEND}"
}

Print_web() {
  [ -d "${nginx_install_dir}" ] && echo "${nginx_install_dir}"
  [ -d "${tengine_install_dir}" ] && echo "${tengine_install_dir}"
  [ -d "${openresty_install_dir}" ] && echo "${openresty_install_dir}"
  [ -e "/etc/init.d/nginx" ] && echo '/etc/init.d/nginx'
  [ -e "/etc/logrotate.d/nginx" ] && echo '/etc/logrotate.d/nginx'

  [ -d "${apache_install_dir}" ] && echo "${apache_install_dir}"
  [ -e "/etc/init.d/httpd" ] && echo "/etc/init.d/httpd"
  [ -e "/etc/logrotate.d/apache" ] && echo "/etc/logrotate.d/apache"

  [ -d "${tomcat_install_dir}" ] && echo "${tomcat_install_dir}"
  [ -e "/etc/init.d/tomcat" ] && echo "/etc/init.d/tomcat"
  [ -e "/etc/logrotate.d/tomcat" ] && echo "/etc/logrotate.d/tomcat"
  [ -d "/usr/java" ] && echo '/usr/java'
  [ -d "/usr/local/apr" ] && echo '/usr/local/apr'
}

Uninstall_Web() {
  [ -d "${nginx_install_dir}" ] && { killall nginx > /dev/null 2>&1; rm -rf ${nginx_install_dir} /etc/init.d/nginx /etc/logrotate.d/nginx; sed -i "s@${nginx_install_dir}/sbin:@@" /etc/profile; }
  [ -d "${tengine_install_dir}" ] && { killall nginx > /dev/null 2>&1; rm -rf ${tengine_install_dir} /etc/init.d/nginx /etc/logrotate.d/nginx; sed -i "s@${tengine_install_dir}/sbin:@@" /etc/profile; }
  [ -d "${openresty_install_dir}" ] && { killall nginx > /dev/null 2>&1; rm -rf ${openresty_install_dir} /etc/init.d/nginx /etc/logrotate.d/nginx; sed -i "s@${openresty_install_dir}/nginx/sbin:@@" /etc/profile; }
  [ -d "${apache_install_dir}" ] && { service httpd stop > /dev/null 2>&1; rm -rf ${apache_install_dir} /etc/init.d/httpd /etc/logrotate.d/apache; sed -i "s@${apache_install_dir}/bin:@@" /etc/profile; }
  [ -d "${tomcat_install_dir}" ] && { killall java > /dev/null 2>&1; chmod +x /etc/logrotate.d/tomcat; rm -rf ${tomcat_install_dir} /etc/init.d/tomcat /etc/logrotate.d/tomcat /usr/local/apr; }
  [ -d "/usr/java" ] && { rm -rf /usr/java; sed -i '/export JAVA_HOME=/d' /etc/profile; sed -i '/export CLASSPATH=/d' /etc/profile; sed -i 's@\$JAVA_HOME/bin:@@' /etc/profile; }
  [ -e "${wwwroot_dir}" ] && /bin/mv ${wwwroot_dir}{,$(date +%Y%m%d%H)}
  sed -i 's@^website_name=.*@website_name=@' ./options.conf
  sed -i 's@^local_bankup_yn=.*@local_bankup_yn=y@' ./options.conf
  sed -i 's@^remote_bankup_yn=.*@remote_bankup_yn=n@' ./options.conf
  echo "${CMSG}Web uninstall completed! ${CEND}"
}

Print_MySQL() {
  [ -e "${db_install_dir}" ] && echo "${db_install_dir}"
  [ -e "/etc/init.d/mysqld" ] && echo "/etc/init.d/mysqld"
  [ -e "/etc/my.cnf" ] && echo "/etc/my.cnf"
}

Print_PostgreSQL() {
  [ -e "${pgsql_install_dir}" ] && echo "${pgsql_install_dir}"
  [ -e "/etc/init.d/postgresql" ] && echo "/etc/init.d/postgresql"
}

Print_MongoDB() {
  [ -e "${mongo_install_dir}" ] && echo "${mongo_install_dir}"
  [ -e "/etc/init.d/mongod" ] && echo "/etc/init.d/mongod"
  [ -e "/etc/mongod.conf" ] && echo "/etc/mongod.conf"
}

Uninstall_MySQL() {
  # uninstall mysql,mariadb,percona,alisql
  if [ -d "${db_install_dir}/support-files" ]; then
    service mysqld stop > /dev/null 2>&1
    rm -rf ${db_install_dir} /etc/init.d/mysqld /etc/my.cnf /etc/ld.so.conf.d/{mysql,mariadb,percona,alisql}*.conf
    id -u mysql >/dev/null 2>&1 ; [ $? -eq 0 ] && userdel mysql
    [ -e "${db_data_dir}" ] && /bin/mv ${db_data_dir}{,$(date +%Y%m%d%H)}
    sed -i 's@^dbrootpwd=.*@dbrootpwd=@' ./options.conf
    sed -i "s@${db_install_dir}/bin:@@" /etc/profile
    echo "${CMSG}MySQL uninstall completed! ${CEND}"
  else
    echo "${CWARNING}MySQL already uninstalled! ${CEND}"
  fi
}

Uninstall_PostgreSQL() {
  # uninstall postgresql
  if [ -e "${pgsql_install_dir}/bin/psql" ]; then
    service postgresql stop > /dev/null 2>&1
    rm -rf ${pgsql_install_dir} /etc/init.d/postgresql
    [ -e "${php_install_dir}/etc/php.d/07-pgsql.ini" ] && rm -rf ${php_install_dir}/etc/php.d/07-pgsql.ini
    id -u postgres >/dev/null 2>&1 ; [ $? -eq 0 ] && userdel postgres
    [ -e "${pgsql_data_dir}" ] && /bin/mv ${pgsql_data_dir}{,$(date +%Y%m%d%H)}
    sed -i 's@^dbpostgrespwd=.*@dbpostgrespwd=@' ./options.conf
    sed -i "s@${pgsql_install_dir}/bin:@@" /etc/profile
    echo "${CMSG}PostgreSQL uninstall completed! ${CEND}"
  else
    echo "${CWARNING}PostgreSQL already uninstalled! ${CEND}"
  fi
}

Uninstall_MongoDB() {
  # uninstall mongodb
  if [ -e "${mongo_install_dir}/bin/mongo" ]; then
    service mongod stop > /dev/null 2>&1
    rm -rf ${mongo_install_dir} /etc/mongod.conf /etc/init.d/mongod /tmp/mongo*.sock
    [ -e "${php_install_dir}/etc/php.d/07-mongo.ini" ] && rm -rf ${php_install_dir}/etc/php.d/07-mongo.ini
    [ -e "${php_install_dir}/etc/php.d/07-mongodb.ini" ] && rm -rf ${php_install_dir}/etc/php.d/07-mongodb.ini
    id -u mongod > /dev/null 2>&1 ; [ $? -eq 0 ] && userdel mongod
    [ -e "${mongo_data_dir}" ] && /bin/mv ${mongo_data_dir}{,$(date +%Y%m%d%H)}
    sed -i 's@^dbmongopwd=.*@dbmongopwd=@' ./options.conf
    sed -i "s@${mongo_install_dir}/bin:@@" /etc/profile
    echo "${CMSG}MongoDB uninstall completed! ${CEND}"
  else
    echo "${CWARNING}MongoDB already uninstalled! ${CEND}"
  fi
}

Print_PHP() {
  [ -e "${php_install_dir}" ] && echo "${php_install_dir}"
  [ -e "/etc/init.d/php-fpm" ] && echo "/etc/init.d/php-fpm"
  [ -e "${imagick_install_dir}" ] && echo "${imagick_install_dir}"
  [ -e "${gmagick_install_dir}" ] && echo "${gmagick_install_dir}"
  [ -e "${curl_install_dir}" ] && echo "${curl_install_dir}"
}

Uninstall_PHP() {
  [ -e "${php_install_dir}/bin/phpize" -a -e "${php_install_dir}/etc/php-fpm.conf" ] && { service php-fpm stop > /dev/null 2>&1; rm -rf ${php_install_dir} /etc/init.d/php-fpm; }
  [ -e "${php_install_dir}/bin/phpize" -a ! -e "${php_install_dir}/etc/php-fpm.conf" ] && rm -rf ${php_install_dir}
  [ -e "${imagick_install_dir}" ] && rm -rf ${imagick_install_dir}
  [ -e "${gmagick_install_dir}" ] && rm -rf ${gmagick_install_dir}
  [ -e "${curl_install_dir}" ] && rm -rf "${curl_install_dir}"
  sed -i "s@${php_install_dir}/bin:@@" /etc/profile
  echo "${CMSG}PHP uninstall completed! ${CEND}"
}

Print_HHVM() {
  [ -e "/usr/bin/hhvm" ] && echo "/usr/bin/hhvm"
  [ -e "/etc/hhvm" ] && echo "/etc/hhvm"
  [ -e "/var/log/hhvm" ] && echo "/var/log/hhvm"
  [ -e "/etc/supervisord.conf" ] && echo "/etc/supervisord.conf"
  [ -e "/etc/init.d/supervisord" ] && echo "/etc/init.d/supervisord"
}

Uninstall_HHVM() {
  [ -e "/etc/init.d/supervisord" ] && { service supervisord stop > /dev/null 2>&1; rm -rf /etc/supervisord.conf /etc/init.d/supervisord; }
  [ -e "/usr/bin/hhvm" ] && { rpm -e hhvm; rm -rf /etc/hhvm /var/log/hhvm /usr/bin/hhvm; }
  echo "${CMSG}HHVM uninstall completed! ${CEND}"
}

Print_PureFtpd() {
  [ -e "${pureftpd_install_dir}" ] && echo "${pureftpd_install_dir}"
  [ -e "/etc/init.d/pureftpd" ] && echo "/etc/init.d/pureftpd"
}

Uninstall_PureFtpd() {
  [ -e "${pureftpd_install_dir}" ] && { service pureftpd stop > /dev/null 2>&1; rm -rf ${pureftpd_install_dir} /etc/init.d/pureftpd; }
  echo "${CMSG}Pureftpd uninstall completed! ${CEND}"
}

Print_Redis() {
  [ -e "$redis_install_dir" ] && echo "$redis_install_dir"
  [ -e "/etc/init.d/redis-server" ] && echo "/etc/init.d/redis-server"
}

Uninstall_Redis() {
  [ -e "$redis_install_dir" ] && { service redis-server stop > /dev/null 2>&1; rm -rf $redis_install_dir /etc/init.d/redis-server /usr/local/bin/redis-*; }
  [ -e "${php_install_dir}/etc/php.d/05-redis.ini" ] && rm -rf ${php_install_dir}/etc/php.d/05-redis.ini
  echo "${CMSG}Redis uninstall completed! ${CEND}"
}

Print_Memcached() {
  [ -e "${memcached_install_dir}" ] && echo "${memcached_install_dir}"
  [ -e "/etc/init.d/memcached" ] && echo "/etc/init.d/memcached"
  [ -e "/usr/bin/memcached" ] && echo "/usr/bin/memcached"
}

Uninstall_Memcached() {
  [ -e "${memcached_install_dir}" ] && { service memcached stop > /dev/null 2>&1; rm -rf ${memcached_install_dir} /etc/init.d/memcached /usr/bin/memcached; }
  [ -e "${php_install_dir}/etc/php.d/05-memcache.ini" ] && rm -rf ${php_install_dir}/etc/php.d/05-memcache.ini
  [ -e "${php_install_dir}/etc/php.d/05-memcached.ini" ] && rm -rf ${php_install_dir}/etc/php.d/05-memcached.ini
  echo "${CMSG}Memcached uninstall completed! ${CEND}"
}

Print_openssl() {
  [ -d "${openssl_install_dir}" ] && echo "${openssl_install_dir}"
}

Uninstall_openssl() {
  [ -d "${openssl_install_dir}" ] && { rm -rf ${openssl_install_dir} /etc/ld.so.conf.d/openssl.conf; ldconfig; }
}

Menu(){
while :; do
  printf "
What Are You Doing?
\t${CMSG}0${CEND}. Uninstall All
\t${CMSG}1${CEND}. Uninstall Nginx/Tengine/Apache/Tomcat
\t${CMSG}2${CEND}. Uninstall MySQL/MariaDB/Percona/AliSQL
\t${CMSG}3${CEND}. Uninstall PostgreSQL
\t${CMSG}4${CEND}. Uninstall MongoDB
\t${CMSG}5${CEND}. Uninstall PHP
\t${CMSG}6${CEND}. Uninstall HHVM
\t${CMSG}7${CEND}. Uninstall PureFtpd
\t${CMSG}8${CEND}. Uninstall Redis
\t${CMSG}9${CEND}. Uninstall Memcached
\t${CMSG}q${CEND}. Exit
"
  echo
  read -p "Please input the correct option: " Number
  if [[ ! $Number =~ ^[0-9,q]$ ]]; then
    echo "${CWARNING}input error! Please only input 0~9 and q${CEND}"
  else
    case "$Number" in
    0)
      Print_Warn
      Print_web
      Print_MySQL
      Print_PostgreSQL
      Print_MongoDB
      Print_PHP
      Print_HHVM
      Print_PureFtpd
      Print_Redis
      Print_Memcached
      Print_openssl

      Uninstall_status
      if [ "${uninstall_yn}" == 'y' ]; then
        Uninstall_Web
        Uninstall_MySQL
        Uninstall_PostgreSQL
        Uninstall_MongoDB
        Uninstall_PHP
        Uninstall_HHVM
        Uninstall_PureFtpd
        Uninstall_Redis
        Uninstall_Memcached
        Uninstall_openssl
      else
        exit
      fi
      ;;
    1)
      Print_Warn
      Print_web
      Uninstall_status
      [ "${uninstall_yn}" == 'y' ] && Uninstall_Web || exit
      ;;
    2)
      Print_Warn
      Print_MySQL
      Uninstall_status
      [ "${uninstall_yn}" == 'y' ] && Uninstall_MySQL || exit
      ;;
    3)
      Print_Warn
      Print_PostgreSQL
      Uninstall_status
      [ "${uninstall_yn}" == 'y' ] && Uninstall_PostgreSQL || exit
      ;;
    4)
      Print_Warn
      Print_MongoDB
      Uninstall_status
      [ "${uninstall_yn}" == 'y' ] && Uninstall_MongoDB || exit
      ;;
    5)
      Print_PHP
      Uninstall_status
      [ "${uninstall_yn}" == 'y' ] && Uninstall_PHP || exit
      ;;
    6)
      Print_HHVM
      Uninstall_status
      [ "${uninstall_yn}" == 'y' ] && Uninstall_HHVM || exit
      ;;
    7)
      Print_PureFtpd
      Uninstall_status
      [ "${uninstall_yn}" == 'y' ] && Uninstall_PureFtpd || exit
      ;;
    8)
      Print_Redis
      Uninstall_status
      [ "${uninstall_yn}" == 'y' ] && Uninstall_Redis || exit
      ;;
    9)
      Print_Memcached
      Uninstall_status
      [ "${uninstall_yn}" == 'y' ] && Uninstall_Memcached || exit
      ;;
    q)
      exit
      ;;
    esac
  fi
done
}

if [ $# == 0 ]; then
  Menu
elif [ $# == 1 ]; then
  case $1 in
  all)
    Print_Warn
    Print_web
    Print_MySQL
    Print_PostgreSQL
    Print_MongoDB
    Print_PHP
    Print_HHVM
    Print_PureFtpd
    Print_Redis
    Print_Memcached
    Print_openssl

    Uninstall_status
    if [ "${uninstall_yn}" == 'y' ]; then
      Uninstall_Web
      Uninstall_MySQL
      Uninstall_PHP
      Uninstall_HHVM
      Uninstall_PureFtpd
      Uninstall_Redis
      Uninstall_Memcached
      Uninstall_openssl
    else
      exit
    fi
    ;;
  web)
    Print_Warn
    Print_web
    Uninstall_status
    [ "${uninstall_yn}" == 'y' ] && Uninstall_Web || exit
    ;;
  mysql)
    Print_Warn
    Print_MySQL
    Uninstall_status
    [ "${uninstall_yn}" == 'y' ] && Uninstall_MySQL || exit
    ;;
  postgresql)
    Print_Warn
    Print_PostgreSQL
    Uninstall_status
    [ "${uninstall_yn}" == 'y' ] && Uninstall_PostgreSQL || exit
    ;;
  mongodb)
    Print_Warn
    Print_MongoDB
    Uninstall_status
    [ "${uninstall_yn}" == 'y' ] && Uninstall_MongoDB || exit
    ;;
  php)
    Print_PHP
    Uninstall_status
    [ "${uninstall_yn}" == 'y' ] && Uninstall_PHP || exit
    ;;
  hhvm)
    Print_HHVM
    Uninstall_status
    [ "${uninstall_yn}" == 'y' ] && Uninstall_HHVM || exit
    ;;
  pureftpd)
    Print_PureFtpd
    Uninstall_status
    [ "${uninstall_yn}" == 'y' ] && Uninstall_PureFtpd || exit
    ;;
  redis)
    Print_Redis
    Uninstall_status
    [ "${uninstall_yn}" == 'y' ] && Uninstall_Redis || exit
    ;;
  memcached)
    Print_Memcached
    Uninstall_status
    [ "${uninstall_yn}" == 'y' ] && Uninstall_Memcached || exit
    ;;
  *)
    Usage
    ;;
  esac
else
  Usage
fi
