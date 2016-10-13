#!/bin/bash
# Author:  Alpha Eva <kaneawk AT gmail.com>
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

checkDownload() {
  pushd ${oneinstack_dir}/src
  mirrorLink=http://mirrors.linuxeye.com/oneinstack/src
  
  # Web
  if [ "${Web_yn}" == 'y' ]; then
    echo "Download openSSL..."
    src_url=https://www.openssl.org/source/openssl-${openssl_version}.tar.gz && Download_src
    if [ "${Nginx_version}" == "1" ]; then
      echo "Download nginx..."
      src_url=http://nginx.org/download/nginx-${nginx_version}.tar.gz && Download_src
    fi
    if [ "${Nginx_version}" == "2" ]; then
      echo "Download tengine..."
      src_url=http://tengine.taobao.org/download/tengine-${tengine_version}.tar.gz && Download_src
    fi
    if [ "${Nginx_version}" == "3" ]; then
      echo "Download openresty..."
      src_url=https://openresty.org/download/openresty-${openresty_version}.tar.gz && Download_src
    fi
    
    if [[ "${Nginx_version}" =~ ^[1-3]$ || ${Apache_version} == "1" ]]; then
      echo "Download pcre..."
      src_url=${mirrorLink}/pcre-${pcre_version}.tar.gz && Download_src
    fi
    
    # apache
    if [ "${Apache_version}" == "1" ]; then
      echo "Download apache 2.4..."
      src_url=http://archive.apache.org/dist/apr/apr-${apr_version}.tar.gz && Download_src
      src_url=http://archive.apache.org/dist/apr/apr-util-${apr_util_version}.tar.gz && Download_src
      src_url=http://mirrors.linuxeye.com/apache/httpd/httpd-${apache_4_version}.tar.gz && Download_src
    fi
    if [ "${Apache_version}" == "2" ]; then
      echo "Download apache 2.2..."
      src_url=http://mirrors.linuxeye.com/apache/httpd/httpd-${apache_2_version}.tar.gz && Download_src
      
      echo "Download mod_remoteip.c for apache 2.2..."
      src_url=${mirrorLink}/mod_remoteip.c && Download_src
    fi
    
    # tomcat
    if [ "${Tomcat_version}" == "1" ]; then
      echo "Download tomcat 8..."
      src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat_8_version}/apache-tomcat-${tomcat_8_version}.tar.gz && Download_src
      src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat_8_version}/catalina-jmx-remote.jar && Download_src
    fi
    if [ "${Tomcat_version}" == "2" ]; then
      echo "Download tomcat 7..."
      src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat_7_version}/apache-tomcat-${tomcat_7_version}.tar.gz && Download_src
      src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat_7_version}/catalina-jmx-remote.jar && Download_src
    fi
    if [ "${Tomcat_version}" == "3" ]; then
      echo "Download tomcat 6..."
      src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat_6_version}/apache-tomcat-${tomcat_6_version}.tar.gz && Download_src
      src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat_6_version}/catalina-jmx-remote.jar && Download_src
    fi
    
    if [[ "${JDK_version}"  =~ ^[1-3]$ ]]; then
      if [ "${JDK_version}" == "1" ]; then
        echo "Download jdk 1.8..."
        JDK_FILE="jdk-$(echo ${jdk_8_version} | awk -F. '{print $2}')u$(echo ${jdk_8_version} | awk -F_ '{print $NF}')-linux-${SYS_BIG_FLAG}.tar.gz"
      fi
      if [ "${JDK_version}" == "2" ]; then
        echo "Download jdk 1.7..."
        JDK_FILE="jdk-$(echo ${jdk_7_version} | awk -F. '{print $2}')u$(echo ${jdk_7_version} | awk -F_ '{print $NF}')-linux-${SYS_BIG_FLAG}.tar.gz"
      fi
      if [ "${JDK_version}" == "3" ]; then
        echo "Download jdk 1.6..."
        JDK_FILE="jdk-$(echo ${jdk_6_version} | awk -F. '{print $2}')u$(echo ${jdk_6_version} | awk -F_ '{print $NF}')-linux-${SYS_BIG_FLAG}.bin"
      fi
      src_url=http://mirrors.linuxeye.com/jdk/${JDK_FILE} && Download_src
    fi
  fi
  
  if [ "${DB_yn}" == "y" ]; then
    if [[ "${DB_version}" =~ ^[1,4,7]$ ]] && [ "${dbInstallMethods}" == "2" ]; then
      echo "Download boost..."
      [ "${IPADDR_COUNTRY}"x == "CN"x ] && DOWN_ADDR_BOOST=${mirrorLink} || DOWN_ADDR_BOOST=http://downloads.sourceforge.net/project/boost/boost/${boost_version}
      boostVersion2=$(echo ${boost_version} | awk -F. '{print $1}')_$(echo ${boost_version} | awk -F. '{print $2}')_$(echo ${boost_version} | awk -F. '{print $3}')
      src_url=${DOWN_ADDR_BOOST}/boost_${boostVersion2}.tar.gz && Download_src
    fi
  
    if [ "${DB_version}" == "1" ]; then
      # mysql 5.7
      if [ "${IPADDR_COUNTRY}"x == "CN"x -a "${IPADDR_ISP}" == 'aliyun' -a "`../include/check_port.py aliyun-oss.linuxeye.com 80`" == 'True' ]; then
        DOWN_ADDR_MYSQL=http://aliyun-oss.linuxeye.com/mysql/MySQL-5.7
      else
        if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
          if [ "$(../include/check_port.py mirrors.tuna.tsinghua.edu.cn 443)" == 'True' ]; then
            DOWN_ADDR_MYSQL=https://mirrors.tuna.tsinghua.edu.cn/mysql/downloads/MySQL-5.7
          else
            DOWN_ADDR_MYSQL=http://mirrors.sohu.com/mysql/MySQL-5.6
            DOWN_ADDR_MYSQL_BK=${DOWN_ADDR_MYSQL}
          fi
        else
          if [ "$(../include/check_port.py cdn.mysql.com 80)" == 'True' ]; then
            DOWN_ADDR_MYSQL=http://cdn.mysql.com/Downloads/MySQL-5.7
          else
            DOWN_ADDR_MYSQL=http://mysql.he.net/Downloads/MySQL-5.7
            DOWN_ADDR_MYSQL_BK=${DOWN_ADDR_MYSQL}
          fi
        fi
      fi
      if [ "${dbInstallMethods}" == "1" ]; then
        echo "Download MySQL 5.7 binary package..."
        FILE_NAME=mysql-${mysql_5_7_version}-linux-glibc2.5-${SYS_BIT_b}.tar.gz
      elif [ "${dbInstallMethods}" == "2" ]; then
        echo "Download MySQL 5.7 source package..."
        FILE_NAME=mysql-${mysql_5_7_version}.tar.gz
      fi
      wget --tries=6 -c --no-check-certificate ${DOWN_ADDR_MYSQL}/${FILE_NAME}
      wget --tries=6 -c --no-check-certificate ${DOWN_ADDR_MYSQL}/${FILE_NAME}.md5
      MYSQL_TAR_MD5=$(awk '{print $1}' ${FILE_NAME}.md5)
      while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${MYSQL_TAR_MD5}" ];do
        wget -4c --no-check-certificate ${DOWN_ADDR_MYSQL_BK}/${FILE_NAME};sleep 1
        [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${MYSQL_TAR_MD5}" ] && break || continue
      done
    fi
  
    if [ "${DB_version}" == "2" ]; then
      # mysql 5.6
      if [ "${IPADDR_COUNTRY}"x == "CN"x -a "${IPADDR_ISP}" == 'aliyun' -a "$(../include/check_port.py aliyun-oss.linuxeye.com 80)" == 'True' ]; then
        DOWN_ADDR_MYSQL=http://aliyun-oss.linuxeye.com/mysql/MySQL-5.6
      else
        if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
          if [ "$(../include/check_port.py mirrors.tuna.tsinghua.edu.cn 443)" == 'True' ]; then
            DOWN_ADDR_MYSQL=https://mirrors.tuna.tsinghua.edu.cn/mysql/downloads/MySQL-5.6
          else
            DOWN_ADDR_MYSQL=http://mirrors.sohu.com/mysql/MySQL-5.6
            DOWN_ADDR_MYSQL_BK=${DOWN_ADDR_MYSQL}
          fi
        else
          if [ "$(../include/check_port.py cdn.mysql.com 80)" == 'True' ]; then
            DOWN_ADDR_MYSQL=http://cdn.mysql.com/Downloads/MySQL-5.6
          else
            DOWN_ADDR_MYSQL=http://mysql.he.net/Downloads/MySQL-5.6
            DOWN_ADDR_MYSQL_BK=${DOWN_ADDR_MYSQL}
          fi
        fi
      fi
      if [ "${dbInstallMethods}" == "1" ]; then
        echo "Download  MySQL 5.6 binary package..."
        FILE_NAME=mysql-${mysql_5_6_version}-linux-glibc2.5-${SYS_BIT_b}.tar.gz
      elif [ "${dbInstallMethods}" == "2" ]; then
        echo "Download MySQL 5.5 source package..."
        FILE_NAME=mysql-${mysql_5_6_version}.tar.gz
      fi
      wget --tries=6 -c --no-check-certificate ${DOWN_ADDR_MYSQL}/${FILE_NAME}
      wget --tries=6 -c --no-check-certificate ${DOWN_ADDR_MYSQL}/${FILE_NAME}.md5
      MYSQL_TAR_MD5=$(awk '{print $1}' ${FILE_NAME}.md5)
      while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${MYSQL_TAR_MD5}" ];do
        wget -4c --no-check-certificate ${DOWN_ADDR_MYSQL_BK}/${FILE_NAME};sleep 1
        [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${MYSQL_TAR_MD5}" ] && break || continue
      done
    fi
  
    if [ "${DB_version}" == "3" ]; then
      # mysql 5.5
      if [ "${IPADDR_COUNTRY}"x == "CN"x -a "${IPADDR_ISP}" == 'aliyun' -a "$(../include/check_port.py aliyun-oss.linuxeye.com 80)" == 'True' ]; then
        DOWN_ADDR_MYSQL=http://aliyun-oss.linuxeye.com/mysql/MySQL-5.5
      else
        if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
          if [ "$(../include/check_port.py mirrors.tuna.tsinghua.edu.cn 443)" == 'True' ]; then
            DOWN_ADDR_MYSQL=https://mirrors.tuna.tsinghua.edu.cn/mysql/downloads/MySQL-5.5
          else
            DOWN_ADDR_MYSQL=http://mirrors.sohu.com/mysql/MySQL-5.5
            DOWN_ADDR_MYSQL_BK=${DOWN_ADDR_MYSQL}
          fi
        else
          if [ "$(../include/check_port.py cdn.mysql.com 80)" == 'True' ]; then
            DOWN_ADDR_MYSQL=http://cdn.mysql.com/Downloads/MySQL-5.5
          else
            DOWN_ADDR_MYSQL=http://mysql.he.net/Downloads/MySQL-5.5
            DOWN_ADDR_MYSQL_BK=${DOWN_ADDR_MYSQL}
          fi
        fi
      fi
      if [ "${dbInstallMethods}" == "1" ]; then
        echo "Download MySQL 5.5 binary package..."
        FILE_NAME=mysql-${mysql_5_5_version}-linux2.6-${SYS_BIT_b}.tar.gz
      elif [ "${dbInstallMethods}" == "2" ]; then
        echo "Download MySQL 5.5 source package..."
        FILE_NAME=mysql-${mysql_5_5_version}.tar.gz
        src_url=${mirrorLink}/mysql-5.5-fix-arm-client_plugin.patch && Download_src
      fi
      wget --tries=6 -c --no-check-certificate ${DOWN_ADDR_MYSQL}/${FILE_NAME}
      wget --tries=6 -c --no-check-certificate ${DOWN_ADDR_MYSQL}/${FILE_NAME}.md5
      MYSQL_TAR_MD5=$(awk '{print $1}' ${FILE_NAME}.md5)
  
      while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${MYSQL_TAR_MD5}" ];do
        wget -c --no-check-certificate ${DOWN_ADDR_MYSQL_BK}/${FILE_NAME};sleep 1
        [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${MYSQL_TAR_MD5}" ] && break || continue
      done
    fi
  
    if [ "${DB_version}" == "4" ]; then
      # mariaDB 10.1
      if [ "${dbInstallMethods}" == "1" ]; then
        echo "Download MariaDB 10.1 binary package..."
        FILE_NAME=mariadb-${mariadb_10_1_version}-${GLIBC_FLAG}-${SYS_BIT_b}.tar.gz
        if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
          DOWN_ADDR_MARIADB=https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-${mariadb_10_1_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
          MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}')
          [ -z "${MARAIDB_TAR_MD5}" ] && { DOWN_ADDR_MARIADB=https://mirrors.ustc.edu.cn/mariadb/mariadb-${mariadb_10_1_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}; MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}'); }
        else
          DOWN_ADDR_MARIADB=https://downloads.mariadb.org/interstitial/mariadb-${mariadb_10_1_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
          MARAIDB_TAR_MD5=$(curl -Lk http://archive.mariadb.org/mariadb-${mariadb_10_1_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}/md5sums.txt |  grep ${FILE_NAME} | awk '{print $1}')
        fi
      elif [ "${dbInstallMethods}" == "2" ]; then
        echo "Download MariaDB 10.1 source package..."
        FILE_NAME=mariadb-${mariadb_10_1_version}.tar.gz
        if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
          DOWN_ADDR_MARIADB=https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-${mariadb_10_1_version}/source
          MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}')
          [ -z "${MARAIDB_TAR_MD5}" ] && { DOWN_ADDR_MARIADB=https://mirrors.ustc.edu.cn/mariadb/mariadb-${mariadb_10_1_version}/source; MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}'); }
        else
          DOWN_ADDR_MARIADB=https://downloads.mariadb.org/interstitial/mariadb-${mariadb_10_1_version}/source
          MARAIDB_TAR_MD5=$(curl -Lk http://archive.mariadb.org/mariadb-${mariadb_10_1_version}/source/md5sums.txt |  grep ${FILE_NAME} | awk '{print $1}')
        fi
      fi
      tryDlCount=0
      while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${MARAIDB_TAR_MD5}" ];do
        wget -c --no-check-certificate ${DOWN_ADDR_MARIADB}/${FILE_NAME};sleep 1
        let "tryDlCount++"
        [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${MARAIDB_TAR_MD5}" -o "${tryDlCount}" == "6" ] && break || continue
      done
      if [ "${tryDlCount}" == "6" ]; then
        echo "${CFAILURE}${FILE_NAME} download failed, Please contact the author! ${CEND}"
        kill -9 $$
      else
        echo "[${CMSG}${FILE_NAME}${CEND}] found."
      fi
    fi
  
    if [ "${DB_version}" == "5" ]; then
      # mariaDB 10.0
      if [ "${dbInstallMethods}" == "1" ]; then
        echo "Download MariaDB 10.0 binary package..."
        FILE_NAME=mariadb-${mariadb_10_0_version}-${GLIBC_FLAG}-${SYS_BIT_b}.tar.gz
        if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
          DOWN_ADDR_MARIADB=https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-${mariadb_10_0_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
          MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}')
          [ -z "${MARAIDB_TAR_MD5}" ] && { DOWN_ADDR_MARIADB=https://mirrors.ustc.edu.cn/mariadb/mariadb-${mariadb_10_0_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}; MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}'); }
        else
          DOWN_ADDR_MARIADB=https://downloads.mariadb.org/interstitial/mariadb-${mariadb_10_0_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
          MARAIDB_TAR_MD5=$(curl -Lk http://archive.mariadb.org/mariadb-${mariadb_10_0_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}/md5sums.txt |  grep ${FILE_NAME} | awk '{print $1}')
        fi
      elif [ "${dbInstallMethods}" == "2" ]; then
        echo "Download MariaDB 10.0 source package..."
        FILE_NAME=mariadb-${mariadb_10_0_version}.tar.gz
        if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
          DOWN_ADDR_MARIADB=https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-${mariadb_10_0_version}/source
          MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}')
          [ -z "${MARAIDB_TAR_MD5}" ] && { DOWN_ADDR_MARIADB=https://mirrors.ustc.edu.cn/mariadb/mariadb-${mariadb_10_0_version}/source; MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}'); }
        else
          DOWN_ADDR_MARIADB=https://downloads.mariadb.org/interstitial/mariadb-${mariadb_10_0_version}/source
          MARAIDB_TAR_MD5=$(curl -Lk http://archive.mariadb.org/mariadb-${mariadb_10_0_version}/source/md5sums.txt |  grep ${FILE_NAME} | awk '{print $1}')
        fi
      fi
      tryDlCount=0
      while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${MARAIDB_TAR_MD5}" ];do
        wget -c --no-check-certificate ${DOWN_ADDR_MARIADB}/${FILE_NAME};sleep 1
        let "tryDlCount++"
        [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${MARAIDB_TAR_MD5}" -o "${tryDlCount}" == "6" ] && break || continue
      done
      if [ "${tryDlCount}" == "6" ]; then
          echo "${CFAILURE}${FILE_NAME} download failed, Please contact the author! ${CEND}"
          kill -9 $$
      else
          echo "[${CMSG}${FILE_NAME}${CEND}] found."
      fi
    fi
    if [ "${DB_version}" == "6" ]; then
      # mariaDB 5.5
      if [ "${dbInstallMethods}" == "1" ]; then
        echo "Download MariaDB 5.5 binary package..."
        FILE_NAME=mariadb-${mariadb_5_5_version}-${GLIBC_FLAG}-${SYS_BIT_b}.tar.gz
        if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
          DOWN_ADDR_MARIADB=https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-${mariadb_5_5_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
          MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}')
          [ -z "${MARAIDB_TAR_MD5}" ] && { DOWN_ADDR_MARIADB=https://mirrors.ustc.edu.cn/mariadb/mariadb-${mariadb_5_5_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}; MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}'); }
        else
          DOWN_ADDR_MARIADB=https://downloads.mariadb.org/interstitial/mariadb-${mariadb_5_5_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
          MARAIDB_TAR_MD5=$(curl -Lk http://archive.mariadb.org/mariadb-${mariadb_5_5_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}/md5sums.txt |  grep ${FILE_NAME} | awk '{print $1}')
        fi
      elif [ "${dbInstallMethods}" == "2" ]; then
        echo "Download MariaDB 5.5 source package..."
        FILE_NAME=mariadb-${mariadb_5_5_version}.tar.gz
        if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
          DOWN_ADDR_MARIADB=https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-${mariadb_5_5_version}/source
          MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}')
          [ -z "${MARAIDB_TAR_MD5}" ] && { DOWN_ADDR_MARIADB=https://mirrors.ustc.edu.cn/mariadb/mariadb-${mariadb_5_5_version}/source; MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}'); }
        else
          DOWN_ADDR_MARIADB=https://downloads.mariadb.org/interstitial/mariadb-${mariadb_5_5_version}/source
          MARAIDB_TAR_MD5=$(curl -Lk http://archive.mariadb.org/mariadb-${mariadb_5_5_version}/source/md5sums.txt |  grep ${FILE_NAME} | awk '{print $1}')
        fi
      fi
      tryDlCount=0
      while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${MARAIDB_TAR_MD5}" ];do
        wget -c --no-check-certificate ${DOWN_ADDR_MARIADB}/${FILE_NAME};sleep 1
        let "tryDlCount++"
        [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${MARAIDB_TAR_MD5}" -o "${tryDlCount}" == "6" ] && break || continue
      done
      if [ "${tryDlCount}" == "6" ]; then
        echo "${CFAILURE}${FILE_NAME} download failed, Please contact the author! ${CEND}"
        kill -9 $$
      else
        echo "[${CMSG}${FILE_NAME}${CEND}] found."
      fi
    fi
  
    if [ "${DB_version}" == "7" ]; then
      # precona 5.7
      if [ "${dbInstallMethods}" == "1" ]; then
        echo "Download Percona 5.7 binary package..."
        FILE_NAME=Percona-Server-${percona_5_7_version}-Linux.${SYS_BIT_b}.${sslLibVer}.tar.gz
        DOWN_ADDR_PERCONA=https://www.percona.com/downloads/Percona-Server-5.7/Percona-Server-${percona_5_7_version}/binary/tarball
        PERCONA_TAR_MD5=$(curl -Lk https://www.percona.com/downloads/Percona-Server-5.7/Percona-Server-${percona_5_7_version}/binary/tarball/${FILE_NAME}.md5sum |  grep ${FILE_NAME} | awk '{print $1}')
      elif [ "${dbInstallMethods}" == "2" ]; then
        echo "Download Percona 5.7 source package..."
        FILE_NAME=percona-server-${percona_5_7_version}.tar.gz
        if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
          DOWN_ADDR_PERCONA=${mirrorLink}
          DOWN_ADDR_PERCONA_2=https://www.percona.com/downloads/Percona-Server-5.7/source/tarball
          PERCONA_TAR_MD5=$(curl -Lk ${DOWN_ADDR_PERCONA_2}/${FILE_NAME}.md5sum | grep ${FILE_NAME} | awk '{print $1}')
          [ -z "${PERCONA_TAR_MD5}" ] && { DOWN_ADDR_PERCONA=${mirrorLink}; PERCONA_TAR_MD5=$(curl -Lk ${DOWN_ADDR_PERCONA_2}/${FILE_NAME}.md5sum | grep ${FILE_NAME} | awk '{print $1}'); }
        else
          DOWN_ADDR_PERCONA=https://www.percona.com/downloads/Percona-Server-5.7/Percona-Server-${percona_5_7_version}/source/tarball
          PERCONA_TAR_MD5=$(curl -Lk ${DOWN_ADDR_PERCONA}/${FILE_NAME}.md5sum |  grep ${FILE_NAME} | awk '{print $1}')
        fi
      fi
      tryDlCount=0
      while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${PERCONA_TAR_MD5}" ];do
        wget -c --no-check-certificate ${DOWN_ADDR_PERCONA}/${FILE_NAME};sleep 1
        let "tryDlCount++"
        [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${PERCONA_TAR_MD5}" -o "${tryDlCount}" == "6" ] && break || continue
      done
      if [ "${tryDlCount}" == "6" ]; then
        echo "${CFAILURE}${FILE_NAME} download failed, Please contact the author! ${CEND}"
        kill -9 $$
      else
        echo "[${CMSG}${FILE_NAME}${CEND}] found."
      fi
    fi
  
    if [ "${DB_version}" == "8" ]; then
      # precona 5.6
      if [ "${dbInstallMethods}" == "1" ]; then
        echo "Download Percona 5.6 binary package..."
        perconaVerStr1=$(echo ${percona_5_6_version} | sed "s@-@-rel@")
        FILE_NAME=Percona-Server-${perconaVerStr1}-Linux.${SYS_BIT_b}.${sslLibVer}.tar.gz
        DOWN_ADDR_PERCONA=https://www.percona.com/downloads/Percona-Server-5.6/Percona-Server-${percona_5_6_version}/binary/tarball
        PERCONA_TAR_MD5=$(curl -Lk https://www.percona.com/downloads/Percona-Server-5.6/Percona-Server-${percona_5_6_version}/binary/tarball/${FILE_NAME}.md5sum |  grep ${FILE_NAME} | awk '{print $1}')
      elif [ "${dbInstallMethods}" == "2" ]; then
        echo "Download Percona 5.6 source package..."
        FILE_NAME=percona-server-${percona_5_6_version}.tar.gz
        if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
          DOWN_ADDR_PERCONA=${mirrorLink}
          DOWN_ADDR_PERCONA_2=https://www.percona.com/downloads/Percona-Server-5.6/Percona-Server-${percona_5_6_version}/source/tarball
          PERCONA_TAR_MD5=$(curl -Lk ${DOWN_ADDR_PERCONA_2}/${FILE_NAME}.md5sum | grep ${FILE_NAME} | awk '{print $1}')
          [ -z "${PERCONA_TAR_MD5}" ] && { DOWN_ADDR_PERCONA=${mirrorLink}; PERCONA_TAR_MD5=$(curl -Lk ${DOWN_ADDR_PERCONA_2}/${FILE_NAME}.md5sum | grep ${FILE_NAME} | awk '{print $1}'); }
        else
          DOWN_ADDR_PERCONA=https://www.percona.com/downloads/Percona-Server-5.6/Percona-Server-${percona_5_6_version}/source/tarball
          PERCONA_TAR_MD5=$(curl -Lk ${DOWN_ADDR_PERCONA}/${FILE_NAME}.md5sum |  grep ${FILE_NAME} | awk '{print $1}')
        fi
      fi
      tryDlCount=0
      while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${PERCONA_TAR_MD5}" ];do
        wget -c --no-check-certificate ${DOWN_ADDR_PERCONA}/${FILE_NAME};sleep 1
        let "tryDlCount++"
        [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${PERCONA_TAR_MD5}" -o "${tryDlCount}" == "6" ] && break || continue
      done
      if [ "${tryDlCount}" == "6" ]; then
        echo "${CFAILURE}${FILE_NAME} download failed, Please contact the author! ${CEND}"
        kill -9 $$
      else
        echo "[${CMSG}${FILE_NAME}${CEND}] found."
      fi
    fi
  
    if [ "${DB_version}" == "9" ]; then
      # precona 5.5
      if [ "${dbInstallMethods}" == "1" ]; then
        echo "Download Percona 5.5 binary package..."
        perconaVerStr1=$(echo ${percona_5_5_version} | sed "s@-@-rel@")
        FILE_NAME=Percona-Server-${perconaVerStr1}-Linux.${SYS_BIT_b}.${sslLibVer}.tar.gz
        DOWN_ADDR_PERCONA=https://www.percona.com/downloads/Percona-Server-5.5/Percona-Server-${percona_5_5_version}/binary/tarball
        PERCONA_TAR_MD5=$(curl -Lk https://www.percona.com/downloads/Percona-Server-5.5/Percona-Server-${percona_5_5_version}/binary/tarball/${FILE_NAME}.md5sum |  grep ${FILE_NAME} | awk '{print $1}')
      elif [ "${dbInstallMethods}" == "2" ]; then
        echo "Download Percona 5.5 source package..."
        FILE_NAME=percona-server-${percona_5_5_version}.tar.gz
        if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
          DOWN_ADDR_PERCONA=${mirrorLink}
          DOWN_ADDR_PERCONA_2=https://www.percona.com/downloads/Percona-Server-5.5/Percona-Server-${percona_5_5_version}/source/tarball
          PERCONA_TAR_MD5=$(curl -Lk ${DOWN_ADDR_PERCONA_2}/${FILE_NAME}.md5sum | grep ${FILE_NAME} | awk '{print $1}')
          [ -z "${PERCONA_TAR_MD5}" ] && { DOWN_ADDR_PERCONA=${mirrorLink}; PERCONA_TAR_MD5=$(curl -Lk ${DOWN_ADDR_PERCONA_2}/${FILE_NAME}.md5sum | grep ${FILE_NAME} | awk '{print $1}'); }
        else
          DOWN_ADDR_PERCONA=https://www.percona.com/downloads/Percona-Server-5.5/Percona-Server-${percona_5_5_version}/source/tarball
          PERCONA_TAR_MD5=$(curl -Lk ${DOWN_ADDR_PERCONA}/${FILE_NAME}.md5sum | grep ${FILE_NAME} | awk '{print $1}')
        fi
      fi
      tryDlCount=0
      while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${PERCONA_TAR_MD5}" ];do
        wget -c --no-check-certificate ${DOWN_ADDR_PERCONA}/${FILE_NAME};sleep 1
        let "tryDlCount++"
        [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${PERCONA_TAR_MD5}" -o "${tryDlCount}" == "6" ] && break || continue
      done
  
      if [ "${tryDlCount}" == "6" ]; then
        echo "${CFAILURE}${FILE_NAME} download failed, Please contact the author! ${CEND}"
        kill -9 $$
      else
        echo "[${CMSG}${FILE_NAME}${CEND}] found."
      fi
    fi
  fi
  # PHP
  if [ "${PHP_yn}" == "y" ]; then
    # php 5.3 5.4 5.5 5.6 5.7
    echo "PHP common..."
    src_url=http://ftp.gnu.org/pub/gnu/libiconv/libiconv-${libiconv_version}.tar.gz && Download_src
    src_url=https://curl.haxx.se/download/curl-${curl_version}.tar.gz && Download_src
    src_url=http://downloads.sourceforge.net/project/mcrypt/Libmcrypt/${libmcrypt_version}/libmcrypt-${libmcrypt_version}.tar.gz && Download_src
    src_url=http://downloads.sourceforge.net/project/mhash/mhash/${mhash_version}/mhash-${mhash_version}.tar.gz && Download_src
    src_url=http://downloads.sourceforge.net/project/mcrypt/MCrypt/${mcrypt_version}/mcrypt-${mcrypt_version}.tar.gz && Download_src
    src_url=${mirrorLink}/libiconv-glibc-2.16.patch && Download_src
    
    if [[ "${PHP_version}" =~ ^[1-3]$ ]]; then
      # php 5.3 5.4 5.5
      src_url=${mirrorLink}/fpm-race-condition.patch && Download_src
    fi
    
    if [ "${PHP_version}" == "1" ]; then
      # php 5.3
      src_url=${mirrorLink}/debian_patches_disable_SSLv2_for_openssl_1_0_0.patch && Download_src
      src_url=${mirrorLink}/php5.3patch && Download_src
      if [ "$Debian_version" == '8' -o "$Ubuntu_version" == '16' ]; then
        if [ ! -e "/usr/local/openssl/lib/libcrypto.a" ]; then
          src_url=${mirrorLink}/openssl-1.0.0s.tar.gz && Download_src
        fi
      fi
      src_url=http://www.php.net/distributions/php-${php_3_version}.tar.gz && Download_src
    fi
    if [ "${PHP_version}" == "2" ]; then
      src_url=http://www.php.net/distributions/php-${php_4_version}.tar.gz && Download_src
    fi
    if [ "${PHP_version}" == "3" ]; then
      src_url=http://www.php.net/distributions/php-${php_5_version}.tar.gz && Download_src
    fi
    if [ "${PHP_version}" == "4" ]; then
      src_url=http://www.php.net/distributions/php-${php_6_version}.tar.gz && Download_src
    fi
    if [ "${PHP_version}" == "5" ]; then
      src_url=http://www.php.net/distributions/php-${php_7_version}.tar.gz && Download_src
    fi
  fi
    
  # PHP OPCache
  if [ "${PHP_cache}" == "1" ] && [[ "$PHP_version" =~ ^[1,2]$ ]]; then
    # php 5.3 5.4
    echo "Download Zend OPCache..."
    src_url=https://pecl.php.net/get/zendopcache-${zendopcache_version}.tgz && Download_src
  fi
  if [ "${PHP_cache}" == "2" ] && [[ "$PHP_version" =~ ^[1-4]$ ]]; then
    # php 5.3 5.4 5.5 5.6
    echo "Download xcache..."
    src_url=http://xcache.lighttpd.net/pub/Releases/${xcache_version}/xcache-${xcache_version}.tar.gz && Download_src
  fi
  if [ "${PHP_cache}" == "3" ]; then
    # php 5.3 5.4 5.5 5.6 7.0
    echo "Download apcu..."
    if [ "${PHP_version}" != "5" ]; then
      src_url=http://pecl.php.net/get/apcu-${apcu_version}.tgz && Download_src
    else
      src_url=http://pecl.php.net/get/apcu-${apcu_for_php7_version}.tgz && Download_src
    fi
  fi
  if [ "${PHP_cache}" == "4" -a "${PHP_version}" == "2" ]; then
    echo "Download eaccelerator 1.0 dev..."
    src_url=https://github.com/eaccelerator/eaccelerator/tarball/master && Download_src
  elif [ "${PHP_cache}" == "4" -a "${PHP_version}" == "1" ]; then
    echo "Download eaccelerator 0.9..."
    src_url=https://github.com/downloads/eaccelerator/eaccelerator/eaccelerator-${eaccelerator_version}.tar.bz2 && Download_src
  fi
  
  # Zend Guard Loader
  if [ "${ZendGuardLoader_yn}" == "y" -a "${armPlatform}" != "y" ]; then
    if [ "${PHP_version}" == "4" ]; then
      if [ "${OS_BIT}" == "64" ]; then
        # 64 bit
        echo "Download ZendGuardLoader for php 5.6..."
        src_url=${mirrorLink}/zend-loader-php5.6-linux-x86_64.tar.gz && Download_src
      else
        # 32 bit
        echo "Download ZendGuardLoader for php 5.6..."
        src_url=${mirrorLink}/zend-loader-php5.6-linux-i386.tar.gz && Download_src
      fi
    fi
    if [ "${PHP_version}" == "3" ]; then
      if [ "${OS_BIT}" == "64" ]; then
        # 64 bit
        echo "Download ZendGuardLoader for php 5.5..."
        src_url=${mirrorLink}/zend-loader-php5.5-linux-x86_64.tar.gz && Download_src
      else
        # 32 bit
        echo "Download ZendGuardLoader for php 5.5..."
        src_url=${mirrorLink}/zend-loader-php5.5-linux-i386.tar.gz && Download_src
      fi
    fi
    if [ "${PHP_version}" == "2" ]; then
      if [ "${OS_BIT}" == "64" ]; then
        # 64 bit
        echo "Download ZendGuardLoader for php 5.4..."
        src_url=${mirrorLink}/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz && Download_src
      else
        # 32 bit
        echo "Download ZendGuardLoader for php 5.4..."
        src_url=${mirrorLink}/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz && Download_src
      fi
    fi
    if [ "${PHP_version}" == "1" ]; then
      if [ "${OS_BIT}" == "64" ]; then
        # 64 bit
        echo "Download ZendGuardLoader for php 5.3..."
        src_url=${mirrorLink}/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz && Download_src
      else
        # 32 bit
        echo "Download ZendGuardLoader for php 5.3..."
        src_url=${mirrorLink}/ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz && Download_src
      fi
    fi
  fi
  
  if [ "${ionCube_yn}" == "y" ]; then
    echo "Download ioncube..."
    if [ "${OS_BIT}" == '64' ]; then
      src_url=http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz && Download_src
    else
      if [ "${TARGET_ARCH}" == "armv7" ]; then
        src_url=http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_armv7l.tar.gz && Download_src
      else
        src_url=http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86.tar.gz && Download_src
      fi
    fi
  fi
  
  if [ "${Magick_yn}" == "y" ]; then
    if [ "${Magick}" == "1" ]; then
      echo "Download ImageMagick..."
      src_url=${mirrorLink}/ImageMagick-${ImageMagick_version}.tar.gz && Download_src
      if [ "${PHP_version}" == "1" ]; then 
        echo "Download image for php 5.3..."
        src_url=https://pecl.php.net/get/imagick-${imagick_for_php53_version}.tgz && Download_src
      else 
        echo "Download imagick..."
        src_url=http://pecl.php.net/get/imagick-${imagick_version}.tgz && Download_src
      fi
    else
      echo "Download graphicsmagick..."
      src_url=http://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick/${GraphicsMagick_version}/GraphicsMagick-${GraphicsMagick_version}.tar.gz && Download_src
      if [ "${PHP_version}" == "5" ]; then 
        echo "Download gmagick for php7..."
        src_url=https://pecl.php.net/get/gmagick-${gmagick_for_php7_version}.tgz && Download_src
      else
        echo "Download gmagick for php..."
        src_url=http://pecl.php.net/get/gmagick-${gmagick_version}.tgz && Download_src
      fi
    fi
  fi
  
  if [ "${FTP_yn}" == "y" ]; then
    echo "Download pureftpd..."
    src_url=http://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-${pureftpd_version}.tar.gz && Download_src
  fi
  
  if [ "${phpMyAdmin_yn}" == "y" ]; then
    echo "Download phpMyAdmin..."
    src_url=https://files.phpmyadmin.net/phpMyAdmin/${phpMyAdmin_version}/phpMyAdmin-${phpMyAdmin_version}-all-languages.tar.gz && Download_src
  fi
  
  if [ "${redis_yn}" == "y" ]; then
    echo "Download redis..."
    src_url=http://download.redis.io/releases/redis-${redis_version}.tar.gz && Download_src
    if [ "${OS}" == "CentOS" ]; then
      echo "Download start-stop-daemon.c for CentOS..."
      src_url=${mirrorLink}/start-stop-daemon.c && Download_src
    fi
    # redis addon
    if [ "${PHP_version}" == "5" ]; then
      echo "Download redis pecl for php7..."
      src_url=http://pecl.php.net/get/redis-${redis_pecl_for_php7_version}.tgz && Download_src
    else
      echo "Download redis pecl..."
      src_url=http://pecl.php.net/get/redis-${redis_pecl_version}.tgz && Download_src
    fi
  fi
  
  if [ "${memcached_yn}" == "y" ]; then
    echo "Download memcached..."
    src_url=http://www.memcached.org/files/memcached-${memcached_version}.tar.gz && Download_src
    if [ "${PHP_version}" == "5" ]; then
      echo "Download pecl memcache for php7..."
      src_url=${mirrorLink}/pecl-memcache-php7.tgz && Download_src
      echo "Download php-memcached for php7..."
      src_url=${mirrorLink}/php-memcached-php7.tgz && Download_src
    else
      echo "Download pecl memcache for php7..."
      src_url=http://pecl.php.net/get/memcache-${memcache_pecl_version}.tgz && Download_src
      echo "Download php-memcached for php7..."
      src_url=http://pecl.php.net/get/memcached-${memcached_pecl_version}.tgz && Download_src
    fi
    
    echo "Download libmemcached..."
    src_url=https://launchpad.net/libmemcached/1.0/${libmemcached_version}/+download/libmemcached-${libmemcached_version}.tar.gz && Download_src
  fi
  
  if [ "${je_tc_malloc_yn}" == "y" ]; then
    if [ "${je_tc_malloc}" == "1" ]; then
      echo "Download jemalloc..."
      src_url=${mirrorLink}/jemalloc-${jemalloc_version}.tar.bz2 && Download_src
    elif [ "${je_tc_malloc}" == "2" ]; then
      echo "Download tcmalloc..."
      src_url=${mirrorLink}/gperftools-${tcmalloc_version}.tar.gz && Download_src
    fi
  fi
  
  # others
  if [ "${OS}" == "CentOS" ]; then
    echo "Download tmux for CentOS..."
    src_url=${mirrorLink}/libevent-${libevent_version}.tar.gz && Download_src
    src_url=${mirrorLink}/tmux-${tmux_version}.tar.gz && Download_src
    
    echo "Download htop for CentOS..."
    src_url=http://hisham.hm/htop/releases/${htop_version}/htop-${htop_version}.tar.gz && Download_src
  fi
  
  if [[ "${Ubuntu_version}" =~ ^14$|^15$ ]]; then
    echo "Download bison for Ubuntu..."
    src_url=http://ftp.gnu.org/gnu/bison/bison-${bison_version}.tar.gz && Download_src
  fi
  popd
}
