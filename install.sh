#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#######################################################################
#       OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+      #
#       For more information please visit https://oneinstack.com      #
#######################################################################
"

# get pwd
sed -i "s@^oneinstack_dir.*@oneinstack_dir=`pwd`@" ./options.conf

. ./versions.txt
. ./options.conf
. ./include/color.sh
. ./include/check_os.sh
. ./include/check_dir.sh
. ./include/download.sh
. ./include/get_char.sh

# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

mkdir -p $wwwroot_dir/default $wwwlogs_dir
[ -d /data ] && chmod 755 /data

# Use default SSH port 22. If you use another SSH port on your server
if [ -e "/etc/ssh/sshd_config" ];then
    [ -z "`grep ^Port /etc/ssh/sshd_config`" ] && ssh_port=22 || ssh_port=`grep ^Port /etc/ssh/sshd_config | awk '{print $2}'`
    while :; do echo
        read -p "Please input SSH port(Default: $ssh_port): " SSH_PORT
        [ -z "$SSH_PORT" ] && SSH_PORT=$ssh_port
        if [ $SSH_PORT -eq 22 >/dev/null 2>&1 -o $SSH_PORT -gt 1024 >/dev/null 2>&1 -a $SSH_PORT -lt 65535 >/dev/null 2>&1 ];then
            break
        else
            echo "${CWARNING}input error! Input range: 22,1025~65534${CEND}"
        fi
    done

    if [ -z "`grep ^Port /etc/ssh/sshd_config`" -a "$SSH_PORT" != '22' ];then
        sed -i "s@^#Port.*@&\nPort $SSH_PORT@" /etc/ssh/sshd_config
    elif [ -n "`grep ^Port /etc/ssh/sshd_config`" ];then
        sed -i "s@^Port.*@Port $SSH_PORT@" /etc/ssh/sshd_config
    fi
fi

