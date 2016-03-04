#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       http://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_Percona-5-7() {
cd $oneinstack_dir/src
[ "$IPADDR_STATE"x == "CN"x ] && DOWN_ADDR_BOOST=http://mirrors.linuxeye.com/oneinstack/src || DOWN_ADDR_BOOST=http://downloads.sourceforge.net/project/boost/boost/1.59.0

if [ ! -e "/usr/local/lib/libboost_system.so" ];then
    src_url=$DOWN_ADDR_BOOST/boost_1_59_0.tar.gz && Download_src
    tar xzf boost_1_59_0.tar.gz
    cd boost_1_59_0
    ./bootstrap.sh
    ./bjam --prefix=/usr/local
    ./b2 install
    cd ..
fi
echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
ldconfig

src_url=http://mirrors.linuxeye.com/oneinstack/src/percona-server-$percona_5_7_version.tar.gz && Download_src

id -u mysql >/dev/null 2>&1
[ $? -ne 0 ] && useradd -M -s /sbin/nologin mysql

mkdir -p $percona_data_dir;chown mysql.mysql -R $percona_data_dir
tar zxf percona-server-$percona_5_7_version.tar.gz 
cd percona-server-$percona_5_7_version 
if [ "$je_tc_malloc" == '1' ];then
    EXE_LINKER="-DCMAKE_EXE_LINKER_FLAGS='-ljemalloc'"
elif [ "$je_tc_malloc" == '2' ];then
    EXE_LINKER="-DCMAKE_EXE_LINKER_FLAGS='-ltcmalloc'"
fi
make clean
[ ! -d "$percona_install_dir" ] && mkdir -p $percona_install_dir
cmake . -DCMAKE_INSTALL_PREFIX=$percona_install_dir \
-DMYSQL_DATADIR=$percona_data_dir \
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
make -j `grep processor /proc/cpuinfo | wc -l` 
make install

if [ -d "$percona_install_dir/support-files" ];then
    echo "${CSUCCESS}Percona install successfully! ${CEND}"
    cd ..
    rm -rf percona-server-$percona_5_7_version 
else
    rm -rf $percona_install_dir
    echo "${CFAILURE}Percona install failed, Please contact the author! ${CEND}"
    kill -9 $$
fi

/bin/cp $percona_install_dir/support-files/mysql.server /etc/init.d/mysqld
chmod +x /etc/init.d/mysqld
[ "$OS" == 'CentOS' ] && { chkconfig --add mysqld; chkconfig mysqld on; }
[[ $OS =~ ^Ubuntu$|^Debian$ ]] && update-rc.d mysqld defaults
cd ..

# my.cnf
[ -d "/etc/mysql" ] && /bin/mv /etc/mysql{,_bk}
cat > /etc/my.cnf << EOF
[client]
port = 3306
socket = /tmp/mysql.sock
default-character-set = utf8mb4

[mysql]
prompt="Percona [\\d]> "
no-auto-rehash

[mysqld]
port = 3306
socket = /tmp/mysql.sock

basedir = $percona_install_dir
datadir = $percona_data_dir
pid-file = $percona_data_dir/mysql.pid
user = mysql
bind-address = 0.0.0.0
server-id = 1

init-connect = 'SET NAMES utf8mb4'
character-set-server = utf8mb4

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
expire_logs_days = 7 

log_error = $percona_data_dir/mysql-error.log
slow_query_log = 1
long_query_time = 1
slow_query_log_file = $percona_data_dir/mysql-slow.log

performance_schema = 0
explicit_defaults_for_timestamp

#lower_case_table_names = 1

skip-external-locking

default_storage_engine = InnoDB
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

sed -i "s@max_connections.*@max_connections = $(($Mem/2))@" /etc/my.cnf 
if [ $Mem -gt 1500 -a $Mem -le 2500 ];then
    sed -i 's@^thread_cache_size.*@thread_cache_size = 16@' /etc/my.cnf
    sed -i 's@^query_cache_size.*@query_cache_size = 16M@' /etc/my.cnf
    sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 16M@' /etc/my.cnf
    sed -i 's@^key_buffer_size.*@key_buffer_size = 16M@' /etc/my.cnf
    sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 128M@' /etc/my.cnf
    sed -i 's@^tmp_table_size.*@tmp_table_size = 32M@' /etc/my.cnf
    sed -i 's@^table_open_cache.*@table_open_cache = 256@' /etc/my.cnf
elif [ $Mem -gt 2500 -a $Mem -le 3500 ];then
    sed -i 's@^thread_cache_size.*@thread_cache_size = 32@' /etc/my.cnf
    sed -i 's@^query_cache_size.*@query_cache_size = 32M@' /etc/my.cnf
    sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 32M@' /etc/my.cnf
    sed -i 's@^key_buffer_size.*@key_buffer_size = 64M@' /etc/my.cnf
    sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 512M@' /etc/my.cnf
    sed -i 's@^tmp_table_size.*@tmp_table_size = 64M@' /etc/my.cnf
    sed -i 's@^table_open_cache.*@table_open_cache = 512@' /etc/my.cnf
elif [ $Mem -gt 3500 ];then
    sed -i 's@^thread_cache_size.*@thread_cache_size = 64@' /etc/my.cnf
    sed -i 's@^query_cache_size.*@query_cache_size = 64M@' /etc/my.cnf
    sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 64M@' /etc/my.cnf
    sed -i 's@^key_buffer_size.*@key_buffer_size = 256M@' /etc/my.cnf
    sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 1024M@' /etc/my.cnf
    sed -i 's@^tmp_table_size.*@tmp_table_size = 128M@' /etc/my.cnf
    sed -i 's@^table_open_cache.*@table_open_cache = 1024@' /etc/my.cnf
fi

$percona_install_dir/bin/mysqld --initialize-insecure --user=mysql --basedir=$percona_install_dir --datadir=$percona_data_dir

chown mysql.mysql -R $percona_data_dir
[ -d '/etc/mysql' ] && mv /etc/mysql{,_bk}
service mysqld start
[ -z "`grep ^'export PATH=' /etc/profile`" ] && echo "export PATH=$percona_install_dir/bin:\$PATH" >> /etc/profile 
[ -n "`grep ^'export PATH=' /etc/profile`" -a -z "`grep $percona_install_dir /etc/profile`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=$percona_install_dir/bin:\1@" /etc/profile

. /etc/profile

$percona_install_dir/bin/mysql -e "grant all privileges on *.* to root@'127.0.0.1' identified by \"$dbrootpwd\" with grant option;"
$percona_install_dir/bin/mysql -e "grant all privileges on *.* to root@'localhost' identified by \"$dbrootpwd\" with grant option;"
$percona_install_dir/bin/mysql -uroot -p$dbrootpwd -e "reset master;"
rm -rf /etc/ld.so.conf.d/{mysql,mariadb,percona}*.conf
[ -e "$percona_install_dir/my.cnf" ] && rm -rf $percona_install_dir/my.cnf
echo "$percona_install_dir/lib" > /etc/ld.so.conf.d/mysql.conf
ldconfig
service mysqld stop
}
