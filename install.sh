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
#       For more information please visit https://oneinstack.com      #
#######################################################################
"
# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

oneinstack_dir=$(dirname "`readlink -f $0`")
pushd ${oneinstack_dir} > /dev/null
. ./versions.txt
. ./options.conf
. ./include/color.sh
. ./include/check_os.sh
. ./include/check_dir.sh
. ./include/download.sh
. ./include/get_char.sh

ssh_port=22
dbrootpwd=`< /dev/urandom tr -dc A-Za-z0-9 | head -c8`
dbpostgrespwd=`< /dev/urandom tr -dc A-Za-z0-9 | head -c8`
dbmongopwd=`< /dev/urandom tr -dc A-Za-z0-9 | head -c8`
xcachepwd=`< /dev/urandom tr -dc A-Za-z0-9 | head -c8`
dbinstallmethod=1

version() {
  echo "version: 1.7"
  echo "updated date: 2018-04-20"
}

showhelp() {
  version
  echo "Usage: $0  command ...[parameters]....
  --help, -h                  Show this help message, More: https://oneinstack.com/auto
  --version, -v               Show version info
  --nginx_option [1-3]        Install Nginx server version
  --apache_option [1-2]       Install Apache server version
  --php_option [1-7]          Install PHP version
  --phpcache_option [1-4]     Install PHP opcode cache, default: 1 opcache
  --php_extensions [ext name] Install PHP extension, include zendguardloader,ioncube,imagick,gmagick
  --tomcat_option [1-4]       Install Tomcat version
  --jdk_option [1-4]          Install JDK version
  --db_option [1-15]          Install DB version
  --dbinstallmethod [1-2]     DB install method, default: 1 binary install
  --dbrootpwd [password]      DB super password
  --pureftpd                  Install Pure-Ftpd
  --redis                     Install Redis
  --memcached                 Install Memcached
  --phpmyadmin                Install phpMyAdmin
  --hhvm                      Install HHVM
  --ssh_port [22]             SSH port, default: 22
  --iptables                  Enable iptables
  --reboot                    Restart the server after installation
  "
}
ARG_NUM=$#
TEMP=`getopt -o hvV --long help,version,nginx_option:,apache_option:,php_option:,phpcache_option:,php_extensions:,tomcat_option:,jdk_option:,db_option:,dbrootpwd:,dbinstallmethod:,pureftpd,redis,memcached,phpmyadmin,hhvm,ssh_port:,iptables,reboot -- "$@" 2>/dev/null`
[ $? != 0 ] && echo "${CWARNING}ERROR: unknown argument! ${CEND}" && showhelp && exit 1
eval set -- "${TEMP}"
while :; do
  [ -z "$1" ] && break;
  case "$1" in
    -h|--help)
      showhelp; exit 0
      ;;
    -v|-V|--version)
      version; exit 0
      ;;
    --nginx_option)
      nginx_option=$2; shift 2
      [[ ! ${nginx_option} =~ ^[1-3]$ ]] && { echo "${CWARNING}nginx_option input error! Please only input number 1~3${CEND}"; exit 1; }
      web_yn=y
      [ -e "${nginx_install_dir}/sbin/nginx" ] && { echo "${CWARNING}Nginx already installed! ${CEND}"; nginx_option=Other; }
      [ -e "${tengine_install_dir}/sbin/nginx" ] && { echo "${CWARNING}Tengine already installed! ${CEND}"; nginx_option=Other; }
      [ -e "${openresty_install_dir}/nginx/sbin/nginx" ] && { echo "${CWARNING}OpenResty already installed! ${CEND}"; nginx_option=Other; }
      ;;
    --apache_option)
      apache_option=$2; shift 2
      [[ ! ${apache_option} =~ ^[1-2]$ ]] && { echo "${CWARNING}apache_option input error! Please only input number 1~2${CEND}"; exit 1; }
      web_yn=y
      [ -e "${apache_install_dir}/conf/httpd.conf" ] && { echo "${CWARNING}Aapche already installed! ${CEND}"; apache_option=Other; }
      ;;
    --php_option)
      php_option=$2; shift 2
      [[ ! ${php_option} =~ ^[1-7]$ ]] && { echo "${CWARNING}php_option input error! Please only input number 1~7${CEND}"; exit 1; }
      php_yn=y
      [ -e "${php_install_dir}/bin/phpize" ] && { echo "${CWARNING}PHP already installed! ${CEND}"; php_option=Other; }
      ;;
    --phpcache_option)
      phpcache_option=$2; shift 2
      ;;
    --php_extensions)
      php_extensions=$2; shift 2
      [ -n "`echo ${php_extensions} | grep -w zendguardloader`" ] && zendguardloader_yn=y
      [ -n "`echo ${php_extensions} | grep -w ioncube`" ] && ioncube_yn=y
      [ -n "`echo ${php_extensions} | grep -w imagick`" ] && magick_option=1
      [ -n "`echo ${php_extensions} | grep -w gmagick`" ] && magick_option=2
      ;;
    --tomcat_option)
      tomcat_option=$2; shift 2
      [[ ! ${tomcat_option} =~ ^[1-4]$ ]] && { echo "${CWARNING}tomcat_option input error! Please only input number 1~4${CEND}"; exit 1; }
      web_yn=y
      [ -e "$tomcat_install_dir/conf/server.xml" ] && { echo "${CWARNING}Tomcat already installed! ${CEND}" ; tomcat_option=Other; }
      ;;
    --jdk_option)
      jdk_option=$2; shift 2
      [[ ! ${jdk_option} =~ ^[1-4]$ ]] && { echo "${CWARNING}jdk_option input error! Please only input number 1~4${CEND}"; exit 1; }
      ;;
    --db_option)
      db_option=$2; shift 2
      db_yn=y
      if [[ "${db_option}" =~ ^[1-9]$|^1[0-3]$ ]]; then
        [ -d "${db_install_dir}/support-files" ] && { echo "${CWARNING}MySQL already installed! ${CEND}"; db_option=Other; }
      elif [ "${db_option}" == '14' ]; then
        [ -e "${pgsql_install_dir}/bin/psql" ] && { echo "${CWARNING}PostgreSQL already installed! ${CEND}"; db_option=Other; }
      elif [ "${db_option}" == '15' ]; then
        [ -e "${mongo_install_dir}/bin/mongo" ] && { echo "${CWARNING}MongoDB already installed! ${CEND}"; db_option=Other; }
      else
        echo "${CWARNING}db_option input error! Please only input number 1~15${CEND}"
        exit 1
      fi
      ;;
    --dbrootpwd)
      dbrootpwd=$2; shift 2
      dbpostgrespwd="${dbrootpwd}"
      dbmongopwd="${dbrootpwd}"
      ;;
    --dbinstallmethod)
      dbinstallmethod=$2; shift 2
      [[ ! ${dbinstallmethod} =~ ^[1-2]$ ]] && { echo "${CWARNING}dbinstallmethod input error! Please only input number 1~2${CEND}"; exit 1; }
      ;;
    --pureftpd)
      ftp_yn=y; shift 1
      [ -e "${pureftpd_install_dir}/sbin/pure-ftpwho" ] && { echo "${CWARNING}Pure-FTPd already installed! ${CEND}"; ftp_yn=Other; }
      ;;
    --redis)
      redis_yn=y; shift 1
      ;;
    --memcached)
      memcached_yn=y; shift 1
      ;;
    --phpmyadmin)
      phpmyadmin_yn=y; shift 1
      [ -d "${wwwroot_dir}/default/phpMyAdmin" ] && { echo "${CWARNING}phpMyAdmin already installed! ${CEND}"; phpmyadmin_yn=Other; }
      ;;
    --hhvm)
      hhvm_yn=y; shift 1
      [ -e "/usr/bin/hhvm" ] && { echo "${CWARNING}HHVM already installed! ${CEND}"; hhvm_yn=Other; }
      ;;
    --ssh_port)
      ssh_port=$2; shift 2
      [ ${ssh_port} -eq 22 >/dev/null 2>&1 -o ${ssh_port} -gt 1024 >/dev/null 2>&1 -a ${ssh_port} -lt 65535 >/dev/null 2>&1 ] || { echo "${CWARNING}ssh_port input error! Input range: 22,1025~65534${CEND}"; exit 1; }
      ;;
    --iptables)
      iptables_yn=y; shift 1
      ;;
    --reboot)
      reboot_yn=y; shift 1
      ;;
    --)
      shift
      ;;
    *)
      echo "${CWARNING}ERROR: unknown argument! ${CEND}" && showhelp && exit 1
      ;;
  esac
