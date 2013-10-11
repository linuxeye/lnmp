#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com
Install_MySQL-5-5()
{
cd $lnmp_dir/src
. ../functions/download.sh 
. ../functions/check_os.sh
. ../options.conf

src_url=http://www.cmake.org/files/v2.8/cmake-2.8.11.2.tar.gz && Download_src 
src_url=http://cdn.mysql.com/Downloads/MySQL-5.5/mysql-5.5.34.tar.gz && Download_src

useradd -M -s /sbin/nologin mysql
mkdir -p $mysql_data_dir;chown mysql.mysql -R $mysql_data_dir
tar xzf cmake-2.8.11.2.tar.gz
cd cmake-2.8.11.2
CFLAGS= CXXFLAGS= ./configure
make && make install
cd ..
tar zxf mysql-5.5.34.tar.gz
cd mysql-5.5.34
if [ "$je_tc_malloc" == '1' ];then
        EXE_LINKER="-DCMAKE_EXE_LINKER_FLAGS='-ljemalloc'"
elif [ "$je_tc_malloc" == '2' ];then
        EXE_LINKER="-DCMAKE_EXE_LINKER_FLAGS='-ltcmalloc'"
fi
cmake . -DCMAKE_INSTALL_PREFIX=$mysql_install_dir \
-DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
-DMYSQL_DATADIR=$mysql_data_dir \
-DSYSCONFDIR=/etc \
-DMYSQL_TCP_PORT=3306 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_EXTRA_CHARSETS=all \
-DWITH_DEBUG=0 \
$EXE_LINKER
make && make install

if [ -d "$mysql_install_dir" ];then
        echo -e "\033[32mMySQL install successfully! \033[0m"
else
        echo -e "\033[31mMySQL install failed, Please contact the author! \033[0m"
        kill -9 $$
fi

/bin/cp support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
OS_CentOS='chkconfig --add mysqld \n
chkconfig mysqld on'
OS_Debian_Ubuntu='update-rc.d mysqld defaults'
OS_command
cd ../../

# my.cf
cat > /etc/my.cnf << EOF
[mysqld]
basedir = $mysql_install_dir
datadir = $mysql_data_dir
pid-file = $mysql_data_dir/mysql.pid
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
log_error = $mysql_data_dir/mysql-error.log
long_query_time = 1
slow_query_log
slow_query_log_file = $mysql_data_dir/mysql-slow.log

# Oher
#max_connections = 1000
open_files_limit = 65535

[client]
port = 3306
EOF

$mysql_install_dir/scripts/mysql_install_db --user=mysql --basedir=$mysql_install_dir --datadir=$mysql_data_dir

chown mysql.mysql -R $mysql_data_dir
service mysqld start
export PATH=$PATH:$mysql_install_dir/bin
echo "export PATH=\$PATH:$mysql_install_dir/bin" >> /etc/profile
. /etc/profile

$mysql_install_dir/bin/mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"$dbrootpwd\" with grant option;"
$mysql_install_dir/bin/mysql -e "grant all privileges on *.* to root@'localhost' identified by \"$dbrootpwd\" with grant option;"
$mysql_install_dir/bin/mysql -uroot -p$dbrootpwd -e "delete from mysql.user where Password='';"
$mysql_install_dir/bin/mysql -uroot -p$dbrootpwd -e "delete from mysql.db where User='';"
$mysql_install_dir/bin/mysql -uroot -p$dbrootpwd -e "drop database test;"
$mysql_install_dir/bin/mysql -uroot -p$dbrootpwd -e "reset master;"
sed -i "s@^db_install_dir.*@db_install_dir=$mysql_install_dir@" options.conf
sed -i "s@^db_data_dir.*@db_data_dir=$mysql_data_dir@" options.conf
service mysqld stop
}
