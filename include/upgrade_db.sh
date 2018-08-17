#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 7+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Upgrade_DB() {
  pushd ${oneinstack_dir}/src > /dev/null
  [ ! -e "${db_install_dir}/bin/mysql" ] && echo "${CWARNING}MySQL/MariaDB/Percona is not installed on your system! ${CEND}" && exit 1
  OLD_db_ver_tmp=`${db_install_dir}/bin/mysql -V | awk '{print $5}' | awk -F, '{print $1}'`
  [ -n "`echo ${OLD_db_ver_tmp} | grep glibc`" ] && OLD_db_ver_tmp=`${db_install_dir}/bin/mysql -V | awk '{print $3}' | awk -F, '{print $1}'`
  DB_tmp=`echo ${OLD_db_ver_tmp} | awk -F'-' '{print $2}'`
  if [ "${DB_tmp}" == 'MariaDB' ]; then
    [ "${IPADDR_COUNTRY}"x == "CN"x ] && DOWN_ADDR=https://mirrors.tuna.tsinghua.edu.cn/mariadb || DOWN_ADDR=https://downloads.mariadb.org/f
    DB=MariaDB
    OLD_db_ver=`echo ${OLD_db_ver_tmp} | awk -F'-' '{print $1}'`
  elif [ -n "${DB_tmp}" -a "${DB_tmp}" != 'MariaDB' ]; then
    DB=Percona
    OLD_db_ver=${OLD_db_ver_tmp}
  else
    [ "${IPADDR_COUNTRY}"x == "CN"x ] && DOWN_ADDR=http://mirrors.ustc.edu.cn/mysql-ftp/Downloads || DOWN_ADDR=http://cdn.mysql.com/Downloads
    DB=MySQL
    OLD_db_ver=${OLD_db_ver_tmp}
  fi

  #backup
  while :; do
    ${db_install_dir}/bin/mysql -uroot -p${dbrootpwd} -e "quit" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      break
    else
      echo
      read -p "Please input the root password of database: " NEW_dbrootpwd
      ${db_install_dir}/bin/mysql -uroot -p${NEW_dbrootpwd} -e "quit" >/dev/null 2>&1
      if [ $? -eq 0 ]; then
        dbrootpwd=${NEW_dbrootpwd}
        sed -i "s+^dbrootpwd.*+dbrootpwd='$dbrootpwd'+" ../options.conf
        break
      else
        echo "${CFAILURE}${DB} root password incorrect,Please enter again! ${CEND}"
      fi
    fi
  done

  echo
  echo "${CSUCCESS}Starting ${DB} backup${CEND}......"
  ${db_install_dir}/bin/mysqldump -uroot -p${dbrootpwd} --opt --all-databases > DB_all_backup_$(date +"%Y%m%d").sql
  [ -f "DB_all_backup_$(date +"%Y%m%d").sql" ] && echo "${DB} backup success, Backup file: ${MSG}`pwd`/DB_all_backup_$(date +"%Y%m%d").sql${CEND}"

  #upgrade
  echo
  echo "Current ${DB} Version: ${CMSG}${OLD_db_ver}${CEND}"
  while :; do echo
    read -p "Please input upgrade ${DB} Version(example: ${OLD_db_ver}): " NEW_db_ver
    if [ `echo ${NEW_db_ver} | awk -F. '{print $1"."$2}'` == `echo ${OLD_db_ver} | awk -F. '{print $1"."$2}'` ]; then
      if [ "${DB}" == 'MariaDB' ]; then
        DB_name=mariadb-${NEW_db_ver}-${GLIBC_FLAG}-${SYS_BIT_b}
        DB_URL=${DOWN_ADDR}/mariadb-${NEW_db_ver}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}/${DB_name}.tar.gz
      elif [ "${DB}" == 'Percona' ]; then
        DB_name=percona-server-${NEW_db_ver}
        DB_URL=http://www.percona.com/redir/downloads/Percona-Server-`echo ${NEW_db_ver} | awk -F. '{print $1"."$2}'`/LATEST/source/tarball/${DB_name}.tar.gz
      elif [ "${DB}" == 'MySQL' ]; then
        DB_name=mysql-${NEW_db_ver}-linux-glibc2.12-${SYS_BIT_b}
        if [ `echo ${OLD_db_ver} | awk -F. '{print $1"."$2}'` == '8.0' ]; then
          DB_URL=${DOWN_ADDR}/MySQL-`echo ${NEW_db_ver} | awk -F. '{print $1"."$2}'`/${DB_name}.tar.xz
        else
          DB_URL=${DOWN_ADDR}/MySQL-`echo ${NEW_db_ver} | awk -F. '{print $1"."$2}'`/${DB_name}.tar.gz
        fi
      fi
      [ ! -e "`ls ${DB_name}.tar.?z 2>/dev/null`" ] && wget --no-check-certificate -c ${DB_URL} > /dev/null 2>&1
      if [ -e "`ls ${DB_name}.tar.?z 2>/dev/null`" ]; then
        echo "Download [${CMSG}`ls ${DB_name}.tar.?z 2>/dev/null`${CEND}] successfully! "
      else
        echo "${CWARNING}${DB} version does not exist! ${CEND}"
      fi
      break
    else
      echo "${CWARNING}input error! ${CEND}Please only input '${CMSG}${OLD_db_ver%.*}.xx${CEND}'"
    fi
  done

  if [ -e "`ls ${DB_name}.tar.?z 2>/dev/null`" ]; then
    echo "[${CMSG}`ls ${DB_name}.tar.?z 2>/dev/null`${CEND}] found"
    echo "Press Ctrl+c to cancel or Press any key to continue..."
    char=`get_char`
    if [ "${DB}" == 'MariaDB' ]; then
      service mysqld stop
      mv ${mariadb_install_dir}{,_old_`date +"%Y%m%d_%H%M%S"`}
      mv ${mariadb_data_dir}{,_old_`date +"%Y%m%d_%H%M%S"`}
      mkdir -p ${mariadb_data_dir};chown mysql.mysql -R ${mariadb_data_dir}
      tar xzf ${DB_name}.tar.gz
      [ ! -d "${mariadb_install_dir}" ] && mkdir -p ${mariadb_install_dir}
      mv mariadb-${NEW_db_ver}-*-${SYS_BIT_b}/* ${mariadb_install_dir}
      sed -i 's@executing mysqld_safe@executing mysqld_safe\nexport LD_PRELOAD=/usr/local/lib/libjemalloc.so@' ${mariadb_install_dir}/bin/mysqld_safe
      ${mariadb_install_dir}/scripts/mysql_install_db --user=mysql --basedir=${mariadb_install_dir} --datadir=${mariadb_data_dir}
      chown mysql.mysql -R ${mariadb_data_dir}
      service mysqld start
      ${mariadb_install_dir}/bin/mysql < DB_all_backup_$(date +"%Y%m%d").sql
      service mysqld restart
      ${mariadb_install_dir}/bin/mysql -uroot -p${dbrootpwd} -e "drop database test;" >/dev/null 2>&1
      ${mariadb_install_dir}/bin/mysql -uroot -p${dbrootpwd} -e "reset master;" >/dev/null 2>&1
      [ $? -eq 0 ] &&  echo "You have ${CMSG}successfully${CEND} upgrade from ${CMSG}${OLD_db_ver}${CEND} to ${CMSG}${NEW_db_ver}${CEND}"
    elif [ "${DB}" == 'Percona' ]; then
      tar xzf ${DB_name}.tar.gz
      pushd ${DB_name}
      make clean
      if [ "`echo ${NEW_db_ver} | awk -F. '{print $1"."$2}'`" == '5.5' ]; then
        cmake . -DCMAKE_INSTALL_PREFIX=${percona_install_dir} \
        -DMYSQL_DATADIR=${percona_data_dir} \
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
        -DCMAKE_EXE_LINKER_FLAGS='-ljemalloc'
      else
        cmake . -DCMAKE_INSTALL_PREFIX=${percona_install_dir} \
        -DMYSQL_DATADIR=${percona_data_dir} \
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
        -DCMAKE_EXE_LINKER_FLAGS='-ljemalloc'
      fi
      make -j ${THREAD}
      service mysqld stop
      mv ${percona_install_dir}{,_old_`date +"%Y%m%d_%H%M%S"`}
      mv ${percona_data_dir}{,_old_`date +"%Y%m%d_%H%M%S"`}
      [ ! -d "${percona_install_dir}" ] && mkdir -p ${percona_install_dir}
      mkdir -p ${percona_data_dir};chown mysql.mysql -R ${percona_data_dir}
      make install
      popd
      if [ "`echo ${NEW_db_ver} | awk -F. '{print $1"."$2}'`" == '5.7' ]; then
        ${percona_install_dir}/bin/mysqld --initialize-insecure --user=mysql --basedir=${percona_install_dir} --datadir=${percona_data_dir}
      else
        ${percona_install_dir}/scripts/mysql_install_db --user=mysql --basedir=${percona_install_dir} --datadir=${percona_data_dir}
      fi
      chown mysql.mysql -R ${percona_data_dir}
      service mysqld start
      ${percona_install_dir}/bin/mysql < DB_all_backup_$(date +"%Y%m%d").sql
      service mysqld restart
      ${percona_install_dir}/bin/mysql -uroot -p${dbrootpwd} -e "drop database test;" >/dev/null 2>&1
      ${percona_install_dir}/bin/mysql -uroot -p${dbrootpwd} -e "reset master;" >/dev/null 2>&1
      [ $? -eq 0 ] &&  echo "You have ${CMSG}successfully${CEND} upgrade from ${CMSG}${OLD_db_ver}${CEND} to ${CMSG}${NEW_db_ver}${CEND}"
    elif [ "${DB}" == 'MySQL' ]; then
      if [ `echo ${OLD_db_ver} | awk -F. '{print $1"."$2}'` == '8.0' ]; then
        tar xJf ${DB_name}.tar.xz
      else
        tar xzf ${DB_name}.tar.gz
      fi
      service mysqld stop
      mv ${mysql_install_dir}{,_old_`date +"%Y%m%d_%H%M%S"`}
      mv ${mysql_data_dir}{,_old_`date +"%Y%m%d_%H%M%S"`}
      [ ! -d "${mysql_install_dir}" ] && mkdir -p ${mysql_install_dir}
      mkdir -p ${mysql_data_dir};chown mysql.mysql -R ${mysql_data_dir}
      mv ${DB_name}/* ${mysql_install_dir}/
      sed -i 's@executing mysqld_safe@executing mysqld_safe\nexport LD_PRELOAD=/usr/local/lib/libjemalloc.so@' ${mysql_install_dir}/bin/mysqld_safe
      sed -i "s@/usr/local/mysql@${mysql_install_dir}@g" ${mysql_install_dir}/bin/mysqld_safe
      if [[ "`echo ${NEW_db_ver} | awk -F. '{print $1"."$2}'`" =~ ^5.[5-6]$ ]]; then
        ${mysql_install_dir}/scripts/mysql_install_db --user=mysql --basedir=${mysql_install_dir} --datadir=${mysql_data_dir}
      else
        ${mysql_install_dir}/bin/mysqld --initialize-insecure --user=mysql --basedir=${mysql_install_dir} --datadir=${mysql_data_dir}
      fi

      chown mysql.mysql -R ${mysql_data_dir}
      [ -e "${mysql_install_dir}/my.cnf" ] && rm -rf ${mysql_install_dir}/my.cnf
      service mysqld start
      ${mysql_install_dir}/bin/mysql < DB_all_backup_$(date +"%Y%m%d").sql
      service mysqld restart
      ${mysql_install_dir}/bin/mysql -uroot -p${dbrootpwd} -e "drop database test;" >/dev/null 2>&1
      ${mysql_install_dir}/bin/mysql -uroot -p${dbrootpwd} -e "reset master;" >/dev/null 2>&1
      [ $? -eq 0 ] &&  echo "You have ${CMSG}successfully${CEND} upgrade from ${CMSG}${OLD_db_ver}${CEND} to ${CMSG}${NEW_db_ver}${CEND}"
    fi
  fi
}