done

mkdir -p ${wwwroot_dir}/default ${wwwlogs_dir}
[ -d /data ] && chmod 755 /data
# Use default SSH port 22. If you use another SSH port on your server
if [ -e "/etc/ssh/sshd_config" ]; then
  if [ ${ARG_NUM} == 0 ]; then
    [ -z "`grep ^Port /etc/ssh/sshd_config`" ] && now_ssh_port=22 || now_ssh_port=`grep ^Port /etc/ssh/sshd_config | awk '{print $2}'`
    while :; do echo
      read -p "Please input SSH port(Default: ${now_ssh_port}): " ssh_port
      [ -z "${ssh_port}" ] && ssh_port=${now_ssh_port}
      if [ ${ssh_port} -eq 22 >/dev/null 2>&1 -o ${ssh_port} -gt 1024 >/dev/null 2>&1 -a ${ssh_port} -lt 65535 >/dev/null 2>&1 ]; then
        break
      else
        echo "${CWARNING}input error! Input range: 22,1025~65534${CEND}"
      fi
    done
  fi

  if [ -z "`grep ^Port /etc/ssh/sshd_config`" -a "${ssh_port}" != '22' ]; then
    sed -i "s@^#Port.*@&\nPort ${ssh_port}@" /etc/ssh/sshd_config
  elif [ -n "`grep ^Port /etc/ssh/sshd_config`" ]; then
    sed -i "s@^Port.*@Port ${ssh_port}@" /etc/ssh/sshd_config
  fi
fi

