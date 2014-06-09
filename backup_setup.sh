#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

while : 
do
	echo
	echo 'Please select your backup destination:'
	echo -e "\t\033[32m1\033[0m. Only Localhost"
	echo -e "\t\033[32m2\033[0m. Only Remote host"
	echo -e "\t\033[32m3\033[0m. Localhost and remote host"
	read -p "Please input a number:(Default 1 press Enter) " DESC_BK 
	[ -z "$DESC_BK" ] && DESC_BK=1
	if [ $DESC_BK != 1 -a $DESC_BK != 2 -a $DESC_BK != 3 ];then
	        echo -e "\033[31minput error! Please only input number 1,2,3\033[0m"
	else
	        break
	fi
done

[ "$DESC_BK" == '1' ] && { sed -i 's@^local_bankup_yn=.*@local_bankup_yn=y@' ./options.conf; sed -i 's@remote_bankup_yn=.*@remote_bankup_yn=n@' ./options.conf; }
[ "$DESC_BK" == '2' ] && { sed -i 's@^local_bankup_yn=.*@local_bankup_yn=n@' ./options.conf; sed -i 's@remote_bankup_yn=.*@remote_bankup_yn=y@' ./options.conf; }
[ "$DESC_BK" == '3' ] && { sed -i 's@^local_bankup_yn=.*@local_bankup_yn=y@' ./options.conf; sed -i 's@remote_bankup_yn=.*@remote_bankup_yn=y@' ./options.conf; }

. ./options.conf

while :
do
	echo
	echo "Please enter the directory for save the backup file: "
	read -p "(Default directory: /home/backup): " backup_dir 
	[ -z "$backup_dir" ] && backup_dir="/home/backup"
        if [ -z "`echo $backup_dir | grep '^/'`" ]; then
                echo -e "\033[31minput error! \033[0m"
        else
                break
        fi
done
sed -i "s@^backup_dir=.*@backup_dir=$backup_dir@" ./options.conf

while :
do
	echo
	echo "Pleas enter a valid backup number of days: "
	read -p "(Default days: 5): " expired_days 
	[ -z "$expired_days" ] && expired_days=5
	[ -n "`echo $expired_days | sed -n "/^[0-9]\+$/p"`" ] && break || echo -e "\033[31minput error! Please only enter numbers! \033[0m"
done
sed -i "s@^expired_days=.*@expired_days=$expired_days@" ./options.conf

databases=`$db_install_dir/bin/mysql -uroot -p$dbrootpwd -e "show databases\G" | grep Database | awk '{print $2}' | grep -Evw "(performance_schema|information_schema|mysql|ftpusers)"`
while :
do
	echo
	echo "Please enter one or more name for database, separate multiple database names with commas: "
	read -p "(Default database: `echo $databases | tr ' ' ','`) " db_name
	db_name=`echo $db_name | tr -d ' '`
	[ -z "$db_name" ] && db_name="`echo $databases | tr ' ' ','`"
	D_tmp=0
	echo $db_name
	for D in `echo $db_name | tr ',' ' '`
	do
		[ -z "`echo $databases | grep -w $D`" ] && { echo -e "\033[31m$D not exist! \033[0m" ; D_tmp=1; }
	done
	[ "$D_tmp" != '1' ] && break
done
sed -i "s@^db_name=.*@db_name=$db_name@" ./options.conf

websites=`ls $home_dir | grep -vw default`
while :
do
        echo
        echo "Please enter one or more name for website, separate multiple website names with commas: "
        read -p "(Default website: `echo $websites | tr ' ' ','`) " website_name 
        website_name=`echo $website_name | tr -d ' '`
        [ -z "$website_name" ] && website_name="`echo $websites | tr ' ' ','`"
        W_tmp=0
        echo $db_name
        for W in `echo $website_name | tr ',' ' '`
        do
                [ ! -e "$home_dir/$W" ] && { echo -e "\033[31m$home_dir/$W not exist! \033[0m" ; W_tmp=1; }
        done
        [ "$W_tmp" != '1' ] && break
done
echo $website_name
sed -i "s@^website_name=.*@website_name=$website_name@" ./options.conf

if [ "$remote_bankup_yn" == 'y' ];then
	> tools/iplist.txt
	while :
	do
		echo
		read -p "Please enter the remote host ip: " remote_ip
		[ -z "$remote_ip" ] && continue
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
			[ -z "`grep $remote_ip tools/iplist.txt`" ] && echo "$remote_ip $remote_port $remote_user $remote_password" >> tools/iplist.txt || echo -e "\033[31m$remote_ip has been added! \033[0m" 
			while :
			do
				echo
			        read -p "Do you want to add more host ? [y/n]: " more_host_yn 
			        if [ "$more_host_yn" != 'y' -a "$more_host_yn" != 'n' ];then
			                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
			        else
					break
				fi
			done
			[ "$more_host_yn" == 'n' ] && break
		fi
	done
fi
