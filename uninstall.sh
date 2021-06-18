#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
clear
printf "
#######################################################################
#       OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+      #
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

Show_Help() {
  echo
  echo "Usage: $0  command ...[parameters]....
  --help, -h                    Show this help message, More: https://oneinstack.com
  --quiet, -q                   quiet operation
  --all                         Uninstall All
  --web                         Uninstall Nginx/Tengine/OpenResty/Apache/Tomcat
  --mysql                       Uninstall MySQL/MariaDB/Percona
  --postgresql                  Uninstall PostgreSQL
  --mongodb                     Uninstall MongoDB
  --php                         Uninstall PHP (PATH: ${php_install_dir})
  --mphp_ver [53~80]            Uninstall another PHP version (PATH: ${php_install_dir}\${mphp_ver})
  --allphp                      Uninstall all PHP
  --phpcache                    Uninstall PHP opcode cache
  --php_extensions [ext name]   Uninstall PHP extensions, include zendguardloader,ioncube,
                                sourceguardian,imagick,gmagick,fileinfo,imap,ldap,calendar,phalcon,
                                yaf,yar,redis,memcached,memcache,mongodb,swoole,xdebug
  --pureftpd                    Uninstall PureFtpd
  --redis                       Uninstall Redis-server
  --memcached                   Uninstall Memcached-server
  --phpmyadmin                  Uninstall phpMyAdmin
  --python                      Uninstall Python (PATH: ${python_install_dir})
  --node                        Uninstall Nodejs (PATH: ${node_install_dir})
  "
}

ARG_NUM=$#
TEMP=`getopt -o hvVq --long help,version,quiet,all,web,mysql,postgresql,mongodb,php,mphp_ver:,allphp,phpcache,php_extensions:,pureftpd,redis,memcached,phpmyadmin,python,node -- "$@" 2>/dev/null`
[ $? != 0 ] && echo "${CWARNING}ERROR: unknown argument! ${CEND}" && Show_Help && exit 1
eval set -- "${TEMP}"
while :; do
  [ -z "$1" ] && break;
  case "$1" in
    -h|--help)
      Show_Help; exit 0
      ;;
    -q|--quiet)
      quiet_flag=y
      uninstall_flag=y
      shift 1
      ;;
    --all)
      all_flag=y
      web_flag=y
      mysql_flag=y
      postgresql_flag=y
      mongodb_flag=y
      allphp_flag=y
      node_flag=y
      pureftpd_flag=y
      redis_flag=y
      memcached_flag=y
      phpmyadmin_flag=y
      python_flag=y
      shift 1
      ;;
    --web)
      web_flag=y; shift 1
      ;;
    --mysql)
      mysql_flag=y; shift 1
      ;;
    --postgresql)
      postgresql_flag=y; shift 1
      ;;
    --mongodb)
      mongodb_flag=y; shift 1
      ;;
    --php)
      php_flag=y; shift 1
      ;;
    --mphp_ver)
      mphp_ver=$2; mphp_flag=y; shift 2
      [[ ! "${mphp_ver}" =~ ^5[3-6]$|^7[0-4]$|^80$ ]] && { echo "${CWARNING}mphp_ver input error! Please only input number 53~80${CEND}"; exit 1; }
      ;;
    --allphp)
      allphp_flag=y; shift 1
      ;;
    --phpcache)
      phpcache_flag=y; shift 1
      ;;
    --php_extensions)
      php_extensions=$2; shift 2
      [ -n "`echo ${php_extensions} | grep -w zendguardloader`" ] && pecl_zendguardloader=1
      [ -n "`echo ${php_extensions} | grep -w ioncube`" ] && pecl_ioncube=1
      [ -n "`echo ${php_extensions} | grep -w sourceguardian`" ] && pecl_sourceguardian=1
      [ -n "`echo ${php_extensions} | grep -w imagick`" ] && pecl_imagick=1
      [ -n "`echo ${php_extensions} | grep -w gmagick`" ] && pecl_gmagick=1
      [ -n "`echo ${php_extensions} | grep -w fileinfo`" ] && pecl_fileinfo=1
      [ -n "`echo ${php_extensions} | grep -w imap`" ] && pecl_imap=1
      [ -n "`echo ${php_extensions} | grep -w ldap`" ] && pecl_ldap=1
      [ -n "`echo ${php_extensions} | grep -w calendar`" ] && pecl_calendar=1
      [ -n "`echo ${php_extensions} | grep -w phalcon`" ] && pecl_phalcon=1
      [ -n "`echo ${php_extensions} | grep -w yaf`" ] && pecl_yaf=1
      [ -n "`echo ${php_extensions} | grep -w yar`" ] && pecl_yar=1
      [ -n "`echo ${php_extensions} | grep -w redis`" ] && pecl_redis=1
      [ -n "`echo ${php_extensions} | grep -w memcached`" ] && pecl_memcached=1
      [ -n "`echo ${php_extensions} | grep -w memcache`" ] && pecl_memcache=1
      [ -n "`echo ${php_extensions} | grep -w mongodb`" ] && pecl_mongodb=1
      [ -n "`echo ${php_extensions} | grep -w swoole`" ] && pecl_swoole=1
      [ -n "`echo ${php_extensions} | grep -w xdebug`" ] && pecl_xdebug=1
      ;;
    --node)
      node_flag=y; shift 1
      ;;
    --pureftpd)
      pureftpd_flag=y; shift 1
      ;;
    --redis)
      redis_flag=y; shift 1
      ;;
    --memcached)
      memcached_flag=y; shift 1
      ;;
    --phpmyadmin)
      phpmyadmin_flag=y; shift 1
      ;;
    --python)
      python_flag=y; shift 1
      ;;
    --)
      shift
      ;;
    *)
      echo "${CWARNING}ERROR: unknown argument! ${CEND}" && Show_Help && exit 1
      ;;
  esac