if [ ${ARG_NUM} == 0 ]; then
  # check iptables
  while :; do echo
    read -p "Do you want to enable iptables? [y/n]: " iptables_yn
    if [[ ! ${iptables_yn} =~ ^[y,n]$ ]]; then
      echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
      break
    fi
  done

  # check Web server
  while :; do echo
    read -p "Do you want to install Web server? [y/n]: " web_yn
    if [[ ! ${web_yn} =~ ^[y,n]$ ]]; then
      echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
      if [ "${web_yn}" == 'y' ]; then
        # Nginx/Tegine/OpenResty
        while :; do echo
          echo 'Please select Nginx server:'
          echo -e "\t${CMSG}1${CEND}. Install Nginx"
          echo -e "\t${CMSG}2${CEND}. Install Tengine"
          echo -e "\t${CMSG}3${CEND}. Install OpenResty"
          echo -e "\t${CMSG}4${CEND}. Do not install"
          read -p "Please input a number:(Default 1 press Enter) " nginx_option
          [ -z "${nginx_option}" ] && nginx_option=1
          if [[ ! ${nginx_option} =~ ^[1-4]$ ]]; then
            echo "${CWARNING}input error! Please only input number 1~4${CEND}"
          else
            [ "${nginx_option}" != '4' -a -e "${nginx_install_dir}/sbin/nginx" ] && { echo "${CWARNING}Nginx already installed! ${CEND}"; nginx_option=Other; }
            [ "${nginx_option}" != '4' -a -e "${tengine_install_dir}/sbin/nginx" ] && { echo "${CWARNING}Tengine already installed! ${CEND}"; nginx_option=Other; }
            [ "${nginx_option}" != '4' -a -e "${openresty_install_dir}/nginx/sbin/nginx" ] && { echo "${CWARNING}OpenResty already installed! ${CEND}"; nginx_option=Other; }
            break
          fi
        done
        # Apache
        while :; do echo
          echo 'Please select Apache server:'
          echo -e "\t${CMSG}1${CEND}. Install Apache-2.4"
          echo -e "\t${CMSG}2${CEND}. Install Apache-2.2"
          echo -e "\t${CMSG}3${CEND}. Do not install"
          read -p "Please input a number:(Default 3 press Enter) " apache_option
          [ -z "${apache_option}" ] && apache_option=3
          if [[ ! ${apache_option} =~ ^[1-3]$ ]]; then
            echo "${CWARNING}input error! Please only input number 1~3${CEND}"
          else
            [ "${apache_option}" != '3' -a -e "${apache_install_dir}/conf/httpd.conf" ] && { echo "${CWARNING}Aapche already installed! ${CEND}"; apache_option=Other; }
            break
          fi
        done
        # Tomcat
        #while :; do echo
        #  echo 'Please select tomcat server:'
        #  echo -e "\t${CMSG}1${CEND}. Install Tomcat-9"
        #  echo -e "\t${CMSG}2${CEND}. Install Tomcat-8"
        #  echo -e "\t${CMSG}3${CEND}. Install Tomcat-7"
        #  echo -e "\t${CMSG}4${CEND}. Install Tomcat-6"
        #  echo -e "\t${CMSG}5${CEND}. Do not install"
        #  read -p "Please input a number:(Default 5 press Enter) " tomcat_option
        #  [ -z "${tomcat_option}" ] && tomcat_option=5
        #  if [[ ! ${tomcat_option} =~ ^[1-5]$ ]]; then
        #    echo "${CWARNING}input error! Please only input number 1~5${CEND}"
        #  else
        #    [ "${tomcat_option}" != '5' -a -e "$tomcat_install_dir/conf/server.xml" ] && { echo "${CWARNING}Tomcat already installed! ${CEND}" ; tomcat_option=Other; }
        #    if [ "${tomcat_option}" == '1' ]; then
        #      while :; do echo
        #        echo 'Please select JDK version:'
        #        echo -e "\t${CMSG}1${CEND}. Install JDK-10"
        #        echo -e "\t${CMSG}2${CEND}. Install JDK-1.8"
        #        read -p "Please input a number:(Default 1 press Enter) " jdk_option
        #        [ -z "${jdk_option}" ] && jdk_option=1
        #        if [[ ! ${jdk_option} =~ ^[1-2]$ ]]; then
        #          echo "${CWARNING}input error! Please only input number 1~2${CEND}"
        #        else
        #          break
        #        fi
        #      done
        #    elif [ "${tomcat_option}" == '2' ]; then
        #      while :; do echo
        #        echo 'Please select JDK version:'
        #        echo -e "\t${CMSG}1${CEND}. Install JDK-10"
        #        echo -e "\t${CMSG}2${CEND}. Install JDK-1.8"
        #        echo -e "\t${CMSG}3${CEND}. Install JDK-1.7"
        #        read -p "Please input a number:(Default 2 press Enter) " jdk_option
        #        [ -z "${jdk_option}" ] && jdk_option=2
        #        if [[ ! ${jdk_option} =~ ^[1-3]$ ]]; then
        #          echo "${CWARNING}input error! Please only input number 1~3${CEND}"
        #        else
        #          break
        #        fi
        #      done
        #    elif [ "${tomcat_option}" == '3' ]; then
        #      while :; do echo
        #        echo 'Please select JDK version:'
        #        echo -e "\t${CMSG}2${CEND}. Install JDK-1.8"
        #        echo -e "\t${CMSG}3${CEND}. Install JDK-1.7"
        #        echo -e "\t${CMSG}4${CEND}. Install JDK-1.6"
        #        read -p "Please input a number:(Default 3 press Enter) " jdk_option
        #        [ -z "${jdk_option}" ] && jdk_option=3
        #        if [[ ! ${jdk_option} =~ ^[2-4]$ ]]; then
        #          echo "${CWARNING}input error! Please only input number 2~4${CEND}"
        #        else
        #          break
        #        fi
        #      done
        #    elif [ "${tomcat_option}" == '4' ]; then
        #      while :; do echo
        #        echo 'Please select JDK version:'
        #        echo -e "\t${CMSG}3${CEND}. Install JDK-1.7"
        #        echo -e "\t${CMSG}4${CEND}. Install JDK-1.6"
        #        read -p "Please input a number:(Default 4 press Enter) " jdk_option
        #        [ -z "${jdk_option}" ] && jdk_option=4
        #        if [[ ! ${jdk_option} =~ ^[3-4]$ ]]; then
        #          echo "${CWARNING}input error! Please only input number 3~4${CEND}"
        #        else
        #          break
        #        fi
        #      done
        #    fi
        #    break
        #  fi
        #done
      fi
      break
    fi
  done

  # choice database
  while :; do echo
    read -p "Do you want to install Database? [y/n]: " db_yn
    if [[ ! ${db_yn} =~ ^[y,n]$ ]]; then
      echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
      if [ "${db_yn}" == 'y' ]; then
        while :; do echo
          echo 'Please select a version of the Database:'
          echo -e "\t${CMSG} 1${CEND}. Install MySQL-8.0"
          echo -e "\t${CMSG} 2${CEND}. Install MySQL-5.7"
          echo -e "\t${CMSG} 3${CEND}. Install MySQL-5.6"
          echo -e "\t${CMSG} 4${CEND}. Install MySQL-5.5"
          echo -e "\t${CMSG} 5${CEND}. Install MariaDB-10.3"
          echo -e "\t${CMSG} 6${CEND}. Install MariaDB-10.2"
          echo -e "\t${CMSG} 7${CEND}. Install MariaDB-10.1"
          echo -e "\t${CMSG} 8${CEND}. Install MariaDB-10.0"
          echo -e "\t${CMSG} 9${CEND}. Install MariaDB-5.5"
          echo -e "\t${CMSG}10${CEND}. Install Percona-5.7"
          echo -e "\t${CMSG}11${CEND}. Install Percona-5.6"
          echo -e "\t${CMSG}12${CEND}. Install Percona-5.5"
          echo -e "\t${CMSG}13${CEND}. Install AliSQL-5.6"
          echo -e "\t${CMSG}14${CEND}. Install PostgreSQL"
          echo -e "\t${CMSG}15${CEND}. Install MongoDB"
          read -p "Please input a number:(Default 2 press Enter) " db_option
          [ -z "${db_option}" ] && db_option=2
          [[ "${db_option}" =~ ^5$|^15$ ]] && [ "${OS_BIT}" == '32' ] && { echo "${CWARNING}By not supporting 32-bit! ${CEND}"; continue; }
          if [[ "${db_option}" =~ ^[1-9]$|^1[0-5]$ ]]; then
            if [ "${db_option}" == '14' ]; then
              [ -e "${pgsql_install_dir}/bin/psql" ] && { echo "${CWARNING}PostgreSQL already installed! ${CEND}"; db_option=Other; break; }
            elif [ "${db_option}" == '15' ]; then
              [ -e "${mongo_install_dir}/bin/mongo" ] && { echo "${CWARNING}MongoDB already installed! ${CEND}"; db_option=Other; break; }
            else
              [ -d "${db_install_dir}/support-files" ] && { echo "${CWARNING}MySQL already installed! ${CEND}"; db_option=Other; break; }
            fi
            while :; do
              if [ "${db_option}" == '14' ]; then
                read -p "Please input the postgres password of PostgreSQL(default: ${dbpostgrespwd}): " dbpwd
                [ -z "${dbpwd}" ] && dbpwd=${dbpostgrespwd}
              elif [ "${db_option}" == '15' ]; then
                read -p "Please input the root password of MongoDB(default: ${dbmongopwd}): " dbpwd
                [ -z "${dbpwd}" ] && dbpwd=${dbmongopwd}
              else
                read -p "Please input the root password of MySQL(default: ${dbrootpwd}): " dbpwd
                [ -z "${dbpwd}" ] && dbpwd=${dbrootpwd}
              fi
              [ -n "`echo ${dbpwd} | grep '[+|&]'`" ] && { echo "${CWARNING}input error,not contain a plus sign (+) and & ${CEND}"; continue; }
              if (( ${#dbpwd} >= 5 )); then
                if [ "${db_option}" == '14' ]; then
                  dbpostgrespwd=${dbpwd}
                elif [ "${db_option}" == '15' ]; then
                  dbmongopwd=${dbpwd}
                else
                  dbrootpwd=${dbpwd}
                fi
                break
              else
                echo "${CWARNING}password least 5 characters! ${CEND}"
              fi
            done
            # choose install methods
            if [[ "${db_option}" =~ ^[1-9]$|^1[0-2]$ ]]; then
              while :; do echo
                echo "Please choose installation of the database:"
                echo -e "\t${CMSG}1${CEND}. Install database from binary package."
                echo -e "\t${CMSG}2${CEND}. Install database from source package."
                read -p "Please input a number:(Default 1 press Enter) " dbinstallmethod
                [ -z "${dbinstallmethod}" ] && dbinstallmethod=1
                if [[ ! ${dbinstallmethod} =~ ^[1-2]$ ]]; then
                  echo "${CWARNING}input error! Please only input number 1~2${CEND}"
                else
                  [ "${db_option}" == '5' -a "${LIBC_YN}" != '0' -a "$dbinstallmethod" == '1' ] && { echo "${CWARNING}MariaDB-10.3 binaries require GLIBC 2.14 or higher! ${CEND}"; continue; }
                  break
                fi
              done
            fi
            break
          else
            echo "${CWARNING}input error! Please only input number 1~15${CEND}"
          fi
        done
      fi
      break
    fi
  done

  # check PHP
  while :; do echo
    read -p "Do you want to install PHP? [y/n]: " php_yn
    if [[ ! ${php_yn} =~ ^[y,n]$ ]]; then
      echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
      if [ "${php_yn}" == 'y' ]; then
        [ -e "${php_install_dir}/bin/phpize" ] && { echo "${CWARNING}PHP already installed! ${CEND}"; php_option=Other; break; }
        while :; do echo
          echo 'Please select a version of the PHP:'
          echo -e "\t${CMSG}1${CEND}. Install php-5.3"
          echo -e "\t${CMSG}2${CEND}. Install php-5.4"
          echo -e "\t${CMSG}3${CEND}. Install php-5.5"
          echo -e "\t${CMSG}4${CEND}. Install php-5.6"
          echo -e "\t${CMSG}5${CEND}. Install php-7.0"
          echo -e "\t${CMSG}6${CEND}. Install php-7.1"
          echo -e "\t${CMSG}7${CEND}. Install php-7.2"
          read -p "Please input a number:(Default 5 press Enter) " php_option
          [ -z "${php_option}" ] && php_option=5
          if [[ ! ${php_option} =~ ^[1-7]$ ]]; then
            echo "${CWARNING}input error! Please only input number 1~7${CEND}"
          else
            while :; do echo
              read -p "Do you want to install opcode cache of the PHP? [y/n]: " phpcache_yn
              if [[ ! ${phpcache_yn} =~ ^[y,n]$ ]]; then
                echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
              else
                if [ "${phpcache_yn}" == 'y' ]; then
                  if [ ${php_option} == 1 ]; then
                    while :; do
                      echo 'Please select a opcode cache of the PHP:'
                      echo -e "\t${CMSG}1${CEND}. Install Zend OPcache"
                      echo -e "\t${CMSG}2${CEND}. Install XCache"
                      echo -e "\t${CMSG}3${CEND}. Install APCU"
                      echo -e "\t${CMSG}4${CEND}. Install eAccelerator-0.9"
                      read -p "Please input a number:(Default 1 press Enter) " phpcache_option
                      [ -z "${phpcache_option}" ] && phpcache_option=1
                      if [[ ! ${phpcache_option} =~ ^[1-4]$ ]]; then
                        echo "${CWARNING}input error! Please only input number 1~4${CEND}"
                      else
                        break
                      fi
                    done
                  fi
                  if [ ${php_option} == 2 ]; then
                    while :; do
                      echo 'Please select a opcode cache of the PHP:'
                      echo -e "\t${CMSG}1${CEND}. Install Zend OPcache"
                      echo -e "\t${CMSG}2${CEND}. Install XCache"
                      echo -e "\t${CMSG}3${CEND}. Install APCU"
                      echo -e "\t${CMSG}4${CEND}. Install eAccelerator-1.0-dev"
                      read -p "Please input a number:(Default 1 press Enter) " phpcache_option
                      [ -z "${phpcache_option}" ] && phpcache_option=1
                      if [[ ! ${phpcache_option} =~ ^[1-4]$ ]]; then
                        echo "${CWARNING}input error! Please only input number 1~4${CEND}"
                      else
                        break
                      fi
                    done
                  fi
                  if [ ${php_option} == 3 ]; then
                    while :; do
                      echo 'Please select a opcode cache of the PHP:'
                      echo -e "\t${CMSG}1${CEND}. Install Zend OPcache"
                      echo -e "\t${CMSG}2${CEND}. Install XCache"
                      echo -e "\t${CMSG}3${CEND}. Install APCU"
                      read -p "Please input a number:(Default 1 press Enter) " phpcache_option
                      [ -z "${phpcache_option}" ] && phpcache_option=1
                      if [[ ! ${phpcache_option} =~ ^[1-3]$ ]]; then
                        echo "${CWARNING}input error! Please only input number 1~3${CEND}"
                      else
                        break
                      fi
                    done
                  fi
                  if [ ${php_option} == 4 ]; then
                    while :; do
                      echo 'Please select a opcode cache of the PHP:'
                      echo -e "\t${CMSG}1${CEND}. Install Zend OPcache"
                      echo -e "\t${CMSG}2${CEND}. Install XCache"
                      echo -e "\t${CMSG}3${CEND}. Install APCU"
                      read -p "Please input a number:(Default 1 press Enter) " phpcache_option
                      [ -z "${phpcache_option}" ] && phpcache_option=1
                      if [[ ! ${phpcache_option} =~ ^[1-3]$ ]]; then
                        echo "${CWARNING}input error! Please only input number 1~3${CEND}"
                      else
                        break
                      fi
                    done
                  fi
                  if [[ ${php_option} =~ ^[5-6]$ ]]; then
                    while :; do
                      echo 'Please select a opcode cache of the PHP:'
                      echo -e "\t${CMSG}1${CEND}. Install Zend OPcache"
                      echo -e "\t${CMSG}3${CEND}. Install APCU"
                      read -p "Please input a number:(Default 1 press Enter) " phpcache_option
                      [ -z "${phpcache_option}" ] && phpcache_option=1
                      if [[ ! ${phpcache_option} =~ ^[1,3]$ ]]; then
                        echo "${CWARNING}input error! Please only input number 1,3${CEND}"
                      else
                        break
                      fi
                    done
                  fi
                  [ ${php_option} == 7 ] && phpcache_option=1
                fi
                break
              fi
            done
            if [ "${phpcache_option}" == '2' ]; then
              while :; do
                read -p "Please input xcache admin password: " xcachepwd
                (( ${#xcachepwd} >= 5 )) && { xcachepwd_md5=$(echo -n "${xcachepwd}" | md5sum | awk '{print $1}') ; break ; } || echo "${CFAILURE}xcache admin password least 5 characters! ${CEND}"
              done
            fi
            if [[ ${php_option} =~ ^[1-4]$ ]] && [ "${phpcache_option}" != '1' -a "${armplatform}" != "y" ]; then
              while :; do echo
                read -p "Do you want to install ZendGuardLoader? [y/n]: " zendguardloader_yn
                if [[ ! ${zendguardloader_yn} =~ ^[y,n]$ ]]; then
                  echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
                else
                  break
                fi
              done
            fi

            # ionCube
            if [ "${TARGET_ARCH}" != "arm64" ]; then
              while :; do echo
                read -p "Do you want to install ionCube? [y/n]: " ioncube_yn
                if [[ ! ${ioncube_yn} =~ ^[y,n]$ ]]; then
                  echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
                else
                  break
                fi
              done
            fi

            # ImageMagick or GraphicsMagick
            while :; do echo
              read -p "Do you want to install ImageMagick or GraphicsMagick? [y/n]: " magick_yn
              if [[ ! ${magick_yn} =~ ^[y,n]$ ]]; then
                echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
              else
                break
              fi
            done

            if [ "${magick_yn}" == 'y' ]; then
              while :; do
                echo 'Please select ImageMagick or GraphicsMagick:'
                echo -e "\t${CMSG}1${CEND}. Install ImageMagick"
                echo -e "\t${CMSG}2${CEND}. Install GraphicsMagick"
                read -p "Please input a number:(Default 1 press Enter) " magick_option
                [ -z "${magick_option}" ] && magick_option=1
                if [[ ! ${magick_option} =~ ^[1-2]$ ]]; then
                  echo "${CWARNING}input error! Please only input number 1~2${CEND}"
                else
                  break
                fi
              done
            fi
            break
          fi
        done
      fi
      break
    fi
  done

  # check Pureftpd
  while :; do echo
    read -p "Do you want to install Pure-FTPd? [y/n]: " ftp_yn
    if [[ ! ${ftp_yn} =~ ^[y,n]$ ]]; then
      echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
      [ "${ftp_yn}" == 'y' -a -e "${pureftpd_install_dir}/sbin/pure-ftpwho" ] && { echo "${CWARNING}Pure-FTPd already installed! ${CEND}"; ftp_yn=Other; }
      break
    fi
  done

  # check phpMyAdmin
  if [[ ${php_option} =~ ^[1-7]$ ]] || [ -e "${php_install_dir}/bin/phpize" ]; then
    while :; do echo
      read -p "Do you want to install phpMyAdmin? [y/n]: " phpmyadmin_yn
      if [[ ! ${phpmyadmin_yn} =~ ^[y,n]$ ]]; then
        echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
      else
        [ "${phpmyadmin_yn}" == 'y' -a -d "${wwwroot_dir}/default/phpMyAdmin" ] && { echo "${CWARNING}phpMyAdmin already installed! ${CEND}"; phpmyadmin_yn=Other; }
        break
      fi
    done
  fi

  # check redis
  while :; do echo
    read -p "Do you want to install redis? [y/n]: " redis_yn
    if [[ ! ${redis_yn} =~ ^[y,n]$ ]]; then
      echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
      break
    fi
  done

  # check memcached
  while :; do echo
    read -p "Do you want to install memcached? [y/n]: " memcached_yn
    if [[ ! ${memcached_yn} =~ ^[y,n]$ ]]; then
      echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
      break
    fi
  done

  while :; do echo
    read -p "Do you want to install HHVM? [y/n]: " hhvm_yn
    if [[ ! ${hhvm_yn} =~ ^[y,n]$ ]]; then
      echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
      if [ "${hhvm_yn}" == 'y' ]; then
        [ -e "/usr/bin/hhvm" ] && { echo "${CWARNING}HHVM already installed! ${CEND}"; hhvm_yn=Other; break; }
        if [ "${OS}" == 'CentOS' -a "${OS_BIT}" == '64' ] && [ -n "`grep -E ' 7\.| 6\.[5-9]' /etc/redhat-release`" ]; then
          break
        else
          echo
          echo "${CWARNING}HHVM only support CentOS6.5+ 64bit, CentOS7 64bit! ${CEND}"
          echo "Press Ctrl+c to cancel or Press any key to continue..."
          char=`get_char`
          hhvm_yn=Other
        fi
      fi
      break
    fi
  done
fi

# get the IP information
IPADDR=`./include/get_ipaddr.py`
PUBLIC_IPADDR=`./include/get_public_ipaddr.py`
IPADDR_COUNTRY_ISP=`./include/get_ipaddr_state.py $PUBLIC_IPADDR`
IPADDR_COUNTRY=`echo $IPADDR_COUNTRY_ISP | awk '{print $1}'`

# Check download source packages
. ./include/check_download.sh
downloadDepsSrc=1
[ "${OS}" == 'CentOS' ] && yum -y -q install wget
[[ "${OS}" =~ ^Ubuntu$|^Debian$ ]] &&  apt -y -q install wget
checkDownload 2>&1 | tee -a ${oneinstack_dir}/install.log

# del openssl for jcloud
[ -e "/usr/local/bin/openssl" ] && rm -rf /usr/local/bin/openssl
[ -e "/usr/local/include/openssl" ] && rm -rf /usr/local/include/openssl

# get OS Memory
. ./include/memory.sh

if [ ! -e ~/.oneinstack ]; then
  # Check binary dependencies packages
  . ./include/check_sw.sh
  case "${OS}" in
    "CentOS")
      installDepsCentOS 2>&1 | tee ${oneinstack_dir}/install.log
      . include/init_CentOS.sh 2>&1 | tee -a ${oneinstack_dir}/install.log
      [ -n "$(gcc --version | head -n1 | grep '4\.1\.')" ] && export CC="gcc44" CXX="g++44"
      ;;
    "Debian")
      installDepsDebian 2>&1 | tee ${oneinstack_dir}/install.log
      . include/init_Debian.sh 2>&1 | tee -a ${oneinstack_dir}/install.log
      ;;
    "Ubuntu")
      installDepsUbuntu 2>&1 | tee ${oneinstack_dir}/install.log
      . include/init_Ubuntu.sh 2>&1 | tee -a ${oneinstack_dir}/install.log
      ;;
  esac
  # Install dependencies from source package
  installDepsBySrc 2>&1 | tee -a ${oneinstack_dir}/install.log
fi

# start Time
startTime=`date +%s`

# Jemalloc
if [[ ${nginx_option} =~ ^[1-3]$ ]] || [ "${db_yn}" == 'y' ]; then
  . include/jemalloc.sh
  Install_Jemalloc | tee -a ${oneinstack_dir}/install.log
fi

# openSSL
. ./include/openssl.sh
if [[ ${tomcat_option} =~ ^[1-4]$ ]] || [[ ${apache_option} =~ ^[1-2]$ ]] || [[ ${php_option} =~ ^[1-7]$ ]]; then
  Install_openSSL102 | tee -a ${oneinstack_dir}/install.log
fi

# Database
case "${db_option}" in
  1)
    [ "${OS}" == 'CentOS' -a "${CentOS_ver}" != '7' ] && dbinstallmethod=1
    . include/mysql-8.0.sh
    Install_MySQL80 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  2)
    . include/mysql-5.7.sh
    Install_MySQL57 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  3)
    . include/mysql-5.6.sh
    Install_MySQL56 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  4)
    . include/mysql-5.5.sh
    Install_MySQL55 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  5)
    . include/mariadb-10.3.sh
    Install_MariaDB103 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  6)
    . include/mariadb-10.2.sh
    Install_MariaDB102 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  7)
    . include/mariadb-10.1.sh
    Install_MariaDB101 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  8)
    . include/mariadb-10.0.sh
    Install_MariaDB100 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  9)
    . include/mariadb-5.5.sh
    Install_MariaDB55 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  10)
    . include/percona-5.7.sh
    Install_Percona57 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  11)
    . include/percona-5.6.sh
    Install_Percona56 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  12)
    . include/percona-5.5.sh
    Install_Percona55 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  13)
    . include/alisql-5.6.sh
    Install_AliSQL56 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  14)
    . include/postgresql.sh
    Install_PostgreSQL 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  15)
    . include/mongodb.sh
    Install_MongoDB 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