# check Web server
while :; do echo
    read -p "Do you want to install Web server? [y/n]: " Web_yn
    if [[ ! $Web_yn =~ ^[y,n]$ ]];then
        echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
        if [ "$Web_yn" == 'y' ];then
            # Nginx/Tegine/OpenResty
            while :; do echo
                echo 'Please select Nginx server:'
                echo -e "\t${CMSG}1${CEND}. Install Nginx"
                echo -e "\t${CMSG}2${CEND}. Install Tengine"
                echo -e "\t${CMSG}3${CEND}. Install OpenResty"
                echo -e "\t${CMSG}4${CEND}. Do not install"
                read -p "Please input a number:(Default 1 press Enter) " Nginx_version
                [ -z "$Nginx_version" ] && Nginx_version=1
                if [[ ! $Nginx_version =~ ^[1-4]$ ]];then
                    echo "${CWARNING}input error! Please only input number 1,2,3,4${CEND}"
                else
                    [ "$Nginx_version" != '4' -a -e "$nginx_install_dir/sbin/nginx" ] && { echo "${CWARNING}Nginx already installed! ${CEND}"; Nginx_version=Other; }
                    [ "$Nginx_version" != '4' -a -e "$tengine_install_dir/sbin/nginx" ] && { echo "${CWARNING}Tengine already installed! ${CEND}"; Nginx_version=Other; }
                    [ "$Nginx_version" != '4' -a -e "$openresty_install_dir/nginx/sbin/nginx" ] && { echo "${CWARNING}OpenResty already installed! ${CEND}"; Nginx_version=Other; }
                    break
                fi
            done
            # Apache
            while :; do echo
                echo 'Please select Apache server:'
                echo -e "\t${CMSG}1${CEND}. Install Apache-2.4"
                echo -e "\t${CMSG}2${CEND}. Install Apache-2.2"
                echo -e "\t${CMSG}3${CEND}. Do not install"
                read -p "Please input a number:(Default 3 press Enter) " Apache_version
                [ -z "$Apache_version" ] && Apache_version=3
                if [[ ! $Apache_version =~ ^[1-3]$ ]];then
                    echo "${CWARNING}input error! Please only input number 1,2,3${CEND}"
                else
                    [ "$Apache_version" != '3' -a -e "$apache_install_dir/conf/httpd.conf" ] && { echo "${CWARNING}Aapche already installed! ${CEND}"; Apache_version=Other; }
                    break
                fi
            done
            # Tomcat
            #while :; do echo
            #    echo 'Please select tomcat server:'
            #    echo -e "\t${CMSG}1${CEND}. Install Tomcat-8"
            #    echo -e "\t${CMSG}2${CEND}. Install Tomcat-7"
            #    echo -e "\t${CMSG}3${CEND}. Install Tomcat-6"
            #    echo -e "\t${CMSG}4${CEND}. Do not install"
            #    read -p "Please input a number:(Default 4 press Enter) " Tomcat_version
            #    [ -z "$Tomcat_version" ] && Tomcat_version=4
            #    if [[ ! $Tomcat_version =~ ^[1-4]$ ]];then
            #        echo "${CWARNING}input error! Please only input number 1,2,3,4${CEND}"
            #    else
            #        [ "$Tomcat_version" != '4' -a -e "$tomcat_install_dir/conf/server.xml" ] && { echo "${CWARNING}Tomcat already installed! ${CEND}" ; Tomcat_version=Other; }
            #        if [ "$Tomcat_version" == '1' ];then
            #            while :; do echo
            #                echo 'Please select JDK version:'
            #                echo -e "\t${CMSG}1${CEND}. Install JDK-1.8"
            #                echo -e "\t${CMSG}2${CEND}. Install JDK-1.7"
            #                read -p "Please input a number:(Default 2 press Enter) " JDK_version
            #                [ -z "$JDK_version" ] && JDK_version=2
            #                if [[ ! $JDK_version =~ ^[1-2]$ ]];then
            #                    echo "${CWARNING}input error! Please only input number 1,2${CEND}"
            #                else
            #                    break
            #                fi
            #            done
            #        elif [ "$Tomcat_version" == '2' ];then
            #            while :; do echo
            #                echo 'Please select JDK version:'
            #                echo -e "\t${CMSG}1${CEND}. Install JDK-1.8"
            #                echo -e "\t${CMSG}2${CEND}. Install JDK-1.7"
            #                echo -e "\t${CMSG}3${CEND}. Install JDK-1.6"
            #                read -p "Please input a number:(Default 2 press Enter) " JDK_version
            #                [ -z "$JDK_version" ] && JDK_version=2
            #                if [[ ! $JDK_version =~ ^[1-3]$ ]];then
            #                    echo "${CWARNING}input error! Please only input number 1,2,3${CEND}"
            #                else
            #                    break
            #                fi
            #            done
            #        elif [ "$Tomcat_version" == '3' ];then
            #            while :; do echo
            #                echo 'Please select JDK version:'
            #                echo -e "\t${CMSG}2${CEND}. Install JDK-1.7"
            #                echo -e "\t${CMSG}3${CEND}. Install JDK-1.6"
            #                read -p "Please input a number:(Default 2 press Enter) " JDK_version
            #                [ -z "$JDK_version" ] && JDK_version=2
            #                if [[ ! $JDK_version =~ ^[2-3]$ ]];then
            #                    echo "${CWARNING}input error! Please only input number 2,3${CEND}"
            #                else
            #                    break
            #                fi
            #            done
            #        fi
            #        break
            #    fi
            #done
        fi
        break
    fi
done