done

Uninstall_status() {
  if [ "${quiet_flag}" != 'y' ]; then
    while :; do echo
      read -e -p "Do you want to uninstall? [y/n]: " uninstall_flag
      if [[ ! ${uninstall_flag} =~ ^[y,n]$ ]]; then
        echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
      else
        break
      fi
    done
  fi
}

Print_Warn() {
  echo
  echo "${CWARNING}You will uninstall OneinStack, Please backup your configure files and DB data! ${CEND}"
}

Print_web() {
  [ -d "${nginx_install_dir}" ] && echo ${nginx_install_dir}
  [ -d "${tengine_install_dir}" ] && echo ${tengine_install_dir}
  [ -d "${openresty_install_dir}" ] && echo ${openresty_install_dir}
  [ -e "/etc/init.d/nginx" ] && echo /etc/init.d/nginx
  [ -e "/lib/systemd/system/nginx.service" ] && echo /lib/systemd/system/nginx.service
  [ -e "/etc/logrotate.d/nginx" ] && echo /etc/logrotate.d/nginx

  [ -d "${apache_install_dir}" ] && echo ${apache_install_dir}
  [ -e "/lib/systemd/system/httpd.service" ] && echo /lib/systemd/system/httpd.service
  [ -e "/etc/init.d/httpd" ] && echo /etc/init.d/httpd
  [ -e "/etc/logrotate.d/apache" ] && echo /etc/logrotate.d/apache

  [ -d "${tomcat_install_dir}" ] && echo ${tomcat_install_dir}
  [ -e "/etc/init.d/tomcat" ] && echo /etc/init.d/tomcat
  [ -e "/etc/logrotate.d/tomcat" ] && echo /etc/logrotate.d/tomcat
  [ -d "/usr/java" ] && echo /usr/java
  [ -d "${apr_install_dir}" ] && echo ${apr_install_dir}
}

Uninstall_Web() {
  [ -d "${nginx_install_dir}" ] && { killall nginx > /dev/null 2>&1; rm -rf ${nginx_install_dir} /etc/init.d/nginx /etc/logrotate.d/nginx; sed -i "s@${nginx_install_dir}/sbin:@@" /etc/profile; echo "${CMSG}Nginx uninstall completed! ${CEND}"; }
  [ -d "${tengine_install_dir}" ] && { killall nginx > /dev/null 2>&1; rm -rf ${tengine_install_dir} /etc/init.d/nginx /etc/logrotate.d/nginx; sed -i "s@${tengine_install_dir}/sbin:@@" /etc/profile; echo "${CMSG}Tengine uninstall completed! ${CEND}"; }
  [ -d "${openresty_install_dir}" ] && { killall nginx > /dev/null 2>&1; rm -rf ${openresty_install_dir} /etc/init.d/nginx /etc/logrotate.d/nginx; sed -i "s@${openresty_install_dir}/nginx/sbin:@@" /etc/profile; echo "${CMSG}OpenResty uninstall completed! ${CEND}"; }
  [ -e "/lib/systemd/system/nginx.service" ] && { systemctl disable nginx > /dev/null 2>&1; rm -f /lib/systemd/system/nginx.service; }
  [ -d "${apache_install_dir}" ] && { service httpd stop > /dev/null 2>&1; rm -rf ${apache_install_dir} /etc/init.d/httpd /etc/logrotate.d/apache; sed -i "s@${apache_install_dir}/bin:@@" /etc/profile; echo "${CMSG}Apache uninstall completed! ${CEND}"; }
  [ -e "/lib/systemd/system/httpd.service" ] && { systemctl disable httpd > /dev/null 2>&1; rm -f /lib/systemd/system/httpd.service; }
  [ -d "${tomcat_install_dir}" ] && { killall java > /dev/null 2>&1; rm -rf ${tomcat_install_dir} /etc/init.d/tomcat /etc/logrotate.d/tomcat; echo "${CMSG}Tomcat uninstall completed! ${CEND}"; }
  [ -d "/usr/java" ] && { rm -rf /usr/java; sed -i '/export JAVA_HOME=/d' /etc/profile; sed -i '/export CLASSPATH=/d' /etc/profile; sed -i 's@\$JAVA_HOME/bin:@@' /etc/profile; }
  [ -e "${wwwroot_dir}" ] && /bin/mv ${wwwroot_dir}{,$(date +%Y%m%d%H)}
  sed -i 's@^website_name=.*@website_name=@' ./options.conf
  sed -i 's@^backup_content=.*@backup_content=@' ./options.conf
  [ -d "${apr_install_dir}" ] && rm -rf ${apr_install_dir}
}