esac

# Apache
if [ "${apache_option}" == '1' ]; then
  . include/apache-2.4.sh
  Install_Apache24 2>&1 | tee -a ${oneinstack_dir}/install.log
elif [ "${apache_option}" == '2' ]; then
  . include/apache-2.2.sh
  Install_Apache22 2>&1 | tee -a ${oneinstack_dir}/install.log
fi

# PHP
case "${php_option}" in
  1)
    . include/php-5.3.sh
    Install_PHP53 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  2)
    . include/php-5.4.sh
    Install_PHP54 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  3)
    . include/php-5.5.sh
    Install_PHP55 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  4)
    . include/php-5.6.sh
    Install_PHP56 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  5)
    . include/php-7.0.sh
    Install_PHP70 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  6)
    . include/php-7.1.sh
    Install_PHP71 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  7)
    . include/php-7.2.sh
    Install_PHP72 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
esac

# pecl_pgsql
if [ -e "${pgsql_install_dir}/bin/psql" -a -e "${php_install_dir}/bin/phpize" ]; then
  . include/pecl_pgsql.sh
  Install_pecl-pgsql 2>&1 | tee -a ${oneinstack_dir}/install.log
fi

# pecl_mongodb
if [ -e "${mongo_install_dir}/bin/mongo" -a -e "${php_install_dir}/bin/phpize" ]; then
  . include/pecl_mongodb.sh
  Install_pecl-mongodb 2>&1 | tee -a ${oneinstack_dir}/install.log
