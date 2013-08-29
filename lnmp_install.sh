#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com
#
# Version: 0.3 27-Aug-2013 lj2007331 AT gmail.com
# Notes: LNMP for CentOS/RadHat 5+ and Ubuntu 12+ 
#
# This script's project home is:
#       https://github.com/lj2007331/lnmp

# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script, Please use root to install lnmp" && kill -9 $$

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

echo "#######################################################################"
echo "#            LNMP for CentOS/RadHat 5+ and Ubuntu 12+                 #"
echo "# For more information Please visit http://blog.linuxeye.com/31.html  #"
echo "#######################################################################"
echo ''

#get pwd
sed -i "s@^lnmp_dir.*@lnmp_dir=`pwd`@" options.conf

# get ipv4
. functions/get_ipv4.sh

# Definition Directory
. ./options.conf
mkdir -p $home_dir/default $wwwlogs_dir $lnmp_dir/{src,conf}

# choice upgrade OS
while :
do
        read -p "Do you want to upgrade operating system ? (y/n) " upgrade_yn
        if [ "$upgrade_yn" != 'y' ] && [ "$upgrade_yn" != 'n' ];then
                echo -e "\033[31minput error! Please input 'y' or 'n'\033[0m"
        else
                break
        fi
done

# choice database 
if [ ! -d "$db_install_dir" ];then
        while :
        do
                echo ''
                echo 'Please select a version of the Database:'
                echo -e "\t\033[32m1\033[0m. Install MySQL-5.6"
                echo -e "\t\033[32m2\033[0m. Install MySQL-5.5"
                echo -e "\t\033[32m3\033[0m. Install MariaDB-5.5"
                read -p "Please input a number:(Default 1 press Enter) " DB_version
                [ -z "$DB_version" ] && DB_version=1
                if [ $DB_version != 1 ] && [ $DB_version != 2 ] && [ $DB_version != 3 ];then
                        echo -e "\033[31minput error! Please input 1 2 3 \033[0m"
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

# check PHP
if [ ! -d "$php_insall_dir" ];then
        while :
        do
                echo ''
                echo 'Please select a version of the PHP:'
                echo -e "\t\033[32m1\033[0m. Install php-5.5"
                echo -e "\t\033[32m2\033[0m. Install php-5.4"
                echo -e "\t\033[32m3\033[0m. Install php-5.3"
                read -p "Please input a number:(Default 1 press Enter) " PHP_version
                [ -z "$PHP_version" ] && PHP_version=1
                if [ $PHP_version != 1 ] && [ $PHP_version != 2 ] && [ $PHP_version != 3 ];then
                        echo -e "\033[31minput error! Please input 1 2 3 \033[0m"
                else
                        if [ $PHP_version == 2 ];then
                                while :
                                do
                                        echo 'Please select a opcode cache of the PHP:'
                                        echo -e "\t\033[32m1\033[0m. Install Zend OPcache"
                                        echo -e "\t\033[32m2\033[0m. Install eAccelerator-1.0-dev"
                                        read -p "Please input a number:(Default 1 press Enter) " PHP_cache
                                        [ -z "$PHP_cache" ] && PHP_cache=1
                                        if [ "$PHP_cache" != 1 ] && [ "$PHP_cache" != 2 ];then
                                                echo -e "\033[31minput error! Please input 1 or 2\033[0m"
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
                                        read -p "Please input a number:(Default 1 press Enter) " PHP_cache
                                        [ -z "$PHP_cache" ] && PHP_cache=1
                                        if [ "$PHP_cache" != 1 ] && [ "$PHP_cache" != 2 ];then
                                                echo -e "\033[31minput error! Please input 1 or 2\033[0m"
                                        else
                                                break
                                        fi
                                done
                        fi
                        break
                fi
        done
fi

# check Pureftpd
if [ ! -d "$pureftpd_install_dir" ];then
while :
do
	echo ''
        read -p "Do you want to install Pure-FTPd? (y/n) " FTP_yn
        if [ "$FTP_yn" != 'y' ] && [ "$FTP_yn" != 'n' ];then
                echo -e "\033[31minput error! Please input 'y' or 'n'\033[0m"
        else

        	if [ "$FTP_yn" == 'y' ];then
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
if [ ! -d "$wwwroot/default/phpMyAdmin" ];then
while :
do
	echo ''
        read -p "Do you want to install phpMyAdmin? (y/n) " phpMyAdmin_yn
        if [ "$phpMyAdmin_yn" != 'y' ] && [ "$phpMyAdmin_yn" != 'n' ];then
                echo -e "\033[31minput error! Please input 'y' or 'n'\033[0m"
        else
                break
        fi
done
fi

# check redis
if [ ! -d "$redis_install_dir" ];then
	while :
	do
		echo ''
		read -p "Do you want to install Redis? (y/n) " redis_yn
		if [ "$redis_yn" != 'y' ] && [ "$redis_yn" != 'n' ];then
	                echo -e "\033[31minput error! Please input 'y' or 'n'\033[0m"
		else
			break
		fi
	done
fi

# check memcached
if [ ! -d "$memcached_install_dir" ];then
        while :
        do
		echo ''
                read -p "Do you want to install memcached? (y/n) " memcached_yn
                if [ "$memcached_yn" != 'y' ] && [ "$memcached_yn" != 'n' ];then
                        echo -e "\033[31minput error! Please input 'y' or 'n'\033[0m"
                else
                        break
                fi
        done
fi

# check ngx_pagespeed
while :
do
	echo ''
        read -p "Do you want to install ngx_pagespeed? (y/n) " ngx_pagespeed_yn
        if [ "$ngx_pagespeed_yn" != 'y' ] && [ "$ngx_pagespeed_yn" != 'n' ];then
                echo -e "\033[31minput error! Please input 'y' or 'n'\033[0m"
        else
                break
        fi