# choice database
while :; do echo
    read -p "Do you want to install Database? [y/n]: " DB_yn
    if [[ ! $DB_yn =~ ^[y,n]$ ]];then
        echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
        if [ "$DB_yn" == 'y' ];then
            [ -d "$db_install_dir/support-files" ] && { echo "${CWARNING}Database already installed! ${CEND}"; DB_yn=Other; break; }
            while :; do echo
                echo 'Please select a version of the Database:'
                echo -e "\t${CMSG}1${CEND}. Install MySQL-5.7"
                echo -e "\t${CMSG}2${CEND}. Install MySQL-5.6"
                echo -e "\t${CMSG}3${CEND}. Install MySQL-5.5"
                echo -e "\t${CMSG}4${CEND}. Install MariaDB-10.1"
                echo -e "\t${CMSG}5${CEND}. Install MariaDB-10.0"
                echo -e "\t${CMSG}6${CEND}. Install MariaDB-5.5"
                echo -e "\t${CMSG}7${CEND}. Install Percona-5.7"
                echo -e "\t${CMSG}8${CEND}. Install Percona-5.6"
                echo -e "\t${CMSG}9${CEND}. Install Percona-5.5"
                read -p "Please input a number:(Default 2 press Enter) " DB_version
                [ -z "$DB_version" ] && DB_version=2
                if [[ ! $DB_version =~ ^[1-9]$ ]];then
                    echo "${CWARNING}input error! Please only input number 1,2,3,4,5,6,7,8,9${CEND}"
                else
                    while :; do
                        read -p "Please input the root password of database: " dbrootpwd
                        [ -n "`echo $dbrootpwd | grep '[+|&]'`" ] && { echo "${CWARNING}input error,not contain a plus sign (+) and & ${CEND}"; continue; }
                        (( ${#dbrootpwd} >= 5 )) && sed -i "s+^dbrootpwd.*+dbrootpwd='$dbrootpwd'+" ./options.conf && break || echo "${CWARNING}database root password least 5 characters! ${CEND}"
                    done
                    break
                fi
            done
        fi
        break
    fi
done

# check PHP
while :; do echo
    read -p "Do you want to install PHP? [y/n]: " PHP_yn
    if [[ ! $PHP_yn =~ ^[y,n]$ ]];then
        echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
        if [ "$PHP_yn" == 'y' ];then
            [ -e "$php_install_dir/bin/phpize" ] && { echo "${CWARNING}PHP already installed! ${CEND}"; PHP_yn=Other; break; }
            while :; do echo
                echo 'Please select a version of the PHP:'
                echo -e "\t${CMSG}1${CEND}. Install php-5.3"
                echo -e "\t${CMSG}2${CEND}. Install php-5.4"
                echo -e "\t${CMSG}3${CEND}. Install php-5.5"
                echo -e "\t${CMSG}4${CEND}. Install php-5.6"
                echo -e "\t${CMSG}5${CEND}. Install php-7"
                read -p "Please input a number:(Default 3 press Enter) " PHP_version
                [ -z "$PHP_version" ] && PHP_version=3
                if [[ ! $PHP_version =~ ^[1-5]$ ]];then
                    echo "${CWARNING}input error! Please only input number 1,2,3,4,5${CEND}"
                else
                    while :; do echo
                        read -p "Do you want to install opcode cache of the PHP? [y/n]: " PHP_cache_yn
                        if [[ ! $PHP_cache_yn =~ ^[y,n]$ ]];then
                            echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
                        else
                            if [ "$PHP_cache_yn" == 'y' ];then
                                if [ $PHP_version == 1 ];then
                                    while :; do
                                        echo 'Please select a opcode cache of the PHP:'
                                        echo -e "\t${CMSG}1${CEND}. Install Zend OPcache"
                                        echo -e "\t${CMSG}2${CEND}. Install XCache"
                                        echo -e "\t${CMSG}3${CEND}. Install APCU"
                                        echo -e "\t${CMSG}4${CEND}. Install eAccelerator-0.9"
                                        read -p "Please input a number:(Default 1 press Enter) " PHP_cache
                                        [ -z "$PHP_cache" ] && PHP_cache=1
                                        if [[ ! $PHP_cache =~ ^[1-4]$ ]];then
                                            echo "${CWARNING}input error! Please only input number 1,2,3,4${CEND}"
                                        else
                                            break
                                        fi
                                    done
                                fi
                                if [ $PHP_version == 2 ];then
                                    while :; do
                                        echo 'Please select a opcode cache of the PHP:'
                                        echo -e "\t${CMSG}1${CEND}. Install Zend OPcache"
                                        echo -e "\t${CMSG}2${CEND}. Install XCache"
                                        echo -e "\t${CMSG}3${CEND}. Install APCU"
                                        echo -e "\t${CMSG}4${CEND}. Install eAccelerator-1.0-dev"
                                        read -p "Please input a number:(Default 1 press Enter) " PHP_cache
                                        [ -z "$PHP_cache" ] && PHP_cache=1
                                        if [[ ! $PHP_cache =~ ^[1-4]$ ]];then
                                            echo "${CWARNING}input error! Please only input number 1,2,3,4${CEND}"
                                        else
                                            break
                                        fi
                                    done
                                fi
                                if [ $PHP_version == 3 ];then
                                    while :; do
                                        echo 'Please select a opcode cache of the PHP:'
                                        echo -e "\t${CMSG}1${CEND}. Install Zend OPcache"
                                        echo -e "\t${CMSG}2${CEND}. Install XCache"
                                        echo -e "\t${CMSG}3${CEND}. Install APCU"
                                        read -p "Please input a number:(Default 1 press Enter) " PHP_cache
                                        [ -z "$PHP_cache" ] && PHP_cache=1
                                        if [[ ! $PHP_cache =~ ^[1-3]$ ]];then
                                            echo "${CWARNING}input error! Please only input number 1,2,3${CEND}"
                                        else
                                            break
                                        fi
                                    done
                                fi
                                if [ $PHP_version == 4 ];then
                                    while :; do
                                        echo 'Please select a opcode cache of the PHP:'
                                        echo -e "\t${CMSG}1${CEND}. Install Zend OPcache"
                                        echo -e "\t${CMSG}2${CEND}. Install XCache"
                                        read -p "Please input a number:(Default 1 press Enter) " PHP_cache
                                        [ -z "$PHP_cache" ] && PHP_cache=1
                                        if [[ ! $PHP_cache =~ ^[1-2]$ ]];then
                                            echo "${CWARNING}input error! Please only input number 1,2${CEND}"
                                        else
                                            break
                                        fi
                                    done
                                fi
                                if [ $PHP_version == 5 ];then
                                    while :; do
                                        echo 'Please select a opcode cache of the PHP:'
                                        echo -e "\t${CMSG}1${CEND}. Install Zend OPcache"
                                        read -p "Please input a number:(Default 1 press Enter) " PHP_cache
                                        [ -z "$PHP_cache" ] && PHP_cache=1
                                        if [ $PHP_cache != 1 ];then
                                            echo "${CWARNING}input error! Please only input number 1${CEND}"
                                        else
                                            break
                                        fi
                                    done
                                fi
                            fi
                            break
                        fi
                    done
                    if [ "$PHP_cache" == '2' ];then
                        while :; do
                            read -p "Please input xcache admin password: " xcache_admin_pass
                            (( ${#xcache_admin_pass} >= 5 )) && { xcache_admin_md5_pass=`echo -n "$xcache_admin_pass" | md5sum | awk '{print $1}'` ; break ; } || echo "${CFAILURE}xcache admin password least 5 characters! ${CEND}"
                        done
                    fi
                    if [ "$PHP_version" != '5' -a "$PHP_cache" != '1' ];then
                        while :; do echo
                            read -p "Do you want to install ZendGuardLoader? [y/n]: " ZendGuardLoader_yn
                            if [[ ! $ZendGuardLoader_yn =~ ^[y,n]$ ]];then
                                echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
                            else
                                break
                            fi
                        done
                    fi

                    if [ "$PHP_version" != '5' ];then
                        while :; do echo
                            read -p "Do you want to install ionCube? [y/n]: " ionCube_yn
                            if [[ ! $ionCube_yn =~ ^[y,n]$ ]];then
                                echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
                            else
                                break
                            fi
                        done
                    fi

                    # ImageMagick or GraphicsMagick
                    while :; do echo
                        read -p "Do you want to install ImageMagick or GraphicsMagick? [y/n]: " Magick_yn
                        if [[ ! $Magick_yn =~ ^[y,n]$ ]];then
                            echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
                        else
                            break
                        fi
                    done

                    if [ "$Magick_yn" == 'y' ];then
                        while :; do
                            echo 'Please select ImageMagick or GraphicsMagick:'
                            echo -e "\t${CMSG}1${CEND}. Install ImageMagick"
                            echo -e "\t${CMSG}2${CEND}. Install GraphicsMagick"
                            read -p "Please input a number:(Default 1 press Enter) " Magick
                            [ -z "$Magick" ] && Magick=1
                            if [[ ! $Magick =~ ^[1-2]$ ]];then
                                echo "${CWARNING}input error! Please only input number 1,2${CEND}"
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
    read -p "Do you want to install Pure-FTPd? [y/n]: " FTP_yn
    if [[ ! $FTP_yn =~ ^[y,n]$ ]];then
        echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
        [ "$FTP_yn" == 'y' -a -e "$pureftpd_install_dir/sbin/pure-ftpwho" ] && { echo "${CWARNING}Pure-FTPd already installed! ${CEND}"; FTP_yn=Other; }
        break
    fi
done

# check phpMyAdmin
if [[ $PHP_version =~ ^[1-5]$ ]] || [ -e "$php_install_dir/bin/phpize" ];then
    while :; do echo
        read -p "Do you want to install phpMyAdmin? [y/n]: " phpMyAdmin_yn
        if [[ ! $phpMyAdmin_yn =~ ^[y,n]$ ]];then
            echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
        else
            [ "$phpMyAdmin_yn" == 'y' -a -d "$wwwroot_dir/default/phpMyAdmin" ] && { echo "${CWARNING}phpMyAdmin already installed! ${CEND}"; phpMyAdmin_yn=Other; }
            break
        fi
    done
fi

# check redis
while :; do echo
    read -p "Do you want to install redis? [y/n]: " redis_yn
    if [[ ! $redis_yn =~ ^[y,n]$ ]];then
        echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
        break
    fi
done

# check memcached
while :; do echo
    read -p "Do you want to install memcached? [y/n]: " memcached_yn
    if [[ ! $memcached_yn =~ ^[y,n]$ ]];then
        echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
        break
    fi
done

# check jemalloc or tcmalloc
if [[ $Nginx_version =~ ^[1-3]$ ]] || [ "$DB_yn" == 'y' ];then
    while :; do echo
        read -p "Do you want to use jemalloc or tcmalloc optimize Database and Web server? [y/n]: " je_tc_malloc_yn
        if [[ ! $je_tc_malloc_yn =~ ^[y,n]$ ]];then
            echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
        else
            if [ "$je_tc_malloc_yn" == 'y' ];then
                echo 'Please select jemalloc or tcmalloc:'
                echo -e "\t${CMSG}1${CEND}. jemalloc"
                echo -e "\t${CMSG}2${CEND}. tcmalloc"
                while :; do
                    read -p "Please input a number:(Default 1 press Enter) " je_tc_malloc
                    [ -z "$je_tc_malloc" ] && je_tc_malloc=1
                    if [[ ! $je_tc_malloc =~ ^[1-2]$ ]];then
                        echo "${CWARNING}input error! Please only input number 1,2${CEND}"
                    else
                        break
                    fi
                done
            fi
            break
        fi
    done
fi

while :; do echo
    read -p "Do you want to install HHVM? [y/n]: " HHVM_yn
    if [[ ! $HHVM_yn =~ ^[y,n]$ ]];then
        echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
        if [ "$HHVM_yn" == 'y' ];then
            [ -e "/usr/bin/hhvm" ] && { echo "${CWARNING}HHVM already installed! ${CEND}"; HHVM_yn=Other; break; }
            if [ "$OS" == 'CentOS' -a "$OS_BIT" == '64' ] && [ -n "`grep -E ' 7\.| 6\.[5-9]' /etc/redhat-release`" ];then
                break
            else
                echo
                echo "${CWARNING}HHVM only support CentOS6.5+ 64bit, CentOS7 64bit! ${CEND}"
                echo "Press Ctrl+c to cancel or Press any key to continue..."
                char=`get_char`
                HHVM_yn=Other
            fi
        fi
        break
    fi
done

# get the IP information
IPADDR=`./include/get_ipaddr.py`
PUBLIC_IPADDR=`./include/get_public_ipaddr.py`
IPADDR_COUNTRY_ISP=`./include/get_ipaddr_state.py $PUBLIC_IPADDR`
IPADDR_COUNTRY=`echo $IPADDR_COUNTRY_ISP | awk '{print $1}'`
[ "`echo $IPADDR_COUNTRY_ISP | awk '{print $2}'`"x == '1000323'x ] && IPADDR_ISP=aliyun

# init
. ./include/memory.sh
if [ "$OS" == 'CentOS' ];then
    . include/init_CentOS.sh 2>&1 | tee $oneinstack_dir/install.log
    [ -n "`gcc --version | head -n1 | grep '4\.1\.'`" ] && export CC="gcc44" CXX="g++44"
elif [ "$OS" == 'Debian' ];then
    . include/init_Debian.sh 2>&1 | tee $oneinstack_dir/install.log
elif [ "$OS" == 'Ubuntu' ];then
    . include/init_Ubuntu.sh 2>&1 | tee $oneinstack_dir/install.log
fi

# jemalloc or tcmalloc
if [ "$je_tc_malloc_yn" == 'y' -a "$je_tc_malloc" == '1' -a ! -e "/usr/local/lib/libjemalloc.so" ];then
    . include/jemalloc.sh
    Install_jemalloc | tee -a $oneinstack_dir/install.log
fi
if [ "$DB_version" == '4' -a ! -e "/usr/local/lib/libjemalloc.so" ];then
    . include/jemalloc.sh
    Install_jemalloc | tee -a $oneinstack_dir/install.log
fi
if [ "$je_tc_malloc_yn" == 'y' -a "$je_tc_malloc" == '2' -a ! -e "/usr/local/lib/libtcmalloc.so" ];then
    . include/tcmalloc.sh
    Install_tcmalloc | tee -a $oneinstack_dir/install.log
fi

# Database
if [ "$DB_version" == '1' ];then
    . include/mysql-5.7.sh
    Install_MySQL-5-7 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$DB_version" == '2' ];then
    . include/mysql-5.6.sh
    Install_MySQL-5-6 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$DB_version" == '3' ];then
    . include/mysql-5.5.sh
    Install_MySQL-5-5 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$DB_version" == '4' ];then
    . include/mariadb-10.1.sh
    Install_MariaDB-10-1 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$DB_version" == '5' ];then
    . include/mariadb-10.0.sh
    Install_MariaDB-10-0 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$DB_version" == '6' ];then
    . include/mariadb-5.5.sh
    Install_MariaDB-5-5 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$DB_version" == '7' ];then
    . include/percona-5.7.sh
    Install_Percona-5-7 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$DB_version" == '8' ];then
    . include/percona-5.6.sh
    Install_Percona-5-6 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$DB_version" == '9' ];then
    . include/percona-5.5.sh
    Install_Percona-5-5 2>&1 | tee -a $oneinstack_dir/install.log
fi

# Apache
if [ "$Apache_version" == '1' ];then
    . include/apache-2.4.sh
    Install_Apache-2-4 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$Apache_version" == '2' ];then
    . include/apache-2.2.sh
    Install_Apache-2-2 2>&1 | tee -a $oneinstack_dir/install.log
fi

# PHP
if [ "$PHP_version" == '1' ];then
    . include/php-5.3.sh
    Install_PHP-5-3 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$PHP_version" == '2' ];then
    . include/php-5.4.sh
    Install_PHP-5-4 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$PHP_version" == '3' ];then
    . include/php-5.5.sh
    Install_PHP-5-5 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$PHP_version" == '4' ];then
    . include/php-5.6.sh
    Install_PHP-5-6 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$PHP_version" == '5' ];then
    . include/php-7.sh
    Install_PHP-7 2>&1 | tee -a $oneinstack_dir/install.log
fi

# ImageMagick or GraphicsMagick
if [ "$Magick" == '1' ];then
    . include/ImageMagick.sh
    [ ! -d "/usr/local/imagemagick" ] && Install_ImageMagick 2>&1 | tee -a $oneinstack_dir/install.log
    [ ! -e "`$php_install_dir/bin/php-config --extension-dir`/imagick.so" ] && Install_php-imagick 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$Magick" == '2' ];then
    . include/GraphicsMagick.sh
    [ ! -d "/usr/local/graphicsmagick" ] && Install_GraphicsMagick 2>&1 | tee -a $oneinstack_dir/install.log
    [ ! -e "`$php_install_dir/bin/php-config --extension-dir`/gmagick.so" ] && Install_php-gmagick 2>&1 | tee -a $oneinstack_dir/install.log
fi

# ionCube
if [ "$ionCube_yn" == 'y' ];then
    . include/ioncube.sh
    Install_ionCube 2>&1 | tee -a $oneinstack_dir/install.log
fi

# PHP opcode cache
if [ "$PHP_cache" == '1' ] && [[ "$PHP_version" =~ ^[1,2]$ ]];then
    . include/zendopcache.sh
    Install_ZendOPcache 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$PHP_cache" == '2' ];then
    . include/xcache.sh
    Install_XCache 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$PHP_cache" == '3' ];then
    . include/apcu.sh
    Install_APCU 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$PHP_cache" == '4' -a "$PHP_version" == '2' ];then
    . include/eaccelerator-1.0-dev.sh
    Install_eAccelerator-1-0-dev 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$PHP_cache" == '4' -a "$PHP_version" == '1' ];then
    . include/eaccelerator-0.9.sh
    Install_eAccelerator-0-9 2>&1 | tee -a $oneinstack_dir/install.log
fi

# ZendGuardLoader (php <= 5.6)
if [ "$ZendGuardLoader_yn" == 'y' ];then
    . include/ZendGuardLoader.sh
    Install_ZendGuardLoader 2>&1 | tee -a $oneinstack_dir/install.log
fi

# Web server
if [ "$Nginx_version" == '1' ];then
    . include/nginx.sh
    Install_Nginx 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$Nginx_version" == '2' ];then
    . include/tengine.sh
    Install_Tengine 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$Nginx_version" == '3' ];then
    . include/openresty.sh
    Install_OpenResty 2>&1 | tee -a $oneinstack_dir/install.log
fi

# JDK
if [ "$JDK_version" == '1' ];then
    . include/jdk-1.8.sh
    Install-JDK-1-8 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$JDK_version" == '2' ];then
    . include/jdk-1.7.sh
    Install-JDK-1-7 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$JDK_version" == '3' ];then
    . include/jdk-1.6.sh
    Install-JDK-1-6 2>&1 | tee -a $oneinstack_dir/install.log
fi

if [ "$Tomcat_version" == '1' ];then
    . include/tomcat-8.sh
    Install_tomcat-8 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$Tomcat_version" == '2' ];then
    . include/tomcat-7.sh
    Install_tomcat-7 2>&1 | tee -a $oneinstack_dir/install.log
elif [ "$Tomcat_version" == '3' ];then
    . include/tomcat-6.sh
    Install_tomcat-6 2>&1 | tee -a $oneinstack_dir/install.log
fi

# Pure-FTPd
if [ "$FTP_yn" == 'y' ];then
    . include/pureftpd.sh
    Install_PureFTPd 2>&1 | tee -a $oneinstack_dir/install.log
fi

# phpMyAdmin
if [ "$phpMyAdmin_yn" == 'y' ];then
    . include/phpmyadmin.sh
    Install_phpMyAdmin 2>&1 | tee -a $oneinstack_dir/install.log
fi

# redis
if [ "$redis_yn" == 'y' ];then
    . include/redis.sh
    [ ! -d "$redis_install_dir" ] && Install_redis-server 2>&1 | tee -a $oneinstack_dir/install.log
    [ -e "$php_install_dir/bin/phpize" ] && [ ! -e "`$php_install_dir/bin/php-config --extension-dir`/redis.so" ] && Install_php-redis 2>&1 | tee -a $oneinstack_dir/install.log
fi

# memcached
if [ "$memcached_yn" == 'y' ];then
    . include/memcached.sh
    [ ! -d "$memcached_install_dir/include/memcached" ] && Install_memcached 2>&1 | tee -a $oneinstack_dir/install.log
    [ -e "$php_install_dir/bin/phpize" ] && [ ! -e "`$php_install_dir/bin/php-config --extension-dir`/memcache.so" ] && Install_php-memcache 2>&1 | tee -a $oneinstack_dir/install.log
    [ -e "$php_install_dir/bin/phpize" ] && [ ! -e "`$php_install_dir/bin/php-config --extension-dir`/memcached.so" ] && Install_php-memcached 2>&1 | tee -a $oneinstack_dir/install.log
fi

# index example
if [ ! -e "$wwwroot_dir/default/index.html" -a "$Web_yn" == 'y' ];then
    . include/demo.sh
    DEMO 2>&1 | tee -a $oneinstack_dir/install.log
fi

# get web_install_dir and db_install_dir
. include/check_dir.sh

# HHVM
if [ "$HHVM_yn" == 'y' ];then
    . include/hhvm_CentOS.sh
    Install_hhvm_CentOS 2>&1 | tee -a $oneinstack_dir/install.log
fi

# Starting DB
[ -d "/etc/mysql" ] && /bin/mv /etc/mysql{,_bk}
[ -d "$db_install_dir/support-files" -a -z "`ps -ef | grep -v grep | grep mysql`" ] && /etc/init.d/mysqld start

echo "####################Congratulations########################"
[ "$Web_yn" == 'y' -a "$Nginx_version" != '4' -a "$Apache_version" == '3' ] && echo -e "\n`printf "%-32s" "Nginx install dir":`${CMSG}$web_install_dir${CEND}"
[ "$Web_yn" == 'y' -a "$Nginx_version" != '4' -a "$Apache_version" != '3' ] && echo -e "\n`printf "%-32s" "Nginx install dir":`${CMSG}$web_install_dir${CEND}\n`printf "%-32s" "Apache install  dir":`${CMSG}$apache_install_dir${CEND}"
[ "$Web_yn" == 'y' -a "$Nginx_version" == '4' -a "$Apache_version" != '3' ] && echo -e "\n`printf "%-32s" "Apache install dir":`${CMSG}$apache_install_dir${CEND}"
[[ "$Tomcat_version" =~ ^[1,2]$ ]] && echo -e "\n`printf "%-32s" "Tomcat install dir":`${CMSG}$tomcat_install_dir${CEND}"
[ "$DB_yn" == 'y' ] && echo -e "\n`printf "%-32s" "Database install dir:"`${CMSG}$db_install_dir${CEND}"
[ "$DB_yn" == 'y' ] && echo "`printf "%-32s" "Database data dir:"`${CMSG}$db_data_dir${CEND}"
[ "$DB_yn" == 'y' ] && echo "`printf "%-32s" "Database user:"`${CMSG}root${CEND}"
[ "$DB_yn" == 'y' ] && echo "`printf "%-32s" "Database password:"`${CMSG}${dbrootpwd}${CEND}"
[ "$PHP_yn" == 'y' ] && echo -e "\n`printf "%-32s" "PHP install dir:"`${CMSG}$php_install_dir${CEND}"
[ "$PHP_cache" == '1' ] && echo "`printf "%-32s" "Opcache Control Panel url:"`${CMSG}http://$IPADDR/ocp.php${CEND}"
[ "$PHP_cache" == '2' ] && echo "`printf "%-32s" "xcache Control Panel url:"`${CMSG}http://$IPADDR/xcache${CEND}"
[ "$PHP_cache" == '2' ] && echo "`printf "%-32s" "xcache user:"`${CMSG}admin${CEND}"
[ "$PHP_cache" == '2' ] && echo "`printf "%-32s" "xcache password:"`${CMSG}$xcache_admin_pass${CEND}"
[ "$PHP_cache" == '3' ] && echo "`printf "%-32s" "APC Control Panel url:"`${CMSG}http://$IPADDR/apc.php${CEND}"
[ "$PHP_cache" == '4' ] && echo "`printf "%-32s" "eAccelerator Control Panel url:"`${CMSG}http://$IPADDR/control.php${CEND}"
[ "$PHP_cache" == '4' ] && echo "`printf "%-32s" "eAccelerator user:"`${CMSG}admin${CEND}"
[ "$PHP_cache" == '4' ] && echo "`printf "%-32s" "eAccelerator password:"`${CMSG}eAccelerator${CEND}"
[ "$FTP_yn" == 'y' ] && echo -e "\n`printf "%-32s" "Pure-FTPd install dir:"`${CMSG}$pureftpd_install_dir${CEND}"
[ "$FTP_yn" == 'y' ] && echo "`printf "%-32s" "Create FTP virtual script:"`${CMSG}./pureftpd_vhost.sh${CEND}"
[ "$phpMyAdmin_yn" == 'y' ] && echo -e "\n`printf "%-32s" "phpMyAdmin dir:"`${CMSG}$wwwroot_dir/default/phpMyAdmin${CEND}"
[ "$phpMyAdmin_yn" == 'y' ] && echo "`printf "%-32s" "phpMyAdmin Control Panel url:"`${CMSG}http://$IPADDR/phpMyAdmin${CEND}"
[ "$redis_yn" == 'y' ] && echo -e "\n`printf "%-32s" "redis install dir:"`${CMSG}$redis_install_dir${CEND}"
[ "$memcached_yn" == 'y' ] && echo -e "\n`printf "%-32s" "memcached install dir:"`${CMSG}$memcached_install_dir${CEND}"
[ "$Web_yn" == 'y' ] && echo -e "\n`printf "%-32s" "index url:"`${CMSG}http://$IPADDR/${CEND}"
while :; do echo
    echo "${CMSG}Please restart the server and see if the services start up fine.${CEND}"
    read -p "Do you want to restart OS ? [y/n]: " restart_yn
    if [[ ! $restart_yn =~ ^[y,n]$ ]];then
        echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
        break
    fi
done
[ "$restart_yn" == 'y' ] && reboot
