#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com

Install_MySQL84() {
  pushd ${current_dir}/src > /dev/null
  id -u mysql >/dev/null 2>&1
  [ $? -ne 0 ] && useradd -M -s /sbin/nologin mysql

  [ ! -d "${mysql_install_dir}" ] && mkdir -p ${mysql_install_dir}
  mkdir -p ${mysql_data_dir};chown mysql:mysql -R ${mysql_data_dir}

  if [ "${dbinstallmethod}" == "1" ]; then
    tar xJf mysql-${mysql84_ver}-linux-glibc2.28-x86_64.tar.xz
    mv mysql-${mysql84_ver}-linux-glibc2.28-x86_64/* ${mysql_install_dir}
    sed -i "s@/usr/local/mysql@${mysql_install_dir}@g" ${mysql_install_dir}/bin/mysqld_safe
  elif [ "${dbinstallmethod}" == "2" ]; then
    boostVersion2=$(echo ${boost_ver} | awk -F. '{print $1"_"$2"_"$3}')
    tar xzf boost_${boostVersion2}.tar.gz
    tar xzf mysql-${mysql84_ver}.tar.gz
    pushd mysql-${mysql84_ver}
    [ -e "/usr/bin/cmake3" ] && CMAKE=cmake3 || CMAKE=cmake
    $CMAKE . -DCMAKE_INSTALL_PREFIX=${mysql_install_dir} \
    -DMYSQL_DATADIR=${mysql_data_dir} \
    -DDOWNLOAD_BOOST=1 \
    -DWITH_BOOST=../boost_${boostVersion2} \
    -DFORCE_INSOURCE_BUILD=1 \
    -DSYSCONFDIR=/etc \
    -DWITH_INNOBASE_STORAGE_ENGINE=1 \
    -DWITH_FEDERATED_STORAGE_ENGINE=1 \
    -DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
    -DWITH_MYISAM_STORAGE_ENGINE=1 \
    -DENABLED_LOCAL_INFILE=1 \
    -DFORCE_INSOURCE_BUILD=1 \
    -DCMAKE_C_COMPILER=/usr/bin/gcc \
    -DCMAKE_CXX_COMPILER=/usr/bin/g++ \
    -DDEFAULT_CHARSET=utf8mb4
    make -j ${THREAD}
    make install
    popd
  fi

  # backup openssl so
  #[ ! -e "${mysql_install_dir}/lib/lib_bk" ] && mkdir ${mysql_install_dir}/lib/lib_bk
  #/bin/mv ${mysql_install_dir}/lib/{libssl,libcrypto}.so* ${mysql_install_dir}/lib/lib_bk/

  if [ -d "${mysql_install_dir}/support-files" ]; then
    sed -i 's@executing mysqld_safe@executing mysqld_safe\nexport LD_PRELOAD=/usr/local/lib/libjemalloc.so@' ${mysql_install_dir}/bin/mysqld_safe
    sed -i "s+^dbrootpwd.*+dbrootpwd='${dbrootpwd}'+" ../options.conf
    echo "${CSUCCESS}MySQL installed successfully! ${CEND}"
    if [ "${dbinstallmethod}" == "1" ]; then
      rm -rf mysql-${mysql84_ver}-*-x86_64
    elif [ "${dbinstallmethod}" == "2" ]; then
      rm -rf mysql-${mysql84_ver} boost_${boostVersion2}
    fi
  else
    rm -rf ${mysql_install_dir}
    echo "${CFAILURE}MySQL install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
    kill -9 $$; exit 1;
  fi

  /bin/cp ${mysql_install_dir}/support-files/mysql.server /etc/init.d/mysqld
  sed -i "s@^basedir=.*@basedir=${mysql_install_dir}@" /etc/init.d/mysqld
  sed -i "s@^datadir=.*@datadir=${mysql_data_dir}@" /etc/init.d/mysqld
  chmod +x /etc/init.d/mysqld
  [ "${PM}" == 'yum' ] && { chkconfig --add mysqld; chkconfig mysqld on; }
  [ "${PM}" == 'apt-get' ] && update-rc.d mysqld defaults
  popd

  # my.cnf
  cat > /etc/my.cnf << EOF
[client]
port = 3306
socket = /tmp/mysql.sock
default-character-set = utf8mb4

[mysql]
prompt="MySQL [\\d]> "
no-auto-rehash

[mysqld]
port = 3306
socket = /tmp/mysql.sock
mysql_native_password = on 

basedir = ${mysql_install_dir}
datadir = ${mysql_data_dir}
pid-file = ${mysql_data_dir}/mysql.pid
user = mysql
bind-address = 0.0.0.0
server-id = 1

init-connect = 'SET NAMES utf8mb4'
character-set-server = utf8mb4
collation-server = utf8mb4_0900_ai_ci

skip-name-resolve
#skip-networking
back_log = 300

max_connections = 1000
max_connect_errors = 6000
open_files_limit = 65535
table_open_cache = 128
max_allowed_packet = 500M
binlog_cache_size = 1M
max_heap_table_size = 8M
tmp_table_size = 16M

read_buffer_size = 2M
read_rnd_buffer_size = 8M
sort_buffer_size = 8M
join_buffer_size = 8M
key_buffer_size = 4M

thread_cache_size = 8

ft_min_word_len = 4

log_bin = mysql-bin
binlog_expire_logs_seconds = 604800

log_error = ${mysql_data_dir}/mysql-error.log
slow_query_log = 1
long_query_time = 1
slow_query_log_file = ${mysql_data_dir}/mysql-slow.log

performance_schema = 0
explicit_defaults_for_timestamp

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
#innodb_redo_log_capacity = 2G
innodb_max_dirty_pages_pct = 90
innodb_lock_wait_timeout = 120

bulk_insert_buffer_size = 8M
myisam_sort_buffer_size = 8M
myisam_max_sort_file_size = 10G

interactive_timeout = 28800
wait_timeout = 28800

[mysqldump]
quick
max_allowed_packet = 500M

[myisamchk]
key_buffer_size = 8M
sort_buffer_size = 8M
read_buffer = 4M
write_buffer = 4M
EOF

  sed -i "s@max_connections.*@max_connections = $((${Mem}/3))@" /etc/my.cnf
  if [ ${Mem} -gt 1500 -a ${Mem} -le 2500 ]; then
    sed -i 's@^thread_cache_size.*@thread_cache_size = 16@' /etc/my.cnf
    sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 16M@' /etc/my.cnf
    sed -i 's@^key_buffer_size.*@key_buffer_size = 16M@' /etc/my.cnf
    sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 128M@' /etc/my.cnf
    sed -i 's@^tmp_table_size.*@tmp_table_size = 32M@' /etc/my.cnf
    sed -i 's@^table_open_cache.*@table_open_cache = 256@' /etc/my.cnf
  elif [ ${Mem} -gt 2500 -a ${Mem} -le 3500 ]; then
    sed -i 's@^thread_cache_size.*@thread_cache_size = 32@' /etc/my.cnf
    sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 32M@' /etc/my.cnf
    sed -i 's@^key_buffer_size.*@key_buffer_size = 64M@' /etc/my.cnf
    sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 512M@' /etc/my.cnf
    sed -i 's@^tmp_table_size.*@tmp_table_size = 64M@' /etc/my.cnf
    sed -i 's@^table_open_cache.*@table_open_cache = 512@' /etc/my.cnf
  elif [ ${Mem} -gt 3500 ]; then
    sed -i 's@^thread_cache_size.*@thread_cache_size = 64@' /etc/my.cnf
    sed -i 's@^myisam_sort_buffer_size.*@myisam_sort_buffer_size = 64M@' /etc/my.cnf
    sed -i 's@^key_buffer_size.*@key_buffer_size = 256M@' /etc/my.cnf
    sed -i 's@^innodb_buffer_pool_size.*@innodb_buffer_pool_size = 1024M@' /etc/my.cnf
    sed -i 's@^tmp_table_size.*@tmp_table_size = 128M@' /etc/my.cnf
    sed -i 's@^table_open_cache.*@table_open_cache = 1024@' /etc/my.cnf
  fi

  ${mysql_install_dir}/bin/mysqld --initialize-insecure --user=mysql --basedir=${mysql_install_dir} --datadir=${mysql_data_dir}

  [ "${Wsl}" == true ] && chmod 600 /etc/my.cnf
  chown mysql:mysql -R ${mysql_data_dir}
  [ -d "/etc/mysql" ] && /bin/mv /etc/mysql{,_bk}
  service mysqld start
  [ -z "$(grep ^'export PATH=' /etc/profile)" ] && echo "export PATH=${mysql_install_dir}/bin:\$PATH" >> /etc/profile
  [ -n "$(grep ^'export PATH=' /etc/profile)" -a -z "$(grep ${mysql_install_dir} /etc/profile)" ] && sed -i "s@^export PATH=\(.*\)@export PATH=${mysql_install_dir}/bin:\1@" /etc/profile
  . /etc/profile

  ${mysql_install_dir}/bin/mysql -uroot -hlocalhost -e "create user root@'127.0.0.1' identified by \"${dbrootpwd}\";"
  ${mysql_install_dir}/bin/mysql -uroot -hlocalhost -e "grant all privileges on *.* to root@'127.0.0.1' with grant option;"
  ${mysql_install_dir}/bin/mysql -uroot -hlocalhost -e "grant all privileges on *.* to root@'localhost' with grant option;"
  ${mysql_install_dir}/bin/mysql -uroot -hlocalhost -e "alter user root@'localhost' identified by \"${dbrootpwd}\";"
  rm -rf /etc/ld.so.conf.d/{mysql,mariadb,percona}*.conf
  [ -e "${mysql_install_dir}/my.cnf" ] && rm -f ${mysql_install_dir}/my.cnf
  echo "${mysql_install_dir}/lib" > /etc/ld.so.conf.d/z-mysql.conf
  ldconfig
  service mysqld stop
}