done

# check tcmalloc
while :
do
        echo ''
        read -p "Do you want to optimize the system with tcmalloc? (y/n) " tcmalloc_yn
        if [ "$tcmalloc_yn" != 'y' ] && [ "$tcmalloc_yn" != 'n' ];then
                echo -e "\033[31minput error! Please input 'y' or 'n'\033[0m"
        else
                break
        fi
done

chmod +x functions/*.sh init/* *.sh

# init
. functions/check_os.sh
export IP upgrade_yn tcmalloc_yn
OS_CentOS='init/init_CentOS.sh 2>&1 | tee -a lnmp_install.log \n
/bin/mv init/init_CentOS.sh init/init_CentOS.ed'
OS_Ubuntu='init/init_Ubuntu.sh 2>&1 | tee -a lnmp_install.log \n
/bin/mv init/init_Ubuntu.sh init/init_Ubuntu.ed'
OS_command

# tcmalloc
[ "$tcmalloc_yn" == 'y' ] && ./functions/tcmalloc.sh | tee -a $lnmp_dir/lnmp_install.log

# Database
if [ $DB_version == 1 ];then
	cd $lnmp_dir
	. functions/mysql-5.6.sh 
	Install_MySQL-5.6 2>&1 | tee -a $lnmp_dir/lnmp_install.log 
elif [ $DB_version == 2 ];then
	cd $lnmp_dir
        . functions/mysql-5.5.sh
        Install_MySQL-5.5 2>&1 | tee -a $lnmp_dir/lnmp_install.log
elif [ $DB_version == 3 ];then
	cd $lnmp_dir
	. functions/mariadb-5.5.sh
	Install_MariaDB-5.5 2>&1 | tee -a $lnmp_dir/lnmp_install.log 
else
        echo -e "\033[31mdatabase install failed, Please contact the author! \033[0m"
        kill -9 $$
fi

# get db_install_dir
. ./options.conf

# PHP
if [ $PHP_version == 1 ];then
	. functions/php-5.5.sh
	Install_PHP-5.5 2>&1 | tee -a $lnmp_dir/lnmp_install.log
elif [ $PHP_version == 2 ];then
        . functions/php-5.4.sh
        Install_PHP-5.4 2>&1 | tee -a $lnmp_dir/lnmp_install.log
elif [ $PHP_version == 3 ];then
        . functions/php-5.3.sh
        Install_PHP-5.3 2>&1 | tee -a $lnmp_dir/lnmp_install.log
else
        echo -e "\033[31mPHP install failed, Please contact the author! \033[0m"
        kill -9 $$
fi

# PHP opcode cache (php <= 5.4)
if [ $PHP_cache == 1 ];then
        . functions/zendopcache.sh
        Install_ZendOPcache 2>&1 | tee -a $lnmp_dir/lnmp_install.log
elif [ $PHP_cache == 2 -a $PHP_version == 2 ];then
        . functions/eaccelerator-1.0-dev.sh
        Install_eAccelerator-1.0-dev 2>&1 | tee -a $lnmp_dir/lnmp_install.log
elif [ $PHP_cache == 2 -a $PHP_version == 3 ];then
        . functions/eaccelerator-0.9.sh
        Install_eAccelerator-0.9 2>&1 | tee -a $lnmp_dir/lnmp_install.log
fi

if [ ! -d "$nginx_install_dir" ];then
	. functions/nginx.sh
	Install_Nginx 2>&1 | tee -a $lnmp_dir/lnmp_install.log 
	sed -i "s@/usr/local/nginx@$nginx_install_dir@g" vhost.sh
	sed -i "s@/home/wwwroot@$home_dir@g" vhost.sh
	sed -i "s@/home/wwwlogs@$wwwlogs_dir@g" vhost.sh
fi

if [ "$FTP_yn" == 'y' ];then
	. functions/pureftpd.sh
	Install_Pureftpd 2>&1 | tee -a $lnmp_dir/lnmp_install.log 
fi

if [ "$phpMyAdmin_yn" == 'y' ];then
	. functions/phpmyadmin.sh
	Install_phpMyAdmin 2>&1 | tee -a $lnmp_dir/lnmp_install.log
fi

if [ "$redis_yn" == 'y' ];then
	. functions/redis.sh
	Install_Redis 2>&1 | tee -a $lnmp_dir/lnmp_install.log
fi

if [ "$memcached_yn" == 'y' ];then
	. functions/memcached.sh
	Install_memcached 2>&1 | tee -a $lnmp_dir/lnmp_install.log
fi

if [ ! -f "$home_dir/default/index.html" ];then
	. functions/test.sh
	TEST 2>&1 | tee -a $lnmp_dir/lnmp_install.log 
fi

if [ "$ngx_pagespeed_yn" == 'y' ];then
	. functions/ngx_pagespeed.sh
	Install_ngx_pagespeed 2>&1 | tee -a $lnmp_dir/lnmp_install.log
fi
echo "################Congratulations####################"
echo -e "\033[32mPlease restart the server and see if the services start up fine.\033[0m"
echo ''
echo "The path of some dirs:"
echo -e "`printf "%-32s" "Nginx dir":`\033[32m$nginx_install_dir\033[0m"
echo -e "`printf "%-32s" "PHP dir:"`\033[32m$php_install_dir\033[0m"
echo -e "`printf "%-32s" "Database Install dir:"`\033[32m$db_install_dir\033[0m"
echo -e "`printf "%-32s" "Database User:"`\033[32mroot\033[0m"
echo -e "`printf "%-32s" "Database Password:"`\033[32m${dbrootpwd}\033[0m"
echo -e "`printf "%-32s" "Manager url:"`\033[32mhttp://$IP/\033[0m"