fi

# ImageMagick or GraphicsMagick
if [ "${magick_option}" == '1' ]; then
  . include/ImageMagick.sh
  [ ! -d "${imagick_install_dir}" ] && Install_ImageMagick 2>&1 | tee -a ${oneinstack_dir}/install.log
  [ ! -e "`${php_install_dir}/bin/php-config --extension-dir`/imagick.so" ] && Install_php-imagick 2>&1 | tee -a ${oneinstack_dir}/install.log
elif [ "${magick_option}" == '2' ]; then
  . include/GraphicsMagick.sh
  [ ! -d "${gmagick_install_dir}" ] && Install_GraphicsMagick 2>&1 | tee -a ${oneinstack_dir}/install.log
  [ ! -e "`${php_install_dir}/bin/php-config --extension-dir`/gmagick.so" ] && Install_php-gmagick 2>&1 | tee -a ${oneinstack_dir}/install.log
fi

# ionCube
if [ "${ioncube_yn}" == 'y' ]; then
  . include/ioncube.sh
  Install_ionCube 2>&1 | tee -a ${oneinstack_dir}/install.log
fi

# PHP opcode cache
case "${phpcache_option}" in
  1)
    if [[ "${php_option}" =~ ^[1,2]$ ]]; then
      . include/zendopcache.sh
      Install_ZendOPcache 2>&1 | tee -a ${oneinstack_dir}/install.log
    fi
    ;;
  2)
    . include/xcache.sh
    Install_XCache 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  3)
    . include/apcu.sh
    Install_APCU 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  4)
    if [[ "${php_option}" =~ ^[1,2]$ ]]; then
      . include/eaccelerator.sh
      Install_eAccelerator 2>&1 | tee -a ${oneinstack_dir}/install.log
    fi
    ;;
