#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com
#
# Version: 0.3 07-Sep-2013 lj2007331 AT gmail.com
# Notes: LNMP for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+ 
#
# This script's project home is:
#       https://github.com/lj2007331/lnmp

# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script" && kill -9 $$

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
echo "#######################################################################"
echo "#         LNMP for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+          #"
echo "# For more information Please visit http://blog.linuxeye.com/31.html  #"
echo "#######################################################################"

#get pwd
sed -i "s@^lnmp_dir.*@lnmp_dir=`pwd`@" ./options.conf

# get ipv4
. functions/get_ipv4.sh

# Definition Directory
. ./options.conf
mkdir -p $home_dir/default $wwwlogs_dir $lnmp_dir/{src,conf}

# choice upgrade OS
while :
do
        echo
        read -p "Do you want to upgrade operating system ? [y/n]: " upgrade_yn
        if [ "$upgrade_yn" != 'y' -a "$upgrade_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
                [ -e init/init_*.ed -a "$upgrade_yn" == 'y' ] && echo -e "\033[31mYour system is already upgraded! \033[0m" && upgrade_yn=n && break
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
                        [ -d "$web_install_dir" ] && echo -e "\033[31mThe web service already installed! \033[0m" && Web_yn=n && break
                        while :
                        do
                                echo
                                echo 'Please select Web server:'
                                echo -e "\t\033[32m1\033[0m. Install Nginx"
                                echo -e "\t\033[32m2\033[0m. Install Tengine"
                                read -p "Please input a number:(Default 1 press Enter) " Web_server
                                [ -z "$Web_server" ] && Web_server=1
                                if [ $Web_server != 1 -a $Web_server != 2 ];then
                                        echo -e "\033[31minput error! Please only input number 1,2\033[0m"
                                else
                                        while :
                                        do
                                                read -p "Do you want to install ngx_pagespeed module? [y/n]: " ngx_pagespeed_yn
                                                if [ "$ngx_pagespeed_yn" != 'y' -a "$ngx_pagespeed_yn" != 'n' ];then
                                                        echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
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
                        [ -d "$db_install_dir" ] && echo -e "\033[31mThe database already installed! \033[0m" && DB_yn=n && break
                        while :
                        do
                                echo
                                echo 'Please select a version of the Database:'
                                echo -e "\t\033[32m1\033[0m. Install MySQL-5.6"
                                echo -e "\t\033[32m2\033[0m. Install MySQL-5.5"
                                echo -e "\t\033[32m3\033[0m. Install MariaDB-5.5"
                                read -p "Please input a number:(Default 1 press Enter) " DB_version
                                [ -z "$DB_version" ] && DB_version=1
                                if [ $DB_version != 1 -a $DB_version != 2 -a $DB_version != 3 ];then
                                        echo -e "\033[31minput error! Please only input number 1,2,3 \033[0m"
                                else
                                        while :
                                        do
                                                read -p "Please input the root password of database: " dbrootpwd
                                                (( ${#dbrootpwd} >= 5 )) && sed -i "s@^dbrootpwd.*@dbrootpwd=$dbrootpwd@" options.conf && break || echo -e "\033[31mdatabase root password least 5 characters! \033[0m"
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
                        [ -d "$php_install_dir" ] && echo -e "\033[31mThe php already installed! \033[0m" && PHP_yn=n && break
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
                                        if [ $PHP_version == 2 ];then
                                                while :
                                                do
                                                        echo 'Please select a opcode cache of the PHP:'
                                                        echo -e "\t\033[32m1\033[0m. Install Zend OPcache"
                                                        echo -e "\t\033[32m2\033[0m. Install eAccelerator-1.0-dev"
                                                        echo -e "\t\033[32m3\033[0m. Install XCache"
                                                        read -p "Please input a number:(Default 1 press Enter) " PHP_cache
                                                        [ -z "$PHP_cache" ] && PHP_cache=1
                                                        if [ $PHP_cache != 1 -a $PHP_cache != 2 -a $PHP_cache != 3 ];then
                                                                echo -e "\033[31minput error! Please only input number 1,2,3\033[
0m"
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
                                                        echo -e "\t\033[32m2\033[0m. Install eAccelerator-0.9"
                                                        echo -e "\t\033[32m3\033[0m. Install XCache"
                                                        read -p "Please input a number:(Default 1 press Enter) " PHP_cache
                                                        [ -z "$PHP_cache" ] && PHP_cache=1
                                                        if [ $PHP_cache != 1 -a $PHP_cache != 2 -a $PHP_cache != 3 ];then
                                                                echo -e "\033[31minput error! Please only input number 1,2
\033[0m"
                                                        else
                                                                break
                                                        fi
                                                done
                                        fi
                                        if [ "$PHP_cache" == '3' ];then
                                                while :
                                                do
                                                        read -p "Please input xcache admin password: " xcache_admin_pass
                                                        (( ${#xcache_admin_pass} >= 5 )) && xcache_admin_md5_pass=`echo -n "$xcache_admin_pass" | md5sum | awk '{print $1}'` && break || echo -e "\033[31mxcache admin password least 5 characters! \033[0m"
                                                done
                                        fi
                                fi
                                break
                        done
                fi
                break
        fi
done

# check Pureftpd
while :
do
        echo
        read -p "Do you want to install Pure-FTPd? [y/n]: " FTP_yn
        if [ "$FTP_yn" != 'y' -a "$FTP_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else

                if [ "$FTP_yn" == 'y' ];then
                        [ -d "$pureftpd_install_dir" ] && echo -e "\033[31mThe FTP service already installed! \033[0m" && FTP_yn=n && break
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
			[ -d "$redis_install_dir" ] && echo -e "\033[31mThe redis already installed! \033[0m" && redis_yn=n && break
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
			[ -d "$memcached_install_dir" ] && echo -e "\033[31mThe memcached already installed! \033[0m" && memcached_yn=n && break
		fi
                break
        fi
done

# check jemalloc or tcmalloc 
if [ ! -d "$db_install_dir" -o ! -d "$web_install_dir" ];then
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
. functions/check_os.sh
if [ "$OS" == 'CentOS' ];then
	. init/init_CentOS.sh 2>&1 | tee -a $lnmp_dir/install.log
	/bin/mv init/init_CentOS.sh init/init_CentOS.ed
elif [ "$OS" == 'Debian' ];then
	. init/init_Debian.sh 2>&1 | tee -a $lnmp_dir/install.log
	/bin/mv init/init_Debian.sh init/init_Debian.ed
elif [ "$OS" == 'Ubuntu' ];then
	. init/init_Ubuntu.sh 2>&1 | tee -a $lnmp_dir/install.log
	/bin/mv init/init_Ubuntu.sh init/init_Ubuntu.ed
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
	. functions/mariadb-5.5.sh
	Install_MariaDB-5-5 2>&1 | tee -a $lnmp_dir/install.log 
fi

# PHP MySQL Client
if [ "$DB" == 'n' -a "$PHP_yn" == 'y' ];then
	. functions/php-mysql-client.sh 2>&1 | tee -a $lnmp_dir/install.log
	Install_PHP-MySQL-Client 2>&1 | tee -a $lnmp_dir/install.log
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

# PHP opcode cache (php <= 5.4)
if [ "$PHP_cache" == '1' ];then
        . functions/zendopcache.sh
        Install_ZendOPcache 2>&1 | tee -a $lnmp_dir/install.log
elif [ "$PHP_cache" == '2' -a "$PHP_version" == '2' ];then
        . functions/eaccelerator-1.0-dev.sh
        Install_eAccelerator-1-0-dev 2>&1 | tee -a $lnmp_dir/install.log
elif [ "$PHP_cache" == '2' -a "$PHP_version" == '3' ];then
        . functions/eaccelerator-0.9.sh
        Install_eAccelerator-0-9 2>&1 | tee -a $lnmp_dir/install.log
elif [ "$PHP_cache" == '3' ];then
        . functions/xcache.sh 
        Install_XCache 2>&1 | tee -a $lnmp_dir/install.log
fi

# Web server
if [ "$Web_server" == '1' ];then
        . functions/nginx.sh
        Install_Nginx 2>&1 | tee -a $lnmp_dir/install.log
elif [ "$Web_server" == '2' ];then
	. functions/tengine.sh
        Install_Tengine 2>&1 | tee -a $lnmp_dir/install.log
fi

# ngx_pagespeed
if [ "$ngx_pagespeed_yn" == 'y' ];then
	. functions/ngx_pagespeed.sh
	Install_ngx_pagespeed 2>&1 | tee -a $lnmp_dir/install.log
fi

# Pure-FTPd
if [ "$Web_yn" == 'y' -a "$DB_yn" == 'y' -a "$FTP_yn" == 'y' ];then
	. functions/pureftpd.sh
	Install_PureFTPd 2>&1 | tee -a $lnmp_dir/install.log 
fi

if [ "$PHP_yn" == 'y' ];then
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
fi

# get db_install_dir and web_install_dir
. ./options.conf

# index example
if [ ! -e "$home_dir/default/index.html" -a -d "$web_install_dir" ];then
	. functions/test.sh
	TEST 2>&1 | tee -a $lnmp_dir/install.log 
fi

echo "####################Congratulations########################"
echo -e "\033[32mPlease restart the server and see if the services start up fine.\033[0m"
echo
[ "$Web_yn" == 'y' ] && echo -e "`printf "%-32s" "Web install  dir":`\033[32m$web_install_dir\033[0m"
[ "$DB_yn" == 'y' ] && echo -e "\n`printf "%-32s" "Database install dir:"`\033[32m$db_install_dir\033[0m"
[ "$DB_yn" == 'y' ] && echo -e "`printf "%-32s" "Database user:"`\033[32mroot\033[0m"
[ "$DB_yn" == 'y' ] && echo -e "`printf "%-32s" "Database password:"`\033[32m${dbrootpwd}\033[0m"
[ "$PHP_yn" == 'y' ] && echo -e "\n`printf "%-32s" "PHP install dir:"`\033[32m$php_install_dir\033[0m"
[ "$PHP_cache" == '3' ] && echo -e "`printf "%-32s" "xcache web dir:"`\033[32m$home_dir/default/xcache\033[0m"
[ "$PHP_cache" == '3' ] && echo -e "`printf "%-32s" "xcache web manager url:"`\033[32mhttp://$IP/xcache\033[0m"
[ "$PHP_cache" == '3' ] && echo -e "`printf "%-32s" "xcache user:"`\033[32madmin\033[0m"
[ "$PHP_cache" == '3' ] && echo -e "`printf "%-32s" "xcache password:"`\033[32m$xcache_admin_pass\033[0m"
[ "$FTP_yn" == 'y' ] && echo -e "\n`printf "%-32s" "Pure-FTPd install dir:"`\033[32m$pureftpd_install_dir\033[0m"
[ "$FTP_yn" == 'y' ] && echo -e "`printf "%-32s" "pureftpd php manager dir:"`\033[32m$home_dir/default/ftp\033[0m"
[ "$FTP_yn" == 'y' ] && echo -e "`printf "%-32s" "ftp web manager url:"`\033[32mhttp://$IP/ftp\033[0m"
[ "$phpMyAdmin_yn" == 'y' ] && echo -e "\n`printf "%-32s" "phpMyAdmin dir:"`\033[32m$home_dir/default/phpMyAdmin\033[0m"
[ "$phpMyAdmin_yn" == 'y' ] && echo -e "`printf "%-32s" "phpMyAdmin url:"`\033[32mhttp://$IP/phpMyAdmin\033[0m"
[ "$redis_yn" == 'y' ] && echo -e "\n`printf "%-32s" "redis install dir:"`\033[32m$redis_install_dir\033[0m"
[ "$memcached_yn" == 'y' ] && echo -e "\n`printf "%-32s" "memcached install dir:"`\033[32m$memcached_install_dir\033[0m"
[ "$Web_yn" == 'y' ] && echo -e "\n`printf "%-32s" "index url:"`\033[32mhttp://$IP/\033[0m"
