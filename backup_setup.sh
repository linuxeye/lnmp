#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       http://oneinstack.com
#       https://github.com/lj2007331/oneinstack

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#######################################################################
#       OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+      #
#                     Setup the backup parameters                     #
#       For more information please visit http://oneinstack.com       #
#######################################################################
"

. ./include/color.sh
. ./include/check_db.sh

# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

while : 
do
    echo
    echo 'Please select your backup destination:'
    echo -e "\t${CMSG}1${CEND}. Only Localhost"
    echo -e "\t${CMSG}2${CEND}. Only Remote host"
    echo -e "\t${CMSG}3${CEND}. Localhost and Remote host"
    read -p "Please input a number:(Default 1 press Enter) " DESC_BK 
    [ -z "$DESC_BK" ] && DESC_BK=1
    if [[ ! $DESC_BK =~ ^[1-3]$ ]];then
        echo "${CWARNING}input error! Please only input number 1,2,3${CEND}"
    else
        break
    fi
done

[ "$DESC_BK" == '1' ] && sed -i 's@^backup_destination=.*@backup_destination=local@' ./options.conf
[ "$DESC_BK" == '2' ] && sed -i 's@^backup_destination=.*@backup_destination=remote@' ./options.conf
[ "$DESC_BK" == '3' ] && sed -i 's@^backup_destination=.*@backup_destination=local,remote@' ./options.conf

while :
do
    echo
    echo 'Please select your backup content:'
    echo -e "\t${CMSG}1${CEND}. Only Database"
    echo -e "\t${CMSG}2${CEND}. Only Website"
    echo -e "\t${CMSG}3${CEND}. Database and Website"
    read -p "Please input a number:(Default 1 press Enter) " CONTENT_BK
    [ -z "$CONTENT_BK" ] && CONTENT_BK=1
    if [[ ! $CONTENT_BK =~ ^[1-3]$ ]];then
        echo "${CWARNING}input error! Please only input number 1,2,3${CEND}"
    else
        break
    fi
done

[ "$CONTENT_BK" == '1' ] && sed -i 's@^backup_content=.*@backup_content=db@' ./options.conf
[ "$CONTENT_BK" == '2' ] && sed -i 's@^backup_content=.*@backup_content=web@' ./options.conf
[ "$CONTENT_BK" == '3' ] && sed -i 's@^backup_content=.*@backup_content=db,web@' ./options.conf

. ./options.conf
. ./include/check_db.sh

while :
do
    echo
    echo "Please enter the directory for save the backup file: "
    read -p "(Default directory: $backup_dir): " NEW_backup_dir 
    [ -z "$NEW_backup_dir" ] && NEW_backup_dir="$backup_dir"
    if [ -z "`echo $NEW_backup_dir| grep '^/'`" ]; then
        echo "${CWARNING}input error! ${CEND}"
    else
        break
    fi
done
sed -i "s@^backup_dir=.*@backup_dir=$NEW_backup_dir@" ./options.conf

while :
do
    echo
    echo "Pleas enter a valid backup number of days: "
    read -p "(Default days: 5): " expired_days 
    [ -z "$expired_days" ] && expired_days=5
    [ -n "`echo $expired_days | sed -n "/^[0-9]\+$/p"`" ] && break || echo "${CWARNING}input error! Please only enter numbers! ${CEND}"
done
sed -i "s@^expired_days=.*@expired_days=$expired_days@" ./options.conf

if [ "$CONTENT_BK" != '2' ];then
    databases=`$db_install_dir/bin/mysql -uroot -p$dbrootpwd -e "show databases\G" | grep Database | awk '{print $2}' | grep -Evw "(performance_schema|information_schema|mysql|sys)"`
    while :
    do
        echo
        echo "Please enter one or more name for database, separate multiple database names with commas: "
        read -p "(Default database: `echo $databases | tr ' ' ','`) " db_name
        db_name=`echo $db_name | tr -d ' '`
        [ -z "$db_name" ] && db_name="`echo $databases | tr ' ' ','`"
        D_tmp=0
        for D in `echo $db_name | tr ',' ' '`
        do
            [ -z "`echo $databases | grep -w $D`" ] && { echo "${CWARNING}$D was not exist! ${CEND}" ; D_tmp=1; }
        done
        [ "$D_tmp" != '1' ] && break
    done
    sed -i "s@^db_name=.*@db_name=$db_name@" ./options.conf
fi

if [ "$CONTENT_BK" != '1' ];then
    websites=`ls $wwwroot_dir | grep -vw default`
    while :
    do
        echo
        echo "Please enter one or more name for website, separate multiple website names with commas: "
        read -p "(Default website: `echo $websites | tr ' ' ','`) " website_name 
        website_name=`echo $website_name | tr -d ' '`
        [ -z "$website_name" ] && website_name="`echo $websites | tr ' ' ','`"
        W_tmp=0
        for W in `echo $website_name | tr ',' ' '`
        do
            [ ! -e "$wwwroot_dir/$W" ] && { echo "${CWARNING}$wwwroot_dir/$W not exist! ${CEND}" ; W_tmp=1; }
        done
        [ "$W_tmp" != '1' ] && break
    done
    sed -i "s@^website_name=.*@website_name=$website_name@" ./options.conf
fi

echo
echo "You have to backup the content:"
[ "$CONTENT_BK" != '2' ] && echo "Database: ${CMSG}$db_name${CEND}"
[ "$CONTENT_BK" != '1' ] && echo "Website: ${CMSG}$website_name${CEND}"

if [[ "$DESC_BK" =~ ^[2,3]$ ]];then 
    > tools/iplist.txt
    while :
    do
        echo
        read -p "Please enter the remote host ip: " remote_ip
        [ -z "$remote_ip" -o "$remote_ip" == '127.0.0.1' ] && continue
        echo
        read -p "Please enter the remote host port(Default: 22) : " remote_port
        [ -z "$remote_port" ] && remote_port=22 
        echo
        read -p "Please enter the remote host user(Default: root) : " remote_user
        [ -z "$remote_user" ] && remote_user=root 
        echo
        read -p "Please enter the remote host password: " remote_password
        IPcode=$(echo "ibase=16;$(echo "$remote_ip" | xxd -ps -u)"|bc|tr -d '\\'|tr -d '\n')
        Portcode=$(echo "ibase=16;$(echo "$remote_port" | xxd -ps -u)"|bc|tr -d '\\'|tr -d '\n')
        PWcode=$(echo "ibase=16;$(echo "$remote_password" | xxd -ps -u)"|bc|tr -d '\\'|tr -d '\n')
        [ -e "~/.ssh/known_hosts" ] && grep $remote_ip ~/.ssh/known_hosts | sed -i "/$remote_ip/d" ~/.ssh/known_hosts
        ./tools/mssh.exp ${IPcode}P $remote_user ${PWcode}P ${Portcode}P true 10
        if [ $? -eq 0 ];then
            [ -z "`grep $remote_ip tools/iplist.txt`" ] && echo "$remote_ip $remote_port $remote_user $remote_password" >> tools/iplist.txt || echo "${CWARNING}$remote_ip has been added! ${CEND}"
            while :
            do
                read -p "Do you want to add more host ? [y/n]: " more_host_yn 
                if [[ ! "$more_host_yn" =~ ^[y,n]$ ]];then
                    echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
                else
                    break
                fi
            done
            [ "$more_host_yn" == 'n' ] && break
        fi
    done
fi