Print_MySQL() {
  [ -e "${db_install_dir}" ] && echo ${db_install_dir}
  [ -e "/etc/init.d/mysqld" ] && echo /etc/init.d/mysqld
  [ -e "/etc/my.cnf" ] && echo /etc/my.cnf
}

Print_PostgreSQL() {
  [ -e "${pgsql_install_dir}" ] && echo ${pgsql_install_dir}
  [ -e "/etc/init.d/postgresql" ] && echo /etc/init.d/postgresql
  [ -e "/lib/systemd/system/postgresql.service" ] && echo /lib/systemd/system/postgresql.service
}

Print_MongoDB() {
  [ -e "${mongo_install_dir}" ] && echo ${mongo_install_dir}
  [ -e "/etc/init.d/mongod" ] && echo /etc/init.d/mongod
  [ -e "/lib/systemd/system/mongod.service" ] && echo /lib/systemd/system/mongod.service
  [ -e "/etc/mongod.conf" ] && echo /etc/mongod.conf
}

Uninstall_MySQL() {
  # uninstall mysql,mariadb,percona
  if [ -d "${db_install_dir}/support-files" ]; then
    service mysqld stop > /dev/null 2>&1
    rm -rf ${db_install_dir} /etc/init.d/mysqld /etc/my.cnf* /etc/ld.so.conf.d/*{mysql,mariadb,percona}*.conf
    id -u mysql >/dev/null 2>&1 ; [ $? -eq 0 ] && userdel mysql
    [ -e "${db_data_dir}" ] && /bin/mv ${db_data_dir}{,$(date +%Y%m%d%H)}
    sed -i 's@^dbrootpwd=.*@dbrootpwd=@' ./options.conf
    sed -i "s@${db_install_dir}/bin:@@" /etc/profile
    echo "${CMSG}MySQL uninstall completed! ${CEND}"
  fi
}

Uninstall_PostgreSQL() {
  # uninstall postgresql
  if [ -e "${pgsql_install_dir}/bin/psql" ]; then
    service postgresql stop > /dev/null 2>&1
    rm -rf ${pgsql_install_dir} /etc/init.d/postgresql
    [ -e "/lib/systemd/system/postgresql.service" ] && { systemctl disable postgresql > /dev/null 2>&1; rm -f /lib/systemd/system/postgresql.service; }
    [ -e "${php_install_dir}/etc/php.d/07-pgsql.ini" ] && rm -f ${php_install_dir}/etc/php.d/07-pgsql.ini
    id -u postgres >/dev/null 2>&1 ; [ $? -eq 0 ] && userdel postgres
    [ -e "${pgsql_data_dir}" ] && /bin/mv ${pgsql_data_dir}{,$(date +%Y%m%d%H)}
    sed -i 's@^dbpostgrespwd=.*@dbpostgrespwd=@' ./options.conf
    sed -i "s@${pgsql_install_dir}/bin:@@" /etc/profile
    echo "${CMSG}PostgreSQL uninstall completed! ${CEND}"
  fi
}

Uninstall_MongoDB() {
  # uninstall mongodb
  if [ -e "${mongo_install_dir}/bin/mongo" ]; then
    service mongod stop > /dev/null 2>&1
    rm -rf ${mongo_install_dir} /etc/mongod.conf /etc/init.d/mongod /tmp/mongo*.sock
    [ -e "/lib/systemd/system/mongod.service" ] && { systemctl disable mongod > /dev/null 2>&1; rm -f /lib/systemd/system/mongod.service; }
    [ -e "${php_install_dir}/etc/php.d/07-mongo.ini" ] && rm -f ${php_install_dir}/etc/php.d/07-mongo.ini
    [ -e "${php_install_dir}/etc/php.d/07-mongodb.ini" ] && rm -f ${php_install_dir}/etc/php.d/07-mongodb.ini
    id -u mongod > /dev/null 2>&1 ; [ $? -eq 0 ] && userdel mongod
    [ -e "${mongo_data_dir}" ] && /bin/mv ${mongo_data_dir}{,$(date +%Y%m%d%H)}
    sed -i 's@^dbmongopwd=.*@dbmongopwd=@' ./options.conf
    sed -i "s@${mongo_install_dir}/bin:@@" /etc/profile
    echo "${CMSG}MongoDB uninstall completed! ${CEND}"
  fi
}

Print_PHP() {
  [ -e "${php_install_dir}" ] && echo ${php_install_dir}
  [ -e "/etc/init.d/php-fpm" ] && echo /etc/init.d/php-fpm
  [ -e "/lib/systemd/system/php-fpm.service" ] && echo /lib/systemd/system/php-fpm.service
}

Print_MPHP() {
  [ -e "${php_install_dir}${mphp_ver}" ] && echo ${php_install_dir}${mphp_ver}
  [ -e "/etc/init.d/php${mphp_ver}-fpm" ] && echo /etc/init.d/php${mphp_ver}-fpm
  [ -e "/lib/systemd/system/php${mphp_ver}-fpm.service" ] && echo /lib/systemd/system/php${mphp_ver}-fpm.service
}

Print_ALLPHP() {
  [ -e "${php_install_dir}" ] && echo ${php_install_dir}
  [ -e "/etc/init.d/php-fpm" ] && echo /etc/init.d/php-fpm
  [ -e "/lib/systemd/system/php-fpm.service" ] && echo /lib/systemd/system/php-fpm.service
  for php_ver in 53 54 55 56 70 71 72 73 74 80; do
    [ -e "${php_install_dir}${php_ver}" ] && echo ${php_install_dir}${php_ver}
    [ -e "/etc/init.d/php${php_ver}-fpm" ] && echo /etc/init.d/php${php_ver}-fpm
    [ -e "/lib/systemd/system/php${php_ver}-fpm.service" ] && echo /lib/systemd/system/php${php_ver}-fpm.service
  done
  [ -e "${imagick_install_dir}" ] && echo ${imagick_install_dir}
  [ -e "${gmagick_install_dir}" ] && echo ${gmagick_install_dir}
  [ -e "${curl_install_dir}" ] && echo ${curl_install_dir}
  [ -e "${freetype_install_dir}" ] && echo ${freetype_install_dir}
  [ -e "${libiconv_install_dir}" ] && echo ${libiconv_install_dir}
}

Uninstall_PHP() {
  [ -e "/etc/init.d/php-fpm" ] && { service php-fpm stop > /dev/null 2>&1; rm -f /etc/init.d/php-fpm; }
  [ -e "/lib/systemd/system/php-fpm.service" ] && { systemctl stop php-fpm > /dev/null 2>&1; systemctl disable php-fpm > /dev/null 2>&1; rm -f /lib/systemd/system/php-fpm.service; }
  [ -e "${apache_install_dir}/conf/httpd.conf" ] && [ -n "`grep libphp ${apache_install_dir}/conf/httpd.conf`" ] && sed -i '/libphp/d' ${apache_install_dir}/conf/httpd.conf
  [ -e "${php_install_dir}" ] && { rm -rf ${php_install_dir}; echo "${CMSG}PHP uninstall completed! ${CEND}"; }
  sed -i "s@${php_install_dir}/bin:@@" /etc/profile
}

Uninstall_MPHP() {
  [ -e "/etc/init.d/php${mphp_ver}-fpm" ] && { service php${mphp_ver}-fpm stop > /dev/null 2>&1; rm -f /etc/init.d/php${mphp_ver}-fpm; }
  [ -e "/lib/systemd/system/php${mphp_ver}-fpm.service" ] && { systemctl stop php${mphp_ver}-fpm > /dev/null 2>&1; systemctl disable php${mphp_ver}-fpm > /dev/null 2>&1; rm -f /lib/systemd/system/php${mphp_ver}-fpm.service; }
  [ -e "${php_install_dir}${mphp_ver}" ] && { rm -rf ${php_install_dir}${mphp_ver}; echo "${CMSG}PHP${mphp_ver} uninstall completed! ${CEND}"; }
}

Uninstall_ALLPHP() {
  [ -e "/etc/init.d/php-fpm" ] && { service php-fpm stop > /dev/null 2>&1; rm -f /etc/init.d/php-fpm; }
  [ -e "/lib/systemd/system/php-fpm.service" ] && { systemctl stop php-fpm > /dev/null 2>&1; systemctl disable php-fpm > /dev/null 2>&1; rm -f /lib/systemd/system/php-fpm.service; }
  [ -e "${apache_install_dir}/conf/httpd.conf" ] && [ -n "`grep libphp ${apache_install_dir}/conf/httpd.conf`" ] && sed -i '/libphp/d' ${apache_install_dir}/conf/httpd.conf
  [ -e "${php_install_dir}" ] && { rm -rf ${php_install_dir}; echo "${CMSG}PHP uninstall completed! ${CEND}"; }
  sed -i "s@${php_install_dir}/bin:@@" /etc/profile
  for php_ver in 53 54 55 56 70 71 72 73 74 80; do
    [ -e "/etc/init.d/php${php_ver}-fpm" ] && { service php${php_ver}-fpm stop > /dev/null 2>&1; rm -f /etc/init.d/php${php_ver}-fpm; }
    [ -e "/lib/systemd/system/php${php_ver}-fpm.service" ] && { systemctl stop php${php_ver}-fpm > /dev/null 2>&1; systemctl disable php${php_ver}-fpm > /dev/null 2>&1; rm -f /lib/systemd/system/php${php_ver}-fpm.service; }
    [ -e "${php_install_dir}${php_ver}" ] && { rm -rf ${php_install_dir}${php_ver}; echo "${CMSG}PHP${php_ver} uninstall completed! ${CEND}"; }
  done
  [ -e "${imagick_install_dir}" ] && rm -rf ${imagick_install_dir}
  [ -e "${gmagick_install_dir}" ] && rm -rf ${gmagick_install_dir}
  [ -e "${curl_install_dir}" ] && rm -rf ${curl_install_dir}
  [ -e "${freetype_install_dir}" ] && rm -rf ${freetype_install_dir}
  [ -e "${libiconv_install_dir}" ] && rm -rf ${libiconv_install_dir}
}

Uninstall_PHPcache() {
  . include/zendopcache.sh
  . include/xcache.sh
  . include/apcu.sh
  . include/eaccelerator.sh
  Uninstall_ZendOPcache
  Uninstall_XCache
  Uninstall_APCU
  Uninstall_eAccelerator
  # reload php
  [ -e "${php_install_dir}/sbin/php-fpm" ] && { [ -e "/bin/systemctl" ] && systemctl reload php-fpm || service php-fpm reload; }
  [ -n "${mphp_ver}" -a -e "${php_install_dir}${mphp_ver}/sbin/php-fpm" ] && { [ -e "/bin/systemctl" ] && systemctl reload php${mphp_ver}-fpm || service php${mphp_ver}-fpm reload; }
  [ -e "${apache_install_dir}/bin/apachectl" ] && ${apache_install_dir}/bin/apachectl -k graceful
}

Uninstall_PHPext() {
  # ZendGuardLoader
  if [ "${pecl_zendguardloader}" == '1' ]; then
    . include/ZendGuardLoader.sh
    Uninstall_ZendGuardLoader
  fi

  # ioncube
  if [ "${pecl_ioncube}" == '1' ]; then
    . include/ioncube.sh
    Uninstall_ionCube
  fi

  # SourceGuardian
  if [ "${pecl_sourceguardian}" == '1' ]; then
    . include/sourceguardian.sh
    Uninstall_SourceGuardian
  fi

  # imagick
  if [ "${pecl_imagick}" == '1' ]; then
    . include/ImageMagick.sh
    Uninstall_ImageMagick
    Uninstall_pecl_imagick
  fi

  # gmagick
  if [ "${pecl_gmagick}" == '1' ]; then
    . include/GraphicsMagick.sh
    Uninstall_GraphicsMagick
    Uninstall_pecl_gmagick
  fi

  # fileinfo
  if [ "${pecl_fileinfo}" == '1' ]; then
    . include/pecl_fileinfo.sh
    Uninstall_pecl_fileinfo
  fi

  # imap
  if [ "${pecl_imap}" == '1' ]; then
    . include/pecl_imap.sh
    Uninstall_pecl_imap
  fi

  # ldap
  if [ "${pecl_ldap}" == '1' ]; then
    . include/pecl_ldap.sh
    Uninstall_pecl_ldap
  fi

  # calendar
  if [ "${pecl_calendar}" == '1' ]; then
    . include/pecl_calendar.sh
    Uninstall_pecl_calendar
  fi

  # phalcon
  if [ "${pecl_phalcon}" == '1' ]; then
    . include/pecl_phalcon.sh
    Uninstall_pecl_phalcon
  fi

  # yaf
  if [ "${pecl_yaf}" == '1' ]; then
    . include/pecl_yaf.sh
    Uninstall_pecl_yaf 2>&1 | tee -a ${oneinstack_dir}/install.log
  fi

  # yar
  if [ "${pecl_yar}" == '1' ]; then
    . include/pecl_yar.sh
    Uninstall_pecl_yar 2>&1 | tee -a ${oneinstack_dir}/install.log
  fi

  # pecl_memcached
  if [ "${pecl_memcached}" == '1' ]; then
    . include/memcached.sh
    Uninstall_pecl_memcached
  fi

  # pecl_memcache
  if [ "${pecl_memcache}" == '1' ]; then
    . include/memcached.sh
    Uninstall_pecl_memcache
  fi

  # pecl_redis
  if [ "${pecl_redis}" == '1' ]; then
    . include/redis.sh
    Uninstall_pecl_redis
  fi

  # pecl_mongodb
  if [ "${pecl_mongodb}" == '1' ]; then
    . include/pecl_mongodb.sh
    Uninstall_pecl_mongodb
  fi

  # swoole
  if [ "${pecl_swoole}" == '1' ]; then
    . include/pecl_swoole.sh
    Uninstall_pecl_swoole
  fi

  # xdebug
  if [ "${pecl_xdebug}" == '1' ]; then
    . include/pecl_xdebug.sh
    Uninstall_pecl_xdebug
  fi

  # reload php
  [ -e "${php_install_dir}/sbin/php-fpm" ] && { [ -e "/bin/systemctl" ] && systemctl reload php-fpm || service php-fpm reload; }
  [ -n "${mphp_ver}" -a -e "${php_install_dir}${mphp_ver}/sbin/php-fpm" ] && { [ -e "/bin/systemctl" ] && systemctl reload php${mphp_ver}-fpm || service php${mphp_ver}-fpm reload; }
  [ -e "${apache_install_dir}/bin/apachectl" ] && ${apache_install_dir}/bin/apachectl -k graceful
}

Menu_PHPext() {
  while :; do
    echo 'Please select uninstall PHP extensions:'
    echo -e "\t${CMSG} 0${CEND}. Do not uninstall"
    echo -e "\t${CMSG} 1${CEND}. Uninstall zendguardloader(PHP<=5.6)"
    echo -e "\t${CMSG} 2${CEND}. Uninstall ioncube"
    echo -e "\t${CMSG} 3${CEND}. Uninstall sourceguardian(PHP<=7.2)"
    echo -e "\t${CMSG} 4${CEND}. Uninstall imagick"
    echo -e "\t${CMSG} 5${CEND}. Uninstall gmagick"
    echo -e "\t${CMSG} 6${CEND}. Uninstall fileinfo"
    echo -e "\t${CMSG} 7${CEND}. Uninstall imap"
    echo -e "\t${CMSG} 8${CEND}. Uninstall ldap"
    echo -e "\t${CMSG} 9${CEND}. Uninstall phalcon(PHP>=5.5)"
    echo -e "\t${CMSG}10${CEND}. Uninstall redis"
    echo -e "\t${CMSG}11${CEND}. Uninstall memcached"
    echo -e "\t${CMSG}12${CEND}. Uninstall memcache"
    echo -e "\t${CMSG}13${CEND}. Uninstall mongodb"
    echo -e "\t${CMSG}14${CEND}. Uninstall swoole"
    echo -e "\t${CMSG}15${CEND}. Uninstall xdebug(PHP>=5.5)"
    read -e -p "Please input a number:(Default 0 press Enter) " phpext_option
    phpext_option=${phpext_option:-0}
    [ "${phpext_option}" == '0' ] && break
    array_phpext=(${phpext_option})
    array_all=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15)
    for v in ${array_phpext[@]}
    do
      [ -z "`echo ${array_all[@]} | grep -w ${v}`" ] && phpext_flag=1
    done
    if [ "${phpext_flag}" == '1' ]; then
      unset phpext_flag
      echo; echo "${CWARNING}input error! Please only input number 1 2 3 14 and so on${CEND}"; echo
      continue
    else
      [ -n "`echo ${array_phpext[@]} | grep -w 1`" ] && pecl_zendguardloader=1
      [ -n "`echo ${array_phpext[@]} | grep -w 2`" ] && pecl_ioncube=1
      [ -n "`echo ${array_phpext[@]} | grep -w 3`" ] && pecl_sourceguardian=1
      [ -n "`echo ${array_phpext[@]} | grep -w 4`" ] && pecl_imagick=1
      [ -n "`echo ${array_phpext[@]} | grep -w 5`" ] && pecl_gmagick=1
      [ -n "`echo ${array_phpext[@]} | grep -w 6`" ] && pecl_fileinfo=1
      [ -n "`echo ${array_phpext[@]} | grep -w 7`" ] && pecl_imap=1
      [ -n "`echo ${array_phpext[@]} | grep -w 8`" ] && pecl_ldap=1
      [ -n "`echo ${array_phpext[@]} | grep -w 9`" ] && pecl_phalcon=1
      [ -n "`echo ${array_phpext[@]} | grep -w 10`" ] && pecl_redis=1
      [ -n "`echo ${array_phpext[@]} | grep -w 11`" ] && pecl_memcached=1
      [ -n "`echo ${array_phpext[@]} | grep -w 12`" ] && pecl_memcache=1
      [ -n "`echo ${array_phpext[@]} | grep -w 13`" ] && pecl_mongodb=1
      [ -n "`echo ${array_phpext[@]} | grep -w 14`" ] && pecl_swoole=1
      [ -n "`echo ${array_phpext[@]} | grep -w 15`" ] && pecl_xdebug=1
      break
    fi
  done
}

Print_PureFtpd() {
  [ -e "${pureftpd_install_dir}" ] && echo ${pureftpd_install_dir}
  [ -e "/etc/init.d/pureftpd" ] && echo /etc/init.d/pureftpd
  [ -e "/lib/systemd/system/pureftpd.service" ] && echo /lib/systemd/system/pureftpd.service
}

Uninstall_PureFtpd() {
  [ -e "${pureftpd_install_dir}" ] && { service pureftpd stop > /dev/null 2>&1; rm -rf ${pureftpd_install_dir} /etc/init.d/pureftpd; echo "${CMSG}Pureftpd uninstall completed! ${CEND}"; }
  [ -e "/lib/systemd/system/pureftpd.service" ] && { systemctl disable pureftpd > /dev/null 2>&1; rm -f /lib/systemd/system/pureftpd.service; }
}

Print_Redis_server() {
  [ -e "${redis_install_dir}" ] && echo ${redis_install_dir}
  [ -e "/etc/init.d/redis-server" ] && echo /etc/init.d/redis-server
  [ -e "/lib/systemd/system/redis-server.service" ] && echo /lib/systemd/system/redis-server.service
}

Uninstall_Redis_server() {
  [ -e "${redis_install_dir}" ] && { service redis-server stop > /dev/null 2>&1; rm -rf ${redis_install_dir} /etc/init.d/redis-server /usr/local/bin/redis-*; echo "${CMSG}Redis uninstall completed! ${CEND}"; }
  [ -e "/lib/systemd/system/redis-server.service" ] && { systemctl disable redis-server > /dev/null 2>&1; rm -f /lib/systemd/system/redis-server.service; }
}

Print_Memcached_server() {
  [ -e "${memcached_install_dir}" ] && echo ${memcached_install_dir}
  [ -e "/etc/init.d/memcached" ] && echo /etc/init.d/memcached
  [ -e "/usr/bin/memcached" ] && echo /usr/bin/memcached
}

Uninstall_Memcached_server() {
  [ -e "${memcached_install_dir}" ] && { service memcached stop > /dev/null 2>&1; rm -rf ${memcached_install_dir} /etc/init.d/memcached /usr/bin/memcached; echo "${CMSG}Memcached uninstall completed! ${CEND}"; }
}

Print_phpMyAdmin() {
  [ -d "${wwwroot_dir}/default/phpMyAdmin" ] && echo ${wwwroot_dir}/default/phpMyAdmin
}

Uninstall_phpMyAdmin() {
  [ -d "${wwwroot_dir}/default/phpMyAdmin" ] && rm -rf ${wwwroot_dir}/default/phpMyAdmin
}

Print_openssl() {
  [ -d "${openssl_install_dir}" ] && echo ${openssl_install_dir}
}

Uninstall_openssl() {
  [ -d "${openssl_install_dir}" ] && rm -rf ${openssl_install_dir}
}

Print_Python() {
  [ -d "${python_install_dir}" ] && echo ${python_install_dir}
}

Print_Node() {
  [ -e "${node_install_dir}" ] && echo ${node_install_dir}
  [ -e "/etc/profile.d/node.sh" ] && echo /etc/profile.d/node.sh
}

Menu() {
while :; do
  printf "
What Are You Doing?
\t${CMSG} 0${CEND}. Uninstall All
\t${CMSG} 1${CEND}. Uninstall Nginx/Tengine/OpenResty/Apache/Tomcat
\t${CMSG} 2${CEND}. Uninstall MySQL/MariaDB/Percona
\t${CMSG} 3${CEND}. Uninstall PostgreSQL
\t${CMSG} 4${CEND}. Uninstall MongoDB
\t${CMSG} 5${CEND}. Uninstall all PHP
\t${CMSG} 6${CEND}. Uninstall PHP opcode cache
\t${CMSG} 7${CEND}. Uninstall PHP extensions
\t${CMSG} 8${CEND}. Uninstall PureFtpd
\t${CMSG} 9${CEND}. Uninstall Redis
\t${CMSG}10${CEND}. Uninstall Memcached
\t${CMSG}11${CEND}. Uninstall phpMyAdmin
\t${CMSG}12${CEND}. Uninstall Python (PATH: ${python_install_dir})
\t${CMSG}13${CEND}. Uninstall Nodejs (PATH: ${node_install_dir})
\t${CMSG} q${CEND}. Exit
"
  echo
  read -e -p "Please input the correct option: " Number
  if [[ ! "${Number}" =~ ^[0-9,q]$|^1[0-3]$ ]]; then
    echo "${CWARNING}input error! Please only input 0~13 and q${CEND}"
  else
    case "$Number" in
    0)
      Print_Warn
      Print_web
      Print_MySQL
      Print_PostgreSQL
      Print_MongoDB
      Print_ALLPHP
      Print_PureFtpd
      Print_Redis_server
      Print_Memcached_server
      Print_openssl
      Print_phpMyAdmin
      Print_Python
      Print_Node
      Uninstall_status
      if [ "${uninstall_flag}" == 'y' ]; then
        Uninstall_Web
        Uninstall_MySQL
        Uninstall_PostgreSQL
        Uninstall_MongoDB
        Uninstall_ALLPHP
        Uninstall_PureFtpd
        Uninstall_Redis_server
        Uninstall_Memcached_server
        Uninstall_openssl
        Uninstall_phpMyAdmin
        . include/python.sh; Uninstall_Python
        . include/node.sh; Uninstall_Node
      else
        exit
      fi
      ;;
    1)
      Print_Warn
      Print_web
      Uninstall_status
      [ "${uninstall_flag}" == 'y' ] && Uninstall_Web || exit
      ;;
    2)
      Print_Warn
      Print_MySQL
      Uninstall_status
      [ "${uninstall_flag}" == 'y' ] && Uninstall_MySQL || exit
      ;;
    3)
      Print_Warn
      Print_PostgreSQL
      Uninstall_status
      [ "${uninstall_flag}" == 'y' ] && Uninstall_PostgreSQL || exit
      ;;
    4)
      Print_Warn
      Print_MongoDB
      Uninstall_status
      [ "${uninstall_flag}" == 'y' ] && Uninstall_MongoDB || exit
      ;;
    5)
      Print_ALLPHP
      Uninstall_status
      [ "${uninstall_flag}" == 'y' ] && Uninstall_ALLPHP || exit
      ;;
    6)
      Uninstall_status
      [ "${uninstall_flag}" == 'y' ] && Uninstall_PHPcache || exit
      ;;
    7)
      Menu_PHPext
      [ "${phpext_option}" != '0' ] && Uninstall_status
      [ "${uninstall_flag}" == 'y' ] && Uninstall_PHPext || exit
      ;;
    8)
      Print_PureFtpd
      Uninstall_status
      [ "${uninstall_flag}" == 'y' ] && Uninstall_PureFtpd || exit
      ;;
    9)
      Print_Redis_server
      Uninstall_status
      [ "${uninstall_flag}" == 'y' ] && Uninstall_Redis_server || exit
      ;;
    10)
      Print_Memcached_server
      Uninstall_status
      [ "${uninstall_flag}" == 'y' ] && Uninstall_Memcached_server || exit
      ;;
    11)
      Print_phpMyAdmin
      Uninstall_status
      [ "${uninstall_flag}" == 'y' ] && Uninstall_phpMyAdmin || exit
      ;;
    12)
      Print_Python
      Uninstall_status
      [ "${uninstall_flag}" == 'y' ] && { . include/python.sh; Uninstall_Python; } || exit
      ;;
    13)
      Print_Node
      Uninstall_status
      [ "${uninstall_flag}" == 'y' ] && { . include/node.sh; Uninstall_Node; } || exit
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
  [ "${web_flag}" == 'y' ] && Print_web
  [ "${mysql_flag}" == 'y' ] && Print_MySQL
  [ "${postgresql_flag}" == 'y' ] && Print_PostgreSQL
  [ "${mongodb_flag}" == 'y' ] && Print_MongoDB
  if [ "${allphp_flag}" == 'y' ]; then
    Print_ALLPHP
  else
    [ "${php_flag}" == 'y' ] && Print_PHP
    [ "${mphp_flag}" == 'y' ] && [ "${phpcache_flag}" != 'y' ] && [ -z "${php_extensions}" ] && Print_MPHP
  fi
  [ "${pureftpd_flag}" == 'y' ] && Print_PureFtpd
  [ "${redis_flag}" == 'y' ] && Print_Redis_server
  [ "${memcached_flag}" == 'y' ] && Print_Memcached_server
  [ "${phpmyadmin_flag}" == 'y' ] && Print_phpMyAdmin
  [ "${python_flag}" == 'y' ] && Print_Python
  [ "${node_flag}" == 'y' ] && Print_Node
  [ "${all_flag}" == 'y' ] && Print_openssl
  Uninstall_status
  if [ "${uninstall_flag}" == 'y' ]; then
    [ "${web_flag}" == 'y' ] && Uninstall_Web
    [ "${mysql_flag}" == 'y' ] && Uninstall_MySQL
    [ "${postgresql_flag}" == 'y' ] && Uninstall_PostgreSQL
    [ "${mongodb_flag}" == 'y' ] && Uninstall_MongoDB
    if [ "${allphp_flag}" == 'y' ]; then
      Uninstall_ALLPHP
    else
      [ "${php_flag}" == 'y' ] && Uninstall_PHP
      [ "${phpcache_flag}" == 'y' ] && Uninstall_PHPcache
      [ -n "${php_extensions}" ] && Uninstall_PHPext
      [ "${mphp_flag}" == 'y' ] && [ "${phpcache_flag}" != 'y' ] && [ -z "${php_extensions}" ] && Uninstall_MPHP
      [ "${mphp_flag}" == 'y' ] && [ "${phpcache_flag}" == 'y' ] && { php_install_dir=${php_install_dir}${mphp_ver}; Uninstall_PHPcache; }
      [ "${mphp_flag}" == 'y' ] && [ -n "${php_extensions}" ] && { php_install_dir=${php_install_dir}${mphp_ver}; Uninstall_PHPext; }
    fi
    [ "${pureftpd_flag}" == 'y' ] && Uninstall_PureFtpd
    [ "${redis_flag}" == 'y' ] && Uninstall_Redis_server
    [ "${memcached_flag}" == 'y' ] && Uninstall_Memcached_server
    [ "${phpmyadmin_flag}" == 'y' ] && Uninstall_phpMyAdmin
    [ "${python_flag}" == 'y' ] && { . include/python.sh; Uninstall_Python; }
    [ "${node_flag}" == 'y' ] && { . include/node.sh; Uninstall_Node; }
    [ "${all_flag}" == 'y' ] && Uninstall_openssl
  fi
fi
