#!/bin/bash
. ./options.conf
if [ ! -d "$php_install_dir" ];then
        while :
        do
                echo -e "\t\033[32m1\033[0m. Install php-5.5"
                echo -e "\t\033[32m1\033[0m. Install php-5.4"
                echo -e "\t\033[32m1\033[0m. Install php-5.3"
                read -p "Please input a number:(Default 1) " PHP_version
                [ -z "$PHP_version" ] && PHP_version=1
                if [ $PHP_version != 1 ] && [ $PHP_version != 2 ] && [ $PHP_version != 3 ];then
                        echo -e "\033[31minput error! Please input 1 2 3 \033[0m"
                else
                        break
                fi
        done
fi
echo $PHP_version
