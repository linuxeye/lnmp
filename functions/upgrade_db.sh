#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Upgrade_DB()
{
cd $lnmp_dir/src
[ ! -e "$db_install_dir/bin/mysql" ] && echo -e "\033[31mThe MySQL/MariaDB/Percona is not installed on your system!\033[0m " && exit 1
DB_version_tmp=`$db_install_dir/bin/mysql -V | awk '{print $5}' | awk -F, '{print $1}'`
DB_tmp=`echo $DB_version_tmp | awk -F'-' '{print $2}'`
if [ "$DB_tmp" == 'MariaDB' ];then
	public_IP=`../functions/get_public_ip.py`
	if [ "`../functions/get_ip_area.py $public_IP`" == '\u4e2d\u56fd' ];then
	        FLAG_IP=CN
	fi
	[ "$FLAG_IP"x == "CN"x ] && DOWN_ADDR=http://mirrors.aliyun.com/mariadb || DOWN_ADDR=https://downloads.mariadb.org/f
	[ -d "/lib64" ] && { SYS_BIT_a=x86_64;SYS_BIT_b=x86_64; } || { SYS_BIT_a=x86;SYS_BIT_b=i686; }
	LIBC_VERSION=`getconf -a | grep GNU_LIBC_VERSION | awk '{print $NF}'`
	LIBC_YN=`echo "$LIBC_VERSION < 2.14" | bc`
	[ $LIBC_YN == '1' ] && GLIBC_FLAG=linux || GLIBC_FLAG=linux-glibc_214

	DB=MariaDB
	Old_DB_version=`echo $DB_version_tmp | awk -F'-' '{print $1}'`
elif [ -n "$DB_tmp" -a "$DB_tmp" != 'MariaDB' ];then
	DB=Percona
	Old_DB_version=$DB_version_tmp
else
	DB=MySQL
	Old_DB_version=$DB_version_tmp
fi

#backup
while :
do
        $db_install_dir/bin/mysql -uroot -p${dbrootpwd} -e "quit" >/dev/null 2>&1
        if [ $? -eq 0 ];then
                break
        else
                echo
                read -p "Please input the root password of database: " NEW_dbrootpwd
                $db_install_dir/bin/mysql -uroot -p${NEW_dbrootpwd} -e "quit" >/dev/null 2>&1
                if [ $? -eq 0 ];then
                        dbrootpwd=$NEW_dbrootpwd
                        sed -i "s+^dbrootpwd.*+dbrootpwd='$dbrootpwd'+" ../options.conf
                        break
                else
                        echo -e "\033[31m$DB root password incorrect,Please enter again! \033[0m"
                fi
        fi

done
echo
echo -e "\033[32mStarting $DB backup......\033[0m"
$db_install_dir/bin/mysqldump -uroot -p${dbrootpwd} --opt --all-databases > DB_all_backup_$(date +"%Y%m%d").sql
[ -f "DB_all_backup_$(date +"%Y%m%d").sql" ] && echo -e "$DB backup success, Backup file: \033[32m`pwd`/DB_all_backup_$(date +"%Y%m%d").sql\033[0m"

#upgrade
echo
echo -e "Current $DB Version: \033[32m$Old_DB_version\033[0m"
[ -e /usr/local/lib/libtcmalloc.so ] && { je_tc_malloc=2; EXE_LINKER="-DCMAKE_EXE_LINKER_FLAGS='-ltcmalloc'"; }
[ -e /usr/local/lib/libjemalloc.so ] && { je_tc_malloc=1; EXE_LINKER="-DCMAKE_EXE_LINKER_FLAGS='-ljemalloc'"; }

while :
do
        echo
        read -p "Please input upgrade $DB Version(example: 5.6.25): " DB_version
        if [ `echo $DB_version | awk -F. '{print $1"."$2}'` == `echo $Old_DB_version | awk -F. '{print $1"."$2}'` ]; then
		if [ "$DB" == 'MariaDB' ];then
			DB_name=mariadb-${DB_version}-${GLIBC_FLAG}-${SYS_BIT_b}
			DB_URL=$DOWN_ADDR/mariadb-${DB_version}/bintar-${GLIBC_FLAG}-$SYS_BIT_a/$DB_name.tar.gz
		elif [ "$DB" == 'Percona' ];then
			DB_name=percona-server-$DB_version
			DB_URL=http://www.percona.com/redir/downloads/Percona-Server-`echo $DB_version | awk -F. '{print $1"."$2}'`/LATEST/source/tarball/$DB_name.tar.gz
		elif [ "$DB" == 'MySQL' ];then
			DB_name=mysql-$DB_version
			DB_URL=http://cdn.mysql.com/Downloads/MySQL-`echo $DB_version | awk -F. '{print $1"."$2}'`/$DB_name.tar.gz
		fi
                [ ! -e "$DB_name.tar.gz" ] && wget -c $DB_URL > /dev/null 2>&1
		
                if [ -e "$DB_name.tar.gz" ];then
                        echo -e "Download \033[32m$DB_name.tar.gz\033[0m successfully! "
                else
                        echo -e "\033[31mIt does not exist!\033[0m"
                fi
                break
        else
                echo -e "\033[31minput error!\033[0m Please only input '\033[32m${Old_DB_version%.*}.xx' \033[0m"
        fi
done

if [ -e "$DB_name.tar.gz" ];then
        echo -e "\033[32m$DB_name.tar.gz\033[0m [found]"
        echo "Press Ctrl+c to cancel or Press any key to continue..."
        char=`get_char`
	if [ "$DB" == 'MariaDB' ];then 
		service mysqld stop
		mv ${db_install_dir}{,_old_`date +"%Y%m%d"`}
		mv ${db_data_dir}{,_old_`date +"%Y%m%d"`}
		mkdir -p $db_data_dir;chown mysql.mysql -R $db_data_dir
		tar xzf $DB_name.tar.gz
		[ ! -d "$db_install_dir" ] && mkdir -p $db_install_dir
		mv mariadb-${DB_version}-linux-${SYS_BIT_b}/* $db_install_dir
		if [ "$je_tc_malloc" == '1' ];then
		        sed -i 's@executing mysqld_safe@executing mysqld_safe\nexport LD_PRELOAD=/usr/local/lib/libjemalloc.so@' $db_install_dir/bin/mysqld_safe
		elif [ "$je_tc_malloc" == '2' ];then
		        sed -i 's@executing mysqld_safe@executing mysqld_safe\nexport LD_PRELOAD=/usr/local/lib/libtcmalloc.so@' $db_install_dir/bin/mysqld_safe
		fi
		$db_install_dir/scripts/mysql_install_db --user=mysql --basedir=$db_install_dir --datadir=$db_data_dir
		chown mysql.mysql -R $db_data_dir
		service mysqld start
		$db_install_dir/bin/mysql < DB_all_backup_$(date +"%Y%m%d").sql 
		service mysqld restart
		$db_install_dir/bin/mysql -uroot -p${dbrootpwd} -e "drop database test;" >/dev/null 2>&1
		$db_install_dir/bin/mysql -uroot -p${dbrootpwd} -e "reset master;" >/dev/null 2>&1
                [ $? -eq 0 ] &&  echo -e "You have \033[32m$DB successfully\033[0m upgrade from \033[32m$Old_DB_version\033[0m to \033[32m$DB_version\033[0m"
	elif [ "$DB" == 'Percona' ];then
		tar zxf $DB_name.tar.gz 
		cd $DB_name
		make clean
		if [ "`echo $DB_version | awk -F. '{print $1"."$2}'`" == '5.5' ];then
			cmake . -DCMAKE_INSTALL_PREFIX=$db_install_dir \
-DMYSQL_DATADIR=$db_data_dir \
-DSYSCONFDIR=/etc \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_FEDERATED_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DENABLE_DTRACE=0 \
-DENABLED_LOCAL_INFILE=1 \
-DDEFAULT_CHARSET=utf8mb4 \
-DDEFAULT_COLLATION=utf8mb4_general_ci \
$EXE_LINKER
		else
			cmake . -DCMAKE_INSTALL_PREFIX=$db_install_dir \
-DMYSQL_DATADIR=$db_data_dir \
-DSYSCONFDIR=/etc \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_FEDERATED_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DENABLE_DTRACE=0 \
-DDEFAULT_CHARSET=utf8mb4 \
-DDEFAULT_COLLATION=utf8mb4_general_ci \
$EXE_LINKER
		fi
		make -j `grep processor /proc/cpuinfo | wc -l`
		service mysqld stop
		mv ${db_install_dir}{,_old_`date +"%Y%m%d"`}
                mv ${db_data_dir}{,_old_`date +"%Y%m%d"`}
		[ ! -d "$db_install_dir" ] && mkdir -p $db_install_dir
                mkdir -p $db_data_dir;chown mysql.mysql -R $db_data_dir
		make install
		cd ..
		$db_install_dir/scripts/mysql_install_db --user=mysql --basedir=$db_install_dir --datadir=$db_data_dir
                chown mysql.mysql -R $db_data_dir
                service mysqld start
		$db_install_dir/bin/mysql < DB_all_backup_$(date +"%Y%m%d").sql
                service mysqld restart
		$db_install_dir/bin/mysql -uroot -p${dbrootpwd} -e "drop database test;" >/dev/null 2>&1
		$db_install_dir/bin/mysql -uroot -p${dbrootpwd} -e "reset master;" >/dev/null 2>&1
                [ $? -eq 0 ] &&  echo -e "You have \033[32m$DB successfully\033[0m upgrade from \033[32m$Old_DB_version\033[0m to \033[32m$DB_version\033[0m"
	elif [ "$DB" == 'MySQL' ];then
		tar zxf $DB_name.tar.gz
                cd $DB_name
                make clean
                if [ "`echo $DB_version | awk -F. '{print $1"."$2}'`" == '5.5' ];then
                        cmake . -DCMAKE_INSTALL_PREFIX=$db_install_dir \
-DMYSQL_DATADIR=$db_data_dir \
-DSYSCONFDIR=/etc \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_FEDERATED_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DENABLE_DTRACE=0 \
-DDEFAULT_CHARSET=utf8mb4 \
-DDEFAULT_COLLATION=utf8mb4_general_ci \
-DWITH_EMBEDDED_SERVER=1 \
$EXE_LINKER
                else
                        cmake . -DCMAKE_INSTALL_PREFIX=$db_install_dir \
-DMYSQL_DATADIR=$db_data_dir \
-DSYSCONFDIR=/etc \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_FEDERATED_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DENABLE_DTRACE=0 \
-DDEFAULT_CHARSET=utf8mb4 \
-DDEFAULT_COLLATION=utf8mb4_general_ci \
-DWITH_EMBEDDED_SERVER=1 \
$EXE_LINKER
                fi
		make -j `grep processor /proc/cpuinfo | wc -l`
		service mysqld stop
                mv ${db_install_dir}{,_old_`date +"%Y%m%d"`}
                mv ${db_data_dir}{,_old_`date +"%Y%m%d"`}
                [ ! -d "$db_install_dir" ] && mkdir -p $db_install_dir
                mkdir -p $db_data_dir;chown mysql.mysql -R $db_data_dir
                make install
		cd ..
		$db_install_dir/scripts/mysql_install_db --user=mysql --basedir=$db_install_dir --datadir=$db_data_dir
                chown mysql.mysql -R $db_data_dir
                service mysqld start
                $db_install_dir/bin/mysql < DB_all_backup_$(date +"%Y%m%d").sql
                service mysqld restart
		$db_install_dir/bin/mysql -uroot -p${dbrootpwd} -e "drop database test;" >/dev/null 2>&1
		$db_install_dir/bin/mysql -uroot -p${dbrootpwd} -e "reset master;" >/dev/null 2>&1
                [ $? -eq 0 ] &&  echo -e "You have \033[32m$DB successfully\033[0m upgrade from \033[32m$Old_DB_version\033[0m to \033[32m$DB_version\033[0m"
	fi 
fi
}
