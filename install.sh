#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com
#
# Version: 0.7 7-Apr-2014 lj2007331 AT gmail.com
# Notes: LNMP/LAMP/LANMP for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+ 
#
# This script's project home is:
#       http://blog.linuxeye.com/31.html
#       https://github.com/lj2007331/lnmp

# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script" && exit 1 

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#######################################################################
#    LNMP/LAMP/LANMP for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+    #
# For more information please visit http://blog.linuxeye.com/31.html  #
#######################################################################"

#get pwd
sed -i "s@^lnmp_dir.*@lnmp_dir=`pwd`@" ./options.conf

# get local ip address
local_IP=`./functions/get_local_ip.py`

# Definition Directory
. ./options.conf
. functions/check_os.sh
mkdir -p $home_dir/default $wwwlogs_dir $lnmp_dir/{src,conf}

# choice upgrade OS
while :
do
	echo
        read -p "Do you want to upgrade operating system ? [y/n]: " upgrade_yn
        if [ "$upgrade_yn" != 'y' -a "$upgrade_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
		[ -e init/init_*.ed -a "$upgrade_yn" == 'y' ] && { echo -e "\033[31mYour system is already upgraded! \033[0m" ; upgrade_yn=n ; }
                # check sendmail
		if [ "$OS" != 'Debian' ];then
	                while :
	                do
	                        echo
	                        read -p "Do you want to install sendmail ? [y/n]: " sendmail_yn
	                        if [ "$sendmail_yn" != 'y' -a "$sendmail_yn" != 'n' ];then
	                                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
	                        else
	                                break
	                        fi
	                done
		fi
                break
        fi
done

# check Web server
while :
do
        echo
        read -p "Do you want to install Web server? [y/n]: " Web_yn
        if [ "$Web_yn" != 'y' -a "$Web_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
                if [ "$Web_yn" == 'y' ];then
                        [ -d "$web_install_dir" ] && { echo -e "\033[31mThe web service already installed! \033[0m" ; Web_yn=n ; break ; }
                        while :
                        do
                                echo
                                echo 'Please select Nginx server:'
                                echo -e "\t\033[32m1\033[0m. Install Nginx"
                                echo -e "\t\033[32m2\033[0m. Install Tengine"
                                echo -e "\t\033[32m3\033[0m. Do not install"
                                read -p "Please input a number:(Default 1 press Enter) " Nginx_version
                                [ -z "$Nginx_version" ] && Nginx_version=1
                                if [ $Nginx_version != 1 -a $Nginx_version != 2 -a $Nginx_version != 3 ];then
                                        echo -e "\033[31minput error! Please only input number 1,2,3\033[0m"
                                else
                                if [ $Nginx_version = 1 -o $Nginx_version = 2 ];then
                                        while :
                                        do
                                                read -p "Do you want to install ngx_pagespeed module? [y/n]: " ngx_pagespeed_yn
                                                if [ "$ngx_pagespeed_yn" != 'y' -a "$ngx_pagespeed_yn" != 'n' ];then
                                                        echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
                                                else
                                                        break
                                                fi
                                        done
                                fi
				while :
				do
                                	echo
	                                echo 'Please select Apache server:'
	                                echo -e "\t\033[32m1\033[0m. Install Apache-2.4"
	                                echo -e "\t\033[32m2\033[0m. Install Apache-2.2"
	                                echo -e "\t\033[32m3\033[0m. Do not install"
	                                read -p "Please input a number:(Default 3 press Enter) " Apache_version
	                                [ -z "$Apache_version" ] && Apache_version=3
	                                if [ $Apache_version != 1 -a $Apache_version != 2 -a $Apache_version != 3 ];then
	                                        echo -e "\033[31minput error! Please only input number 1,2,3\033[0m"
	                                else
	                                        break
	                                fi
				done
                                break
                                fi
                        done
                fi
                break
        fi
done

# choice database
while :
do
        echo
        read -p "Do you want to install Database? [y/n]: " DB_yn
        if [ "$DB_yn" != 'y' -a "$DB_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
                if [ "$DB_yn" == 'y' ];then
                        [ -d "$db_install_dir" ] && { echo -e "\033[31mThe database already installed! \033[0m" ; DB_yn=n ; break ; }
                        while :
                        do
                                echo
                                echo 'Please select a version of the Database:'
                                echo -e "\t\033[32m1\033[0m. Install MySQL-5.6"
                                echo -e "\t\033[32m2\033[0m. Install MySQL-5.5"
                                echo -e "\t\033[32m3\033[0m. Install MariaDB-10.0"
                                echo -e "\t\033[32m4\033[0m. Install MariaDB-5.5"
                                echo -e "\t\033[32m5\033[0m. Install Percona-5.6"
                                echo -e "\t\033[32m6\033[0m. Install Percona-5.5"
                                read -p "Please input a number:(Default 1 press Enter) " DB_version
                                [ -z "$DB_version" ] && DB_version=1
                                if [ $DB_version != 1 -a $DB_version != 2 -a $DB_version != 3 -a $DB_version != 4 -a $DB_version != 5 -a $DB_version != 6 ];then
                                        echo -e "\033[31minput error! Please only input number 1,2,3,4,5,6 \033[0m"
                                else
                                        while :
                                        do
                                                read -p "Please input the root password of database: " dbrootpwd
                                                (( ${#dbrootpwd} >= 5 )) && sed -i "s@^dbrootpwd.*@dbrootpwd=$dbrootpwd@" ./options.conf && break || echo -e "\033[31mdatabase root password least 5 characters! \033[0m"
                                        done
                                        break
                                fi
                        done
                fi
                break
        fi
done

# check PHP
while :
do
echo
read -p "Do you want to install PHP? [y/n]: " PHP_yn
if [ "$PHP_yn" != 'y' -a "$PHP_yn" != 'n' ];then
        echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
else
        if [ "$PHP_yn" == 'y' ];then
                [ -d "$php_install_dir" ] && { echo -e "\033[31mThe php already installed! \033[0m" ; PHP_yn=n ; break ; }
                while :
                do
                        echo
                        echo 'Please select a version of the PHP:'
                        echo -e "\t\033[32m1\033[0m. Install php-5.5"
                        echo -e "\t\033[32m2\033[0m. Install php-5.4"
                        echo -e "\t\033[32m3\033[0m. Install php-5.3"
                        read -p "Please input a number:(Default 1 press Enter) " PHP_version
                        [ -z "$PHP_version" ] && PHP_version=1
                        if [ $PHP_version != 1 -a $PHP_version != 2 -a $PHP_version != 3 ];then
                                echo -e "\033[31minput error! Please only input number 1,2,3 \033[0m"
                        else
                                while :
                                        do
                                        echo
                                        echo 'You can either use the mysqlnd or libmysql library to connect from PHP to MySQL:'
                                        echo -e "\t\033[32m1\033[0m. MySQL native driver (mysqlnd)"
                                        echo -e "\t\033[32m2\033[0m. MySQL Client Library (libmysql)"
                                        read -p "Please input a number:(Default 1 press Enter) " PHP_MySQL_driver
                                        [ -z "$PHP_MySQL_driver" ] && PHP_MySQL_driver=1
                                        if [ $PHP_MySQL_driver != 1 -a $PHP_MySQL_driver != 2 ];then
                                                echo -e "\033[31minput error! Please only input number 1,2\033[0m"
                                        else
                                                break
                                        fi
                                done

				while :
				do
					echo
					read -p "Do you want to install opcode cache of the PHP? [y/n]: " PHP_cache_yn 
					if [ "$PHP_cache_yn" != 'y' -a "$PHP_cache_yn" != 'n' ];then
						echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
					else
						if [ "$PHP_cache_yn" == 'y' ];then	
		                                        if [ $PHP_version == 1 ];then
		                                                while :
		                                                do
		                                                        echo 'Please select a opcode cache of the PHP:'
		                                                        echo -e "\t\033[32m1\033[0m. Install Zend OPcache"
		                                                        echo -e "\t\033[32m2\033[0m. Install XCache"
		                                                        echo -e "\t\033[32m3\033[0m. Install APCU"
		                                                        read -p "Please input a number:(Default 1 press Enter) " PHP_cache
		                                                        [ -z "$PHP_cache" ] && PHP_cache=1
		                                                        if [ $PHP_cache != 1 -a $PHP_cache != 2 -a $PHP_cache != 3 ];then
		                                                                echo -e "\033[31minput error! Please only input number 1,2,3\033[0m"
		                                                        else
		                                                                break
		                                                        fi
		                                                done
		                                        fi
		                                        if [ $PHP_version == 2 ];then
		                                                while :
		                                                do
		                                                        echo 'Please select a opcode cache of the PHP:'
		                                                        echo -e "\t\033[32m1\033[0m. Install Zend OPcache"
		                                                        echo -e "\t\033[32m2\033[0m. Install XCache"
		                                                        echo -e "\t\033[32m3\033[0m. Install APCU"
		                                                        echo -e "\t\033[32m4\033[0m. Install eAccelerator-1.0-dev"
		                                                        read -p "Please input a number:(Default 1 press Enter) " PHP_cache
		                                                        [ -z "$PHP_cache" ] && PHP_cache=1
		                                                        if [ $PHP_cache != 1 -a $PHP_cache != 2 -a $PHP_cache != 3 -a $PHP_cache != 4 ];then
		                                                                echo -e "\033[31minput error! Please only input number 1,2,3,4\033[0m"
		                                                        else
		                                                                break
		                                                        fi
		                                                done
		                                        fi
		                                        if [ $PHP_version == 3 ];then
		                                                while :
		                                                do
		                                                        echo 'Please select a opcode cache of the PHP:'
		                                                        echo -e "\t\033[32m1\033[0m. Install Zend OPcache"
		                                                        echo -e "\t\033[32m2\033[0m. Install XCache"
		                                                        echo -e "\t\033[32m3\033[0m. Install APCU"
		                                                        echo -e "\t\033[32m4\033[0m. Install eAccelerator-0.9"
		                                                        read -p "Please input a number:(Default 1 press Enter) " PHP_cache
		                                                        [ -z "$PHP_cache" ] && PHP_cache=1
		                                                        if [ $PHP_cache != 1 -a $PHP_cache != 2 -a $PHP_cache != 3 -a $PHP_cache != 4 ];then
		                                                                echo -e "\033[31minput error! Please only input number 1,2,3,4\033[0m"
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
                                        while :
                                        do
                                                read -p "Please input xcache admin password: " xcache_admin_pass
                                                (( ${#xcache_admin_pass} >= 5 )) && { xcache_admin_md5_pass=`echo -n "$xcache_admin_pass" | md5sum | awk '{print $1}'` ; break ; } || echo -e "\033[31mxcache admin password least 5 characters! \033[0m"
                                        done
                                fi
				if [ "$PHP_version" == '2' -o "$PHP_version" == '3' ];then
                                        while :
                                        do
                                                echo
                                                read -p "Do you want to install ZendGuardLoader? [y/n]: " ZendGuardLoader_yn
                                                if [ "$ZendGuardLoader_yn" != 'y' -a "$ZendGuardLoader_yn" != 'n' ];then
                                                        echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
                                                else
                                                        break
                                                fi
                                        done
                                fi

                                while :
                                do
                                        echo
                                        read -p "Do you want to install ionCube? [y/n]: " ionCube_yn
                                        if [ "$ionCube_yn" != 'y' -a "$ionCube_yn" != 'n' ];then
                                                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
                                        else
                                                break
                                        fi
                                done

                                while :
                                do
                                        echo
                                        read -p "Do you want to install ImageMagick or GraphicsMagick? [y/n]: " Magick_yn
                                        if [ "$Magick_yn" != 'y' -a "$Magick_yn" != 'n' ];then
                                                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
                                        else
                                                break
                                        fi
                                done
                                if [ "$Magick_yn" == 'y' ];then
                                        while :
                                        do
                                                echo 'Please select ImageMagick or GraphicsMagick:'
                                                echo -e "\t\033[32m1\033[0m. Install ImageMagick"
                                                echo -e "\t\033[32m2\033[0m. Install GraphicsMagick"
                                                read -p "Please input a number:(Default 1 press Enter) " Magick
                                                [ -z "$Magick" ] && Magick=1
                                                if [ $Magick != 1 -a $Magick != 2 ];then
                                                        echo -e "\033[31minput error! Please only input number 1,2 \033[0m"
                                                else
                                                        break
                                                fi
                                        done
                                fi

                                #while :
                                #do
                                #        echo
                                #        read -p "Do you want to install pecl_http PHP extension(Support HTTP request curls)? [y/n]: " pecl_http_yn
                                #        if [ "$pecl_http_yn" != 'y' -a "$pecl_http_yn" != 'n' ];then
                                #                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
                                #        else
                                #                break
                                #        fi
                                #done
                                break
                        fi
                done
        fi
        break
fi
done

if [ "$Web_yn" == 'y' -a "$DB_yn" == 'y' -a "$PHP_yn" == 'y' ];then
# check Pureftpd
while :
do
        echo
        read -p "Do you want to install Pure-FTPd? [y/n]: " FTP_yn
        if [ "$FTP_yn" != 'y' -a "$FTP_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else

                if [ "$FTP_yn" == 'y' ];then
                        [ -d "$pureftpd_install_dir" ] && { echo -e "\033[31mThe FTP service already installed! \033[0m" ; FTP_yn=n ; break ; }
                        while :
                        do
                                read -p "Please input the manager password of Pure-FTPd: " ftpmanagerpwd
                                if (( ${#ftpmanagerpwd} >= 5 ));then
                                        sed -i "s@^ftpmanagerpwd.*@ftpmanagerpwd=$ftpmanagerpwd@" options.conf
                                        break
                                else
                                        echo -e "\033[31mFtp manager password least 5 characters! \033[0m"
                                fi
                        done
                fi
                break
        fi
done
fi

# check phpMyAdmin
while :
do
        echo
        read -p "Do you want to install phpMyAdmin? [y/n]: " phpMyAdmin_yn
        if [ "$phpMyAdmin_yn" != 'y' -a "$phpMyAdmin_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
		if [ "$phpMyAdmin_yn" == 'y' ];then
		        [ -d "$home_dir/default/phpMyAdmin" ] && echo -e "\033[31mThe phpMyAdmin already installed! \033[0m" && phpMyAdmin_yn=n && break
		fi
                break
        fi
done

# check redis
while :
do
	echo
	read -p "Do you want to install redis? [y/n]: " redis_yn
	if [ "$redis_yn" != 'y' -a "$redis_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
	else
		if [ "$redis_yn" == 'y' ];then
			[ -d "$redis_install_dir" ] && { echo -e "\033[31mThe redis already installed! \033[0m" ; redis_yn=n ; break ; }
		fi
		break
	fi
done

# check memcached
while :
do
	echo
        read -p "Do you want to install memcached? [y/n]: " memcached_yn
        if [ "$memcached_yn" != 'y' -a "$memcached_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
		if [ "$memcached_yn" == 'y' ];then
			[ -d "$memcached_install_dir" ] && { echo -e "\033[31mThe memcached already installed! \033[0m" ; memcached_yn=n ; break ; }
		fi
                break
        fi
done

# gcc sane CFLAGS and CXXFLAGS
#while :
#do
#        echo
#        read -p "Do you want to optimizing compiled code using safe, sane CFLAGS and CXXFLAGS? [y/n]: " gcc_sane_yn
#        if [ "$gcc_sane_yn" != 'y' -a "$gcc_sane_yn" != 'n' ];then
#                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
#        else
#                [ "$gcc_sane_yn" == 'y' -a -z "`cat /proc/cpuinfo | grep 'model name' | grep -E 'Intel|AMD'`" ] && echo -e "Unknown CPU model" && gcc_sane_yn=n && break
#                break
#        fi
#done

# check jemalloc or tcmalloc 
if [ "$Web_yn" == 'y' -o "$DB_yn" == 'y' ];then
        while :
        do
                echo
                read -p "Do you want to use jemalloc or tcmalloc optimize Database and Web server? [y/n]: " je_tc_malloc_yn
                if [ "$je_tc_malloc_yn" != 'y' -a "$je_tc_malloc_yn" != 'n' ];then
                        echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
                else
                        if [ "$je_tc_malloc_yn" == 'y' ];then
                                echo 'Please select jemalloc or tcmalloc:'
                                echo -e "\t\033[32m1\033[0m. jemalloc"
                                echo -e "\t\033[32m2\033[0m. tcmalloc"
                                while :
                                do
                                        read -p "Please input a number:(Default 1 press Enter) " je_tc_malloc
                                        [ -z "$je_tc_malloc" ] && je_tc_malloc=1
                                        if [ $je_tc_malloc != 1 -a $je_tc_malloc != 2 ];then
                                                echo -e "\033[31minput error! Please only input number 1,2\033[0m"
                                        else
                                                break
                                        fi
                                done
                        fi
                        break
                fi
        done
fi

chmod +x functions/*.sh init/* *.sh

# init
if [ "$OS" == 'CentOS' ];then
	. init/init_CentOS.sh 2>&1 | tee $lnmp_dir/install.log
	#/bin/mv init/init_CentOS.sh init/init_CentOS.ed
	[ -n "`gcc --version | head -n1 | grep '4\.1\.'`" ] && export CC="gcc44" CXX="g++44"
elif [ "$OS" == 'Debian' ];then
	. init/init_Debian.sh 2>&1 | tee $lnmp_dir/install.log
	#/bin/mv init/init_Debian.sh init/init_Debian.ed
elif [ "$OS" == 'Ubuntu' ];then
	. init/init_Ubuntu.sh 2>&1 | tee $lnmp_dir/install.log
	#/bin/mv init/init_Ubuntu.sh init/init_Ubuntu.ed
fi

# Optimization compiled code using safe, sane CFLAGS and CXXFLAGS
if [ "$gcc_sane_yn" == 'y' ];then
        if [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 64 ];then
                export CHOST="x86_64-pc-linux-gnu" CFLAGS="-march=native -O3 -pipe -fomit-frame-pointer"
                export CXXFLAGS="${CFLAGS}"
        elif [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 32 ];then
                export CHOST="i686-pc-linux-gnu" CFLAGS="-march=native -O3 -pipe -fomit-frame-pointer"
                export CXXFLAGS="${CFLAGS}"
        fi
fi

# jemalloc or tcmalloc
if [ "$je_tc_malloc_yn" == 'y' -a "$je_tc_malloc" == '1' ];then
	. functions/jemalloc.sh
	Install_jemalloc | tee -a $lnmp_dir/install.log
elif [ "$je_tc_malloc_yn" == 'y' -a "$je_tc_malloc" == '2' ];then
	. functions/tcmalloc.sh
	Install_tcmalloc | tee -a $lnmp_dir/install.log
fi

# Database
if [ "$DB_version" == '1' ];then
	. functions/mysql-5.6.sh 
	Install_MySQL-5-6 2>&1 | tee -a $lnmp_dir/install.log 
elif [ "$DB_version" == '2' ];then
        . functions/mysql-5.5.sh
        Install_MySQL-5-5 2>&1 | tee -a $lnmp_dir/install.log
elif [ "$DB_version" == '3' ];then
	. functions/mariadb-10.0.sh
	Install_MariaDB-10-0 2>&1 | tee -a $lnmp_dir/install.log 
elif [ "$DB_version" == '4' ];then
	. functions/mariadb-5.5.sh
	Install_MariaDB-5-5 2>&1 | tee -a $lnmp_dir/install.log 
elif [ "$DB_version" == '5' ];then
        . functions/percona-5.6.sh
        Install_Percona-5-6 2>&1 | tee -a $lnmp_dir/install.log
elif [ "$DB_version" == '6' ];then
	. functions/percona-5.5.sh 
	Install_Percona-5-5 2>&1 | tee -a $lnmp_dir/install.log 
fi

# PHP MySQL Client
if [ "$DB_yn" == 'n' -a "$PHP_yn" == 'y' -a "$PHP_MySQL_driver" == '2' ];then
	. functions/php-mysql-client.sh
	Install_PHP-MySQL-Client 2>&1 | tee -a $lnmp_dir/install.log
fi

# Apache
if [ "$Apache_version" == '1' ];then
	. functions/apache-2.4.sh 
	Install_Apache-2-4 2>&1 | tee -a $lnmp_dir/install.log
elif [ "$Apache_version" == '2' ];then
	. functions/apache-2.2.sh 
	Install_Apache-2-2 2>&1 | tee -a $lnmp_dir/install.log
fi

# PHP
if [ "$PHP_version" == '1' ];then
	. functions/php-5.5.sh
	Install_PHP-5-5 2>&1 | tee -a $lnmp_dir/install.log
elif [ "$PHP_version" == '2' ];then
        . functions/php-5.4.sh
        Install_PHP-5-4 2>&1 | tee -a $lnmp_dir/install.log
elif [ "$PHP_version" == '3' ];then
        . functions/php-5.3.sh
        Install_PHP-5-3 2>&1 | tee -a $lnmp_dir/install.log
fi

# ImageMagick or GraphicsMagick
if [ "$Magick" == '1' ];then
	. functions/ImageMagick.sh
	Install_ImageMagick 2>&1 | tee -a $lnmp_dir/install.log
elif [ "$Magick" == '2' ];then
	. functions/GraphicsMagick.sh
	Install_GraphicsMagick 2>&1 | tee -a $lnmp_dir/install.log
fi

# Support HTTP request curls 
if [ "$pecl_http_yn" == 'y' ];then
	. functions/pecl_http.sh
	Install_pecl_http 2>&1 | tee -a $lnmp_dir/install.log
fi

# ionCube
if [ "$ionCube_yn" == 'y' ];then
        . functions/ioncube.sh
        Install_ionCube 2>&1 | tee -a $lnmp_dir/install.log
fi

# PHP opcode cache
if [ "$PHP_cache" == '1' -a "$PHP_version" != '1' ];then
        . functions/zendopcache.sh
        Install_ZendOPcache 2>&1 | tee -a $lnmp_dir/install.log
elif [ "$PHP_cache" == '2' ];then
        . functions/xcache.sh 
        Install_XCache 2>&1 | tee -a $lnmp_dir/install.log
elif [ "$PHP_cache" == '3' ];then
        . functions/apcu.sh
        Install_APCU 2>&1 | tee -a $lnmp_dir/install.log
elif [ "$PHP_cache" == '4' -a "$PHP_version" == '2' ];then
        . functions/eaccelerator-1.0-dev.sh
        Install_eAccelerator-1-0-dev 2>&1 | tee -a $lnmp_dir/install.log
elif [ "$PHP_cache" == '4' -a "$PHP_version" == '3' ];then
        . functions/eaccelerator-0.9.sh
        Install_eAccelerator-0-9 2>&1 | tee -a $lnmp_dir/install.log
fi

# ZendGuardLoader (php <= 5.4)
if [ "$ZendGuardLoader_yn" == 'y' ];then
	. functions/ZendGuardLoader.sh
        Install_ZendGuardLoader 2>&1 | tee -a $lnmp_dir/install.log
fi

# Web server
if [ "$Nginx_version" == '1' ];then
        . functions/nginx.sh
        Install_Nginx 2>&1 | tee -a $lnmp_dir/install.log
elif [ "$Nginx_version" == '2' ];then
	. functions/tengine.sh
        Install_Tengine 2>&1 | tee -a $lnmp_dir/install.log
fi

# ngx_pagespeed
if [ "$ngx_pagespeed_yn" == 'y' ];then
	. functions/ngx_pagespeed.sh
	Install_ngx_pagespeed 2>&1 | tee -a $lnmp_dir/install.log
fi

# Pure-FTPd
if [ "$FTP_yn" == 'y' ];then
	. functions/pureftpd.sh
	Install_PureFTPd 2>&1 | tee -a $lnmp_dir/install.log 
fi

# phpMyAdmin
if [ "$phpMyAdmin_yn" == 'y' ];then
	. functions/phpmyadmin.sh
	Install_phpMyAdmin 2>&1 | tee -a $lnmp_dir/install.log
fi

# redis
if [ "$redis_yn" == 'y' ];then
	. functions/redis.sh
	Install_redis 2>&1 | tee -a $lnmp_dir/install.log
fi

# memcached
if [ "$memcached_yn" == 'y' ];then
	. functions/memcached.sh
	Install_memcached 2>&1 | tee -a $lnmp_dir/install.log
fi

# get db_install_dir and web_install_dir
. ./options.conf

# index example
if [ ! -e "$home_dir/default/index.html" -a "$Web_yn" == 'y' ];then
	. functions/test.sh
	TEST 2>&1 | tee -a $lnmp_dir/install.log 
fi

echo "####################Congratulations########################"
[ "$Web_yn" == 'y' -a "$Nginx_version" != '3' -a "$Apache_version" == '3' ] && echo -e "\n`printf "%-32s" "Nginx/Tengine install dir":`\033[32m$web_install_dir\033[0m"
[ "$Web_yn" == 'y' -a "$Nginx_version" != '3' -a "$Apache_version" != '3' ] && echo -e "\n`printf "%-32s" "Nginx/Tengine install dir":`\033[32m$web_install_dir\033[0m\n`printf "%-32s" "Apache install  dir":`\033[32m$apache_install_dir\033[0m" 
[ "$Web_yn" == 'y' -a "$Nginx_version" == '3' -a "$Apache_version" != '3' ] && echo -e "\n`printf "%-32s" "Apache install dir":`\033[32m$apache_install_dir\033[0m"
[ "$DB_yn" == 'y' ] && echo -e "\n`printf "%-32s" "Database install dir:"`\033[32m$db_install_dir\033[0m"
[ "$DB_yn" == 'y' ] && echo -e "`printf "%-32s" "Database data dir:"`\033[32m$db_data_dir\033[0m"
[ "$DB_yn" == 'y' ] && echo -e "`printf "%-32s" "Database user:"`\033[32mroot\033[0m"
[ "$DB_yn" == 'y' ] && echo -e "`printf "%-32s" "Database password:"`\033[32m${dbrootpwd}\033[0m"
[ "$PHP_yn" == 'y' ] && echo -e "\n`printf "%-32s" "PHP install dir:"`\033[32m$php_install_dir\033[0m"
[ "$PHP_cache" == '1' ] && echo -e "`printf "%-32s" "Opcache Control Panel url:"`\033[32mhttp://$local_IP/ocp.php\033[0m" 
[ "$PHP_cache" == '2' ] && echo -e "`printf "%-32s" "xcache Control Panel url:"`\033[32mhttp://$local_IP/xcache\033[0m"
[ "$PHP_cache" == '2' ] && echo -e "`printf "%-32s" "xcache user:"`\033[32madmin\033[0m"
[ "$PHP_cache" == '2' ] && echo -e "`printf "%-32s" "xcache password:"`\033[32m$xcache_admin_pass\033[0m"
[ "$PHP_cache" == '3' ] && echo -e "`printf "%-32s" "APC Control Panel url:"`\033[32mhttp://$local_IP/apc.php\033[0m" 
[ "$PHP_cache" == '4' ] && echo -e "`printf "%-32s" "eAccelerator Control Panel url:"`\033[32mhttp://$local_IP/control.php\033[0m"
[ "$PHP_cache" == '4' ] && echo -e "`printf "%-32s" "eAccelerator user:"`\033[32madmin\033[0m"
[ "$PHP_cache" == '4' ] && echo -e "`printf "%-32s" "eAccelerator password:"`\033[32meAccelerator\033[0m"
[ "$FTP_yn" == 'y' ] && echo -e "\n`printf "%-32s" "Pure-FTPd install dir:"`\033[32m$pureftpd_install_dir\033[0m"
[ "$FTP_yn" == 'y' ] && echo -e "`printf "%-32s" "Pure-FTPd php manager dir:"`\033[32m$home_dir/default/ftp\033[0m"
[ "$FTP_yn" == 'y' ] && echo -e "`printf "%-32s" "Ftp User Control Panel url:"`\033[32mhttp://$local_IP/ftp\033[0m"
[ "$phpMyAdmin_yn" == 'y' ] && echo -e "\n`printf "%-32s" "phpMyAdmin dir:"`\033[32m$home_dir/default/phpMyAdmin\033[0m"
[ "$phpMyAdmin_yn" == 'y' ] && echo -e "`printf "%-32s" "phpMyAdmin Control Panel url:"`\033[32mhttp://$local_IP/phpMyAdmin\033[0m"
[ "$redis_yn" == 'y' ] && echo -e "\n`printf "%-32s" "redis install dir:"`\033[32m$redis_install_dir\033[0m"
[ "$memcached_yn" == 'y' ] && echo -e "\n`printf "%-32s" "memcached install dir:"`\033[32m$memcached_install_dir\033[0m"
[ "$Web_yn" == 'y' ] && echo -e "\n`printf "%-32s" "index url:"`\033[32mhttp://$local_IP/\033[0m"
while :
do
        echo
        echo -e "\033[31mPlease restart the server and see if the services start up fine.\033[0m"
        read -p "Do you want to restart OS ? [y/n]: " restart_yn
        if [ "$restart_yn" != 'y' -a "$restart_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
                break
        fi
done
[ "$restart_yn" == 'y' ] && reboot