esac

# ZendGuardLoader (php <= 5.6)
if [ "${zendguardloader_yn}" == 'y' ]; then
  . include/ZendGuardLoader.sh
  Install_ZendGuardLoader 2>&1 | tee -a ${oneinstack_dir}/install.log
fi

# Web server
case "${nginx_option}" in
  1)
    . include/nginx.sh
    Install_Nginx 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  2)
    . include/tengine.sh
    Install_Tengine 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  3)
    . include/openresty.sh
    Install_OpenResty 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
esac

# JDK
case "${jdk_option}" in
  1)
    . include/jdk-10.sh
    Install-JDK10 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  2)
    . include/jdk-1.8.sh
    Install-JDK18 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  3)
    . include/jdk-1.7.sh
    Install-JDK17 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  4)
    . include/jdk-1.6.sh
    Install-JDK16 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
esac

case "${tomcat_option}" in
  1)
    . include/tomcat-9.sh
    Install_Tomcat9 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  2)
    . include/tomcat-8.sh
    Install_Tomcat8 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  3)
    . include/tomcat-7.sh
    Install_Tomcat7 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
  4)
    . include/tomcat-6.sh
    Install_Tomcat6 2>&1 | tee -a ${oneinstack_dir}/install.log
    ;;
esac

# Pure-FTPd
if [ "${ftp_yn}" == 'y' ]; then
  . include/pureftpd.sh
  Install_PureFTPd 2>&1 | tee -a ${oneinstack_dir}/install.log
