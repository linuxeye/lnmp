#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_MariaDB-5-5()
{
cd $lnmp_dir/src
. ../functions/download.sh 
. ../functions/check_os.sh
. ../options.conf

src_url=http://www.cmake.org/files/v3.0/cmake-3.0.0.tar.gz && Download_src 
src_url=https://downloads.mariadb.org/f/mariadb-5.5.38/source/mariadb-5.5.38.tar.gz && Download_src 

useradd -M -s /sbin/nologin mysql
mkdir -p $mariadb_data_dir;chown mysql.mysql -R $mariadb_data_dir
if [ ! -e "`which cmake`" ];then
        tar xzf cmake-3.0.0.tar.gz
        cd cmake-3.0.0
        CFLAGS= CXXFLAGS= ./configure
        make && make install
        cd ..
	/bin/rm -rf cmake-3.0.0
fi
tar zxf mariadb-5.5.38.tar.gz
cd mariadb-5.5.38
if [ "$je_tc_malloc" == '1' ];then
	EXE_LINKER="-DCMAKE_EXE_LINKER_FLAGS='-ljemalloc'"
elif [ "$je_tc_malloc" == '2' ];then
	EXE_LINKER="-DCMAKE_EXE_LINKER_FLAGS='-ltcmalloc'"
fi
make clean
cmake . -DCMAKE_INSTALL_PREFIX=$mariadb_install_dir \
-DMYSQL_DATADIR=$mariadb_data_dir \
-DWITH_ARIA_STORAGE_ENGINE=1 \
-DWITH_XTRADB_STORAGE_ENGINE=1 \
-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_FEDERATEDX_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DENABLED_LOCAL_INFILE=1 \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_EMBEDDED_SERVER=1 \
$EXE_LINKER
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
OS_Debian_Ubuntu='update-rc.d mysqld defaults'
OS_command
cd ..
/bin/rm -rf mariadb-5.5.38 
cd ..

# my.cf
cat > /etc/my.cnf << EOF
[client]
port = 3306
socket = /tmp/mysql.sock

[mysqld]
port = 3306
socket = /tmp/mysql.sock

basedir = $mariadb_install_dir
datadir = $mariadb_data_dir
pid-file = $mariadb_data_dir/mysql.pid
user = mysql
bind-address = 0.0.0.0
server-id = 1

skip-name-resolve
#skip-networking
back_log = 300

max_connections = 1000
max_connect_errors = 6000
open_files_limit = 65535
table_open_cache = 128 
max_allowed_packet = 4M
binlog_cache_size = 1M
max_heap_table_size = 8M
tmp_table_size = 16M

read_buffer_size = 2M
read_rnd_buffer_size = 8M
sort_buffer_size = 8M
join_buffer_size = 8M
key_buffer_size = 4M

thread_cache_size = 8

query_cache_type = 1
query_cache_size = 8M
query_cache_limit = 2M

ft_min_word_len = 4

log_bin = mysql-bin
binlog_format = mixed
expire_logs_days = 30

log_error = $mariadb_data_dir/mysql-error.log
slow_query_log = 1
long_query_time = 1
slow_query_log_file = $mariadb_data_dir/mysql-slow.log

performance_schema = 0

#lower_case_table_names = 1

skip-external-locking

default_storage_engine = InnoDB
#default-storage-engine = MyISAM
innodb_file_per_table = 1
innodb_open_files = 500
innodb_buffer_pool_size = 64M
innodb_write_io_threads = 4
innodb_read_io_threads = 4
innodb_thread_concurrency = 0
innodb_purge_threads = 1
innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 2M
innodb_log_file_size = 32M
innodb_log_files_in_group = 3
innodb_max_dirty_pages_pct = 90
innodb_lock_wait_timeout = 120

bulk_insert_buffer_size = 8M
myisam_sort_buffer_size = 8M
myisam_max_sort_file_size = 10G
myisam_repair_threads = 1

interactive_timeout = 28800
wait_timeout = 28800

[mysqldump]
quick
max_allowed_packet = 16M

[myisamchk]
key_buffer_size = 8M
sort_buffer_size = 8M
read_buffer = 4M
write_buffer = 4M
EOF

Memtatol=`free -m | grep 'Mem:' | awk '{print $2}'`
if [ $Memtatol -gt 1500 -a $Memtatol -le 2500 ];then
        sed -i 's@^thread_cache_size.*@thread_cache_size = 16@' /etc/my.cnf
        sed -i 's@^query_cache_size.*@query_cache_size = 16M@' /etc/my.cnf
        sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 16M@' /etc/my.cnf
        sed -i 's@^key_buffer_size.*@key_buffer_size = 16M@' /etc/my.cnf
        sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 128M@' /etc/my.cnf
        sed -i 's@^tmp_table_size.*@tmp_table_size = 32M@' /etc/my.cnf
        sed -i 's@^table_open_cache.*@table_open_cache = 256@' /etc/my.cnf
elif [ $Memtatol -gt 2500 -a $Memtatol -le 3500 ];then
        sed -i 's@^thread_cache_size.*@thread_cache_size = 32@' /etc/my.cnf
        sed -i 's@^query_cache_size.*@query_cache_size = 32M@' /etc/my.cnf
        sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 32M@' /etc/my.cnf
        sed -i 's@^key_buffer_size.*@key_buffer_size = 64M@' /etc/my.cnf
        sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 512M@' /etc/my.cnf
        sed -i 's@^tmp_table_size.*@tmp_table_size = 64M@' /etc/my.cnf
        sed -i 's@^table_open_cache.*@table_open_cache = 512@' /etc/my.cnf
elif [ $Memtatol -gt 3500 ];then
        sed -i 's@^thread_cache_size.*@thread_cache_size = 64@' /etc/my.cnf
        sed -i 's@^query_cache_size.*@query_cache_size = 64M@' /etc/my.cnf
        sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 64M@' /etc/my.cnf
        sed -i 's@^key_buffer_size.*@key_buffer_size = 256M@' /etc/my.cnf
        sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 1024M@' /etc/my.cnf
        sed -i 's@^tmp_table_size.*@tmp_table_size = 128M@' /etc/my.cnf
        sed -i 's@^table_open_cache.*@table_open_cache = 1024@' /etc/my.cnf
fi

$mariadb_install_dir/scripts/mysql_install_db --user=mysql --basedir=$mariadb_install_dir --datadir=$mariadb_data_dir

chown mysql.mysql -R $mariadb_data_dir
service mysqld start
export PATH=$mariadb_install_dir/bin:$PATH
[ -z "`cat /etc/profile | grep $mariadb_install_dir`" ] && echo "export PATH=$mariadb_install_dir/bin:\$PATH" >> /etc/profile 
. /etc/profile

$mariadb_install_dir/bin/mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"$dbrootpwd\" with grant option;"
$mariadb_install_dir/bin/mysql -e "grant all privileges on *.* to root@'localhost' identified by \"$dbrootpwd\" with grant option;"
$mariadb_install_dir/bin/mysql -uroot -p$dbrootpwd -e "delete from mysql.user where Password='';"
$mariadb_install_dir/bin/mysql -uroot -p$dbrootpwd -e "delete from mysql.db where User='';"
$mariadb_install_dir/bin/mysql -uroot -p$dbrootpwd -e "delete from mysql.proxies_priv where Host!='localhost';"
$mariadb_install_dir/bin/mysql -uroot -p$dbrootpwd -e "drop database test;"
$mariadb_install_dir/bin/mysql -uroot -p$dbrootpwd -e "reset master;"
sed -i "s@^db_install_dir.*@db_install_dir=$mariadb_install_dir@" options.conf
sed -i "s@^db_data_dir.*@db_data_dir=$mariadb_data_dir@" options.conf
service mysqld stop
}
