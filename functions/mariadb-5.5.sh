#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_MariaDB-5.5()
{
cd $lnmp_dir/src
. ../functions/download.sh 
. ../functions/check_os.sh
. ../options.conf

src_url=http://www.cmake.org/files/v2.8/cmake-2.8.11.2.tar.gz && Download_src 
src_url=http://ftp.osuosl.org/pub/mariadb/mariadb-5.5.32/kvm-tarbake-jaunty-x86/mariadb-5.5.32.tar.gz && Download_src 

useradd -M -s /sbin/nologin mysql
mkdir -p $mariadb_data_dir;chown mysql.mysql -R $mariadb_data_dir
tar xzf cmake-2.8.11.2.tar.gz
cd cmake-2.8.11.2
./configure
make &&  make install
cd ..
tar zxf mariadb-5.5.32.tar.gz
cd mariadb-5.5.32
cmake . -DCMAKE_INSTALL_PREFIX=$mariadb_install_dir \
-DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
-DMYSQL_DATADIR=$mariadb_data_dir \
-DSYSCONFDIR=/etc \
-DMYSQL_USER=mysql \
-DMYSQL_TCP_PORT=3306 \
-DWITH_ARIA_STORAGE_ENGINE=1 \
-DWITH_XTRADB_STORAGE_ENGINE=1 \
-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DEXTRA_CHARSETS=all \
-DWITH_BIG_TABLES=1 \
-DWITH_DEBUG=0
make && make install

if [ -d "$mariadb_install_dir" ];then
        echo -e "\033[32mMariaDB install successfully! \033[0m"
else
        echo -e "\033[31mMariaDB install failed, Please contact the author! \033[0m"
        kill -9 $$
fi

/bin/cp support-files/my-small.cnf /etc/my.cnf
/bin/cp support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
OS_CentOS='chkconfig --add mysqld \n
chkconfig mysqld on'
OS_Ubuntu='update-rc.d mysqld defaults'
OS_command

# my.cf
cat > /etc/my.cnf << EOF
[mysqld]
basedir = $mariadb_install_dir
datadir = $mariadb_data_dir
pid-file = $mariadb_data_dir/mariadb.pid
character-set-server = utf8
collation-server = utf8_general_ci
user = mysql
port = 3306
default_storage_engine = InnoDB
innodb_file_per_table = 1
server_id = 1
log_bin = mysql-bin
binlog_format = mixed
expire_logs_days = 7
bind-address = 0.0.0.0

# name-resolve
skip-name-resolve
skip-host-cache

#lower_case_table_names = 1
ft_min_word_len = 1
query_cache_size = 64M
query_cache_type = 1

skip-external-locking
key_buffer_size = 16M
max_allowed_packet = 1M
table_open_cache = 64
sort_buffer_size = 512K
net_buffer_length = 8K
read_buffer_size = 256K
read_rnd_buffer_size = 512K
myisam_sort_buffer_size = 8M

# LOG
log_error = $mariadb_data_dir/mariadb-error.log
long_query_time = 1
slow_query_log
slow_query_log_file = $mariadb_data_dir/mariadb-slow.log

# Oher
#max_connections = 1000
open_files_limit = 65535

[client]
port = 3306
EOF

$mariadb_install_dir/scripts/mysql_install_db --user=mysql --basedir=$mariadb_install_dir --datadir=$mariadb_data_dir

chown mysql.mysql -R $mariadb_data_dir
service mysqld start
export PATH=$PATH:$mariadb_install_dir/bin
echo "export PATH=\$PATH:$mariadb_install_dir/bin" >> /etc/profile
. /etc/profile

$mariadb_install_dir/bin/mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"$dbrootpwd\" with grant option;"
$mariadb_install_dir/bin/mysql -e "grant all privileges on *.* to root@'localhost' identified by \"$dbrootpwd\" with grant option;"
$mariadb_install_dir/bin/mysql -uroot -p$dbrootpwd -e "delete from mysql.user where Password='';"
$mariadb_install_dir/bin/mysql -uroot -p$dbrootpwd -e "delete from mysql.db where User='';"
$mariadb_install_dir/bin/mysql -uroot -p$dbrootpwd -e "drop database test;"
$mariadb_install_dir/bin/mysql -uroot -p$dbrootpwd -e "reset master;"
cd ../
sed -i "s@^db_install_dir.*@db_install_dir=$mariadb_install_dir@" options.conf
sed -i "s@^db_data_dir.*@db_data_dir$mariadb_data_dir@" options.conf
service mysqld stop
cd ../../
}