fi

# phpMyAdmin
if [ "${phpmyadmin_yn}" == 'y' ]; then
  . include/phpmyadmin.sh
  Install_phpMyAdmin 2>&1 | tee -a ${oneinstack_dir}/install.log
fi

# redis
if [ "${redis_yn}" == 'y' ]; then
  . include/redis.sh
  [ ! -d "${redis_install_dir}" ] && Install_redis-server 2>&1 | tee -a ${oneinstack_dir}/install.log
  [ -e "${php_install_dir}/bin/phpize" ] && [ ! -e "$(${php_install_dir}/bin/php-config --extension-dir)/redis.so" ] && Install_php-redis 2>&1 | tee -a ${oneinstack_dir}/install.log
fi

# memcached
if [ "${memcached_yn}" == 'y' ]; then
  . include/memcached.sh
  [ ! -d "${memcached_install_dir}/include/memcached" ] && Install_memcached 2>&1 | tee -a ${oneinstack_dir}/install.log
  [ -e "${php_install_dir}/bin/phpize" ] && [ ! -e "$(${php_install_dir}/bin/php-config --extension-dir)/memcache.so" ] && Install_php-memcache 2>&1 | tee -a ${oneinstack_dir}/install.log
  [ -e "${php_install_dir}/bin/phpize" ] && [ ! -e "$(${php_install_dir}/bin/php-config --extension-dir)/memcached.so" ] && Install_php-memcached 2>&1 | tee -a ${oneinstack_dir}/install.log
fi

# index example
if [ ! -e "${wwwroot_dir}/default/index.html" -a "${web_yn}" == 'y' ]; then
  . include/demo.sh
  DEMO 2>&1 | tee -a ${oneinstack_dir}/install.log
fi

# get web_install_dir and db_install_dir
. include/check_dir.sh

# HHVM
if [ "${hhvm_yn}" == 'y' ] && [ "${OS}" == 'CentOS' -a "${OS_BIT}" == '64' ] && [ -n "`grep -E ' 7\.| 6\.[5-9]' /etc/redhat-release`" ]; then
  . include/hhvm_CentOS.sh
  Install_hhvm_CentOS 2>&1 | tee -a ${oneinstack_dir}/install.log
fi

# Starting DB
[ -d "/etc/mysql" ] && /bin/mv /etc/mysql{,_bk}
[ -d "${db_install_dir}/support-files" ] && service mysqld start
endTime=`date +%s`
((installTime=($endTime-$startTime)/60))
echo "####################Congratulations########################"
echo "Total OneinStack Install Time: ${CQUESTION}${installTime}${CEND} minutes"
[ "${web_yn}" == 'y' ] && [[ "${nginx_option}" =~ ^[1-3]$ ]] && echo -e "\n$(printf "%-32s" "Nginx install dir":)${CMSG}${web_install_dir}${CEND}"
[ "${web_yn}" == 'y' ] && [[ "${apache_option}" =~ ^[1,2]$ ]] && echo -e "\n$(printf "%-32s" "Apache install dir":)${CMSG}${apache_install_dir}${CEND}"
[[ "${tomcat_option}" =~ ^[1,2]$ ]] && echo -e "\n$(printf "%-32s" "Tomcat install dir":)${CMSG}${tomcat_install_dir}${CEND}"
[[ "${db_option}" =~ ^[1-9]$|^1[0-3]$ ]] && echo -e "\n$(printf "%-32s" "Database install dir:")${CMSG}${db_install_dir}${CEND}"
[[ "${db_option}" =~ ^[1-9]$|^1[0-3]$ ]] && echo "$(printf "%-32s" "Database data dir:")${CMSG}${db_data_dir}${CEND}"
[[ "${db_option}" =~ ^[1-9]$|^1[0-3]$ ]] && echo "$(printf "%-32s" "Database user:")${CMSG}root${CEND}"
[[ "${db_option}" =~ ^[1-9]$|^1[0-3]$ ]] && echo "$(printf "%-32s" "Database password:")${CMSG}${dbrootpwd}${CEND}"
[ "${db_option}" == '14' ] && echo -e "\n$(printf "%-32s" "PostgreSQL install dir:")${CMSG}${pgsql_install_dir}${CEND}"
[ "${db_option}" == '14' ] && echo "$(printf "%-32s" "PostgreSQL data dir:")${CMSG}${pgsql_data_dir}${CEND}"
[ "${db_option}" == '14' ] && echo "$(printf "%-32s" "PostgreSQL user:")${CMSG}postgres${CEND}"
[ "${db_option}" == '14' ] && echo "$(printf "%-32s" "postgres password:")${CMSG}${dbpostgrespwd}${CEND}"
[ "${db_option}" == '15' ] && echo -e "\n$(printf "%-32s" "MongoDB install dir:")${CMSG}${mongo_install_dir}${CEND}"
[ "${db_option}" == '15' ] && echo "$(printf "%-32s" "MongoDB data dir:")${CMSG}${mongo_data_dir}${CEND}"
[ "${db_option}" == '15' ] && echo "$(printf "%-32s" "MongoDB user:")${CMSG}root${CEND}"
[ "${db_option}" == '15' ] && echo "$(printf "%-32s" "MongoDB password:")${CMSG}${dbmongopwd}${CEND}"
[ "${php_yn}" == 'y' ] && echo -e "\n$(printf "%-32s" "PHP install dir:")${CMSG}${php_install_dir}${CEND}"
[ "${php_yn}" == 'y' -a "${phpcache_option}" == '1' ] && echo "$(printf "%-32s" "Opcache Control Panel URL:")${CMSG}http://${IPADDR}/ocp.php${CEND}"
[ "${phpcache_option}" == '2' ] && echo "$(printf "%-32s" "xcache Control Panel URL:")${CMSG}http://${IPADDR}/xcache${CEND}"
[ "${phpcache_option}" == '2' ] && echo "$(printf "%-32s" "xcache user:")${CMSG}admin${CEND}"
[ "${phpcache_option}" == '2' ] && echo "$(printf "%-32s" "xcache password:")${CMSG}${xcachepwd}${CEND}"
[ "${phpcache_option}" == '3' ] && echo "$(printf "%-32s" "APC Control Panel URL:")${CMSG}http://${IPADDR}/apc.php${CEND}"
[ "${phpcache_option}" == '4' ] && echo "$(printf "%-32s" "eAccelerator Control Panel URL:")${CMSG}http://${IPADDR}/control.php${CEND}"
[ "${phpcache_option}" == '4' ] && echo "$(printf "%-32s" "eAccelerator user:")${CMSG}admin${CEND}"
[ "${phpcache_option}" == '4' ] && echo "$(printf "%-32s" "eAccelerator password:")${CMSG}eAccelerator${CEND}"
[ "${ftp_yn}" == 'y' ] && echo -e "\n$(printf "%-32s" "Pure-FTPd install dir:")${CMSG}${pureftpd_install_dir}${CEND}"
[ "${ftp_yn}" == 'y' ] && echo "$(printf "%-32s" "Create FTP virtual script:")${CMSG}./pureftpd_vhost.sh${CEND}"
[ "${phpmyadmin_yn}" == 'y' ] && echo -e "\n$(printf "%-32s" "phpMyAdmin dir:")${CMSG}${wwwroot_dir}/default/phpMyAdmin${CEND}"
[ "${phpmyadmin_yn}" == 'y' ] && echo "$(printf "%-32s" "phpMyAdmin Control Panel URL:")${CMSG}http://${IPADDR}/phpMyAdmin${CEND}"
[ "${redis_yn}" == 'y' ] && echo -e "\n$(printf "%-32s" "redis install dir:")${CMSG}${redis_install_dir}${CEND}"
[ "${memcached_yn}" == 'y' ] && echo -e "\n$(printf "%-32s" "memcached install dir:")${CMSG}${memcached_install_dir}${CEND}"
[ "${web_yn}" == 'y' ] && echo -e "\n$(printf "%-32s" "Index URL:")${CMSG}http://${IPADDR}/${CEND}"
if [ ${ARG_NUM} == 0 ]; then
  while :; do echo
    echo "${CMSG}Please restart the server and see if the services start up fine.${CEND}"
    read -p "Do you want to restart OS ? [y/n]: " reboot_yn
    if [[ ! "${reboot_yn}" =~ ^[y,n]$ ]]; then
      echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
      break
    fi
  done
fi
[ "${reboot_yn}" == 'y' ] && reboot
