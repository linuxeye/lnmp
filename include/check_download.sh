#!/bin/bash
# Author:  Alpha Eva <kaneawk AT gmail.com>
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

checkDownload() {
  mirrorLink=http://mirrors.linuxeye.com/oneinstack/src
  pushd ${oneinstack_dir}/src

  # Web
  if [ "${Web_yn}" == 'y' ]; then
    echo "Download openSSL..."
    src_url=https://www.openssl.org/source/openssl-${openssl_version}.tar.gz && Download_src
    src_url=http://curl.haxx.se/ca/cacert.pem && Download_src
    case "${Nginx_version}" in
      1)
        echo "Download nginx..."
        src_url=http://nginx.org/download/nginx-${nginx_version}.tar.gz && Download_src
        ;;
      2)
        echo "Download tengine..."
        src_url=http://tengine.taobao.org/download/tengine-${tengine_version}.tar.gz && Download_src
        ;;
      3)
        echo "Download openresty..."
        src_url=https://openresty.org/download/openresty-${openresty_version}.tar.gz && Download_src
        ;;
    esac

    if [[ "${Nginx_version}" =~ ^[1-3]$ || ${Apache_version} == '1' ]]; then
      echo "Download pcre..."
      src_url=${mirrorLink}/pcre-${pcre_version}.tar.gz && Download_src
    fi

    # apache
    if [ "${Apache_version}" == '1' ]; then
      echo "Download apache 2.4..."
      src_url=http://archive.apache.org/dist/apr/apr-${apr_version}.tar.gz && Download_src
      src_url=http://archive.apache.org/dist/apr/apr-util-${apr_util_version}.tar.gz && Download_src
      src_url=http://mirrors.linuxeye.com/apache/httpd/nghttp2-${nghttp2_version}.tar.gz && Download_src
      src_url=http://mirrors.linuxeye.com/apache/httpd/httpd-${apache24_version}.tar.gz && Download_src
    fi
    if [ "${Apache_version}" == '2' ]; then
      echo "Download apache 2.2..."
      src_url=http://mirrors.linuxeye.com/apache/httpd/httpd-${apache22_version}.tar.gz && Download_src

      echo "Download mod_remoteip.c for apache 2.2..."
      src_url=${mirrorLink}/mod_remoteip.c && Download_src
    fi

    # tomcat
    case "${Tomcat_version}" in
      1)
        echo "Download tomcat 8..."
        src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat8_version}/apache-tomcat-${tomcat8_version}.tar.gz && Download_src
        src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat8_version}/catalina-jmx-remote.jar && Download_src
        ;;
      2)
        echo "Download tomcat 7..."
        src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat7_version}/apache-tomcat-${tomcat7_version}.tar.gz && Download_src
        src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat7_version}/catalina-jmx-remote.jar && Download_src
        ;;
      3)
        echo "Download tomcat 6..."
        src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat6_version}/apache-tomcat-${tomcat6_version}.tar.gz && Download_src
        src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat6_version}/catalina-jmx-remote.jar && Download_src
        ;;
    esac

    if [[ "${JDK_version}"  =~ ^[1-3]$ ]]; then
      case "${JDK_version}" in
        1)
          echo "Download JDK 1.8..."
          JDK_FILE="jdk-$(echo ${jdk18_version} | awk -F. '{print $2}')u$(echo ${jdk18_version} | awk -F_ '{print $NF}')-linux-${SYS_BIG_FLAG}.tar.gz"
          ;;
        2)
          echo "Download JDK 1.7..."
          JDK_FILE="jdk-$(echo ${jdk17_version} | awk -F. '{print $2}')u$(echo ${jdk17_version} | awk -F_ '{print $NF}')-linux-${SYS_BIG_FLAG}.tar.gz"
          ;;
        3)
          echo "Download JDK 1.6..."
          JDK_FILE="jdk-$(echo ${jdk16_version} | awk -F. '{print $2}')u$(echo ${jdk16_version} | awk -F_ '{print $NF}')-linux-${SYS_BIG_FLAG}.bin"
          ;;
      esac
      echo "Download apr..."
      src_url=http://archive.apache.org/dist/apr/apr-${apr_version}.tar.gz && Download_src
      # start download...
      src_url=http://mirrors.linuxeye.com/jdk/${JDK_FILE} && Download_src
    fi
  fi

  if [ "${DB_yn}" == 'y' ]; then
    if [[ "${DB_version}" =~ ^[1,4,7]$ ]] && [ "${dbInstallMethods}" == "2" ]; then
      echo "Download boost..."
      [ "${IPADDR_COUNTRY}"x == "CN"x ] && DOWN_ADDR_BOOST=${mirrorLink} || DOWN_ADDR_BOOST=http://downloads.sourceforge.net/project/boost/boost/${boost_version}
      boostVersion2=$(echo ${boost_version} | awk -F. '{print $1}')_$(echo ${boost_version} | awk -F. '{print $2}')_$(echo ${boost_version} | awk -F. '{print $3}')
      src_url=${DOWN_ADDR_BOOST}/boost_${boostVersion2}.tar.gz && Download_src
    fi

    case "${DB_version}" in
      1)
        # MySQL 5.7
        if [ "${IPADDR_COUNTRY}"x == "CN"x -a "${IPADDR_ISP}" == "aliyun" -a "$(../include/check_port.py aliyun-oss.linuxeye.com 80)" == "True" ]; then
          DOWN_ADDR_MYSQL=http://aliyun-oss.linuxeye.com/mysql/MySQL-5.7
        else
          if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
            if [ "$(../include/check_port.py mirrors.tuna.tsinghua.edu.cn 443)" == "True" ]; then
              DOWN_ADDR_MYSQL=https://mirrors.tuna.tsinghua.edu.cn/mysql/downloads/MySQL-5.7
              DOWN_ADDR_MYSQL_BK=http://mirrors.ustc.edu.cn/mysql-ftp/Downloads/MySQL-5.7
            else
              DOWN_ADDR_MYSQL=http://mirrors.ustc.edu.cn/mysql-ftp/Downloads/MySQL-5.7
              DOWN_ADDR_MYSQL_BK=https://mirrors.tuna.tsinghua.edu.cn/mysql/downloads/MySQL-5.7
            fi
          else
            if [ "$(../include/check_port.py cdn.mysql.com 80)" == "True" ]; then
              DOWN_ADDR_MYSQL=http://cdn.mysql.com/Downloads/MySQL-5.7
              DOWN_ADDR_MYSQL_BK=http://mysql.he.net/Downloads/MySQL-5.7
            else
              DOWN_ADDR_MYSQL=http://mysql.he.net/Downloads/MySQL-5.7
              DOWN_ADDR_MYSQL_BK=http://cdn.mysql.com/Downloads/MySQL-5.7
            fi
          fi
        fi
        if [ "${dbInstallMethods}" == '1' ]; then
          echo "Download MySQL 5.7 binary package..."
          FILE_NAME=mysql-${mysql57_version}-linux-glibc2.12-${SYS_BIT_b}.tar.gz
        elif [ "${dbInstallMethods}" == '2' ]; then
          echo "Download MySQL 5.7 source package..."
          FILE_NAME=mysql-${mysql57_version}.tar.gz
        fi
        # start download
        wget --tries=6 -c --no-check-certificate ${DOWN_ADDR_MYSQL}/${FILE_NAME}
        # verifying download
        MYSQL_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MYSQL}/${FILE_NAME}.md5 | grep ${FILE_NAME} | awk '{print $1}')
        [ -z "${MYSQL_TAR_MD5}" ] && MYSQL_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MYSQL_BK}/${FILE_NAME}.md5 | grep ${FILE_NAME} | awk '{print $1}') 
        tryDlCount=0
        while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${MYSQL_TAR_MD5}" ]; do
          wget -c --no-check-certificate ${DOWN_ADDR_MYSQL_BK}/${FILE_NAME};sleep 1
          let "tryDlCount++"
          [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${MYSQL_TAR_MD5}" -o "${tryDlCount}" == '6' ] && break || continue
        done
        if [ "${tryDlCount}" == '6' ]; then
          echo "${CFAILURE}${FILE_NAME} download failed, Please contact the author! ${CEND}"
          kill -9 $$
        else
          echo "[${CMSG}${FILE_NAME}${CEND}] found."
        fi
        ;;

      2)
        # MySQL 5.6
        if [ "${IPADDR_COUNTRY}"x == "CN"x -a "${IPADDR_ISP}" == "aliyun" -a "$(../include/check_port.py aliyun-oss.linuxeye.com 80)" == "True" ]; then
          DOWN_ADDR_MYSQL=http://aliyun-oss.linuxeye.com/mysql/MySQL-5.6
        else
          if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
            if [ "$(../include/check_port.py mirrors.tuna.tsinghua.edu.cn 443)" == "True" ]; then
              DOWN_ADDR_MYSQL=https://mirrors.tuna.tsinghua.edu.cn/mysql/downloads/MySQL-5.6
              DOWN_ADDR_MYSQL_BK=http://mirrors.ustc.edu.cn/mysql-ftp/Downloads/MySQL-5.6
            else
              DOWN_ADDR_MYSQL=http://mirrors.ustc.edu.cn/mysql-ftp/Downloads/MySQL-5.6
              DOWN_ADDR_MYSQL_BK=https://mirrors.tuna.tsinghua.edu.cn/mysql/downloads/MySQL-5.6
            fi
          else
            if [ "$(../include/check_port.py cdn.mysql.com 80)" == "True" ]; then
              DOWN_ADDR_MYSQL=http://cdn.mysql.com/Downloads/MySQL-5.6
              DOWN_ADDR_MYSQL_BK=http://mysql.he.net/Downloads/MySQL-5.6
            else
              DOWN_ADDR_MYSQL=http://mysql.he.net/Downloads/MySQL-5.6
              DOWN_ADDR_MYSQL_BK=http://cdn.mysql.com/Downloads/MySQL-5.6
            fi
          fi
        fi
        if [ "${dbInstallMethods}" == '1' ]; then
          echo "Download MySQL 5.6 binary package..."
          FILE_NAME=mysql-${mysql56_version}-linux-glibc2.12-${SYS_BIT_b}.tar.gz
        elif [ "${dbInstallMethods}" == '2' ]; then
          echo "Download MySQL 5.6 source package..."
          FILE_NAME=mysql-${mysql56_version}.tar.gz
        fi
        wget --tries=6 -c --no-check-certificate ${DOWN_ADDR_MYSQL}/${FILE_NAME}
        # verifying download
        MYSQL_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MYSQL}/${FILE_NAME}.md5 | grep ${FILE_NAME} | awk '{print $1}')
        [ -z "${MYSQL_TAR_MD5}" ] && MYSQL_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MYSQL_BK}/${FILE_NAME}.md5 | grep ${FILE_NAME} | awk '{print $1}') 
        tryDlCount=0
        while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${MYSQL_TAR_MD5}" ]; do
          wget -c --no-check-certificate ${DOWN_ADDR_MYSQL_BK}/${FILE_NAME};sleep 1
          let "tryDlCount++"
          [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${MYSQL_TAR_MD5}" -o "${tryDlCount}" == '6' ] && break || continue
        done
        if [ "${tryDlCount}" == '6' ]; then
          echo "${CFAILURE}${FILE_NAME} download failed, Please contact the author! ${CEND}"
          kill -9 $$
        else
          echo "[${CMSG}${FILE_NAME}${CEND}] found."
        fi
        ;;

      3)
        # MySQL 5.5
        if [ "${IPADDR_COUNTRY}"x == "CN"x -a "${IPADDR_ISP}" == "aliyun" -a "$(../include/check_port.py aliyun-oss.linuxeye.com 80)" == "True" ]; then
          DOWN_ADDR_MYSQL=http://aliyun-oss.linuxeye.com/mysql/MySQL-5.5
        else
          if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
            if [ "$(../include/check_port.py mirrors.tuna.tsinghua.edu.cn 443)" == "True" ]; then
              DOWN_ADDR_MYSQL=https://mirrors.tuna.tsinghua.edu.cn/mysql/downloads/MySQL-5.5
              DOWN_ADDR_MYSQL_BK=http://mirrors.ustc.edu.cn/mysql-ftp/Downloads/MySQL-5.5
            else
              DOWN_ADDR_MYSQL=http://mirrors.ustc.edu.cn/mysql-ftp/Downloads/MySQL-5.5
              DOWN_ADDR_MYSQL_BK=https://mirrors.tuna.tsinghua.edu.cn/mysql/downloads/MySQL-5.5
            fi
          else
            if [ "$(../include/check_port.py cdn.mysql.com 80)" == "True" ]; then
              DOWN_ADDR_MYSQL=http://cdn.mysql.com/Downloads/MySQL-5.5
              DOWN_ADDR_MYSQL_BK=http://mysql.he.net/Downloads/MySQL-5.5
            else
              DOWN_ADDR_MYSQL=http://mysql.he.net/Downloads/MySQL-5.5
              DOWN_ADDR_MYSQL_BK=http://cdn.mysql.com/Downloads/MySQL-5.5
            fi
          fi
        fi
        if [ "${dbInstallMethods}" == '1' ]; then
          echo "Download MySQL 5.5 binary package..."
          FILE_NAME=mysql-${mysql55_version}-linux-glibc2.12-${SYS_BIT_b}.tar.gz
        elif [ "${dbInstallMethods}" == '2' ]; then
          echo "Download MySQL 5.5 source package..."
          FILE_NAME=mysql-${mysql55_version}.tar.gz
          src_url=${mirrorLink}/mysql-5.5-fix-arm-client_plugin.patch && Download_src
        fi
        wget --tries=6 -c --no-check-certificate ${DOWN_ADDR_MYSQL}/${FILE_NAME}
        # verifying download
        MYSQL_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MYSQL}/${FILE_NAME}.md5 | grep ${FILE_NAME} | awk '{print $1}')
        [ -z "${MYSQL_TAR_MD5}" ] && MYSQL_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MYSQL_BK}/${FILE_NAME}.md5 | grep ${FILE_NAME} | awk '{print $1}') 
        tryDlCount=0
        while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${MYSQL_TAR_MD5}" ]; do
          wget -c --no-check-certificate ${DOWN_ADDR_MYSQL_BK}/${FILE_NAME};sleep 1
          let "tryDlCount++"
          [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${MYSQL_TAR_MD5}" -o "${tryDlCount}" == '6' ] && break || continue
        done
        if [ "${tryDlCount}" == '6' ]; then
          echo "${CFAILURE}${FILE_NAME} download failed, Please contact the author! ${CEND}"
          kill -9 $$
        else
          echo "[${CMSG}${FILE_NAME}${CEND}] found."
        fi
        ;;

      4)
        # MariaDB 10.2
        if [ "${dbInstallMethods}" == '1' ]; then
          echo "Download MariaDB 10.2 binary package..."
          FILE_NAME=mariadb-${mariadb102_version}-${GLIBC_FLAG}-${SYS_BIT_b}.tar.gz
          if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
            DOWN_ADDR_MARIADB=https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-${mariadb102_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
            MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}')
            [ -z "${MARAIDB_TAR_MD5}" ] && { DOWN_ADDR_MARIADB=https://mirrors.ustc.edu.cn/mariadb/mariadb-${mariadb102_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}; MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}'); }
          else
            DOWN_ADDR_MARIADB=https://downloads.mariadb.org/interstitial/mariadb-${mariadb102_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
            MARAIDB_TAR_MD5=$(curl -Lk http://archive.mariadb.org/mariadb-${mariadb102_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}/md5sums.txt |  grep ${FILE_NAME} | awk '{print $1}')
          fi
        elif [ "${dbInstallMethods}" == '2' ]; then
          echo "Download MariaDB 10.2 source package..."
          FILE_NAME=mariadb-${mariadb102_version}.tar.gz
          if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
            DOWN_ADDR_MARIADB=https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-${mariadb102_version}/source
            MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}')
            [ -z "${MARAIDB_TAR_MD5}" ] && { DOWN_ADDR_MARIADB=https://mirrors.ustc.edu.cn/mariadb/mariadb-${mariadb102_version}/source; MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}'); }
          else
            DOWN_ADDR_MARIADB=https://downloads.mariadb.org/interstitial/mariadb-${mariadb102_version}/source
            MARAIDB_TAR_MD5=$(curl -Lk http://archive.mariadb.org/mariadb-${mariadb102_version}/source/md5sums.txt |  grep ${FILE_NAME} | awk '{print $1}')
          fi
        fi
        tryDlCount=0
        while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${MARAIDB_TAR_MD5}" ]; do
          wget -c --no-check-certificate ${DOWN_ADDR_MARIADB}/${FILE_NAME};sleep 1
          let "tryDlCount++"
          [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${MARAIDB_TAR_MD5}" -o "${tryDlCount}" == '6' ] && break || continue
        done
        if [ "${tryDlCount}" == '6' ]; then
          echo "${CFAILURE}${FILE_NAME} download failed, Please contact the author! ${CEND}"
          kill -9 $$
        else
          echo "[${CMSG}${FILE_NAME}${CEND}] found."
        fi
        ;;

      5)
        # MariaDB 10.1
        if [ "${dbInstallMethods}" == '1' ]; then
          echo "Download MariaDB 10.1 binary package..."
          FILE_NAME=mariadb-${mariadb101_version}-${GLIBC_FLAG}-${SYS_BIT_b}.tar.gz
          if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
            DOWN_ADDR_MARIADB=https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-${mariadb101_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
            MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}')
            [ -z "${MARAIDB_TAR_MD5}" ] && { DOWN_ADDR_MARIADB=https://mirrors.ustc.edu.cn/mariadb/mariadb-${mariadb101_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}; MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}'); }
          else
            DOWN_ADDR_MARIADB=https://downloads.mariadb.org/interstitial/mariadb-${mariadb101_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
            MARAIDB_TAR_MD5=$(curl -Lk http://archive.mariadb.org/mariadb-${mariadb101_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}/md5sums.txt |  grep ${FILE_NAME} | awk '{print $1}')
          fi
        elif [ "${dbInstallMethods}" == '2' ]; then
          echo "Download MariaDB 10.1 source package..."
          FILE_NAME=mariadb-${mariadb101_version}.tar.gz
          if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
            DOWN_ADDR_MARIADB=https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-${mariadb101_version}/source
            MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}')
            [ -z "${MARAIDB_TAR_MD5}" ] && { DOWN_ADDR_MARIADB=https://mirrors.ustc.edu.cn/mariadb/mariadb-${mariadb101_version}/source; MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}'); }
          else
            DOWN_ADDR_MARIADB=https://downloads.mariadb.org/interstitial/mariadb-${mariadb101_version}/source
            MARAIDB_TAR_MD5=$(curl -Lk http://archive.mariadb.org/mariadb-${mariadb101_version}/source/md5sums.txt |  grep ${FILE_NAME} | awk '{print $1}')
          fi
        fi
        tryDlCount=0
        while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${MARAIDB_TAR_MD5}" ]; do
          wget -c --no-check-certificate ${DOWN_ADDR_MARIADB}/${FILE_NAME};sleep 1
          let "tryDlCount++"
          [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${MARAIDB_TAR_MD5}" -o "${tryDlCount}" == '6' ] && break || continue
        done
        if [ "${tryDlCount}" == '6' ]; then
          echo "${CFAILURE}${FILE_NAME} download failed, Please contact the author! ${CEND}"
          kill -9 $$
        else
          echo "[${CMSG}${FILE_NAME}${CEND}] found."
        fi
        ;;

      6)
        # MariaDB 10.0
        if [ "${dbInstallMethods}" == '1' ]; then
          echo "Download MariaDB 10.0 binary package..."
          FILE_NAME=mariadb-${mariadb100_version}-${GLIBC_FLAG}-${SYS_BIT_b}.tar.gz
          if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
            DOWN_ADDR_MARIADB=https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-${mariadb100_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
            MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}')
            [ -z "${MARAIDB_TAR_MD5}" ] && { DOWN_ADDR_MARIADB=https://mirrors.ustc.edu.cn/mariadb/mariadb-${mariadb100_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}; MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}'); }
          else
            DOWN_ADDR_MARIADB=https://downloads.mariadb.org/interstitial/mariadb-${mariadb100_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
            MARAIDB_TAR_MD5=$(curl -Lk http://archive.mariadb.org/mariadb-${mariadb100_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}/md5sums.txt |  grep ${FILE_NAME} | awk '{print $1}')
          fi
        elif [ "${dbInstallMethods}" == '2' ]; then
          echo "Download MariaDB 10.0 source package..."
          FILE_NAME=mariadb-${mariadb100_version}.tar.gz
          if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
            DOWN_ADDR_MARIADB=https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-${mariadb100_version}/source
            MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}')
            [ -z "${MARAIDB_TAR_MD5}" ] && { DOWN_ADDR_MARIADB=https://mirrors.ustc.edu.cn/mariadb/mariadb-${mariadb100_version}/source; MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}'); }
          else
            DOWN_ADDR_MARIADB=https://downloads.mariadb.org/interstitial/mariadb-${mariadb100_version}/source
            MARAIDB_TAR_MD5=$(curl -Lk http://archive.mariadb.org/mariadb-${mariadb100_version}/source/md5sums.txt |  grep ${FILE_NAME} | awk '{print $1}')
          fi
        fi
        tryDlCount=0
        while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${MARAIDB_TAR_MD5}" ]; do
          wget -c --no-check-certificate ${DOWN_ADDR_MARIADB}/${FILE_NAME};sleep 1
          let "tryDlCount++"
          [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${MARAIDB_TAR_MD5}" -o "${tryDlCount}" == '6' ] && break || continue
        done
        if [ "${tryDlCount}" == '6' ]; then
          echo "${CFAILURE}${FILE_NAME} download failed, Please contact the author! ${CEND}"
          kill -9 $$
        else
          echo "[${CMSG}${FILE_NAME}${CEND}] found."
        fi
        ;;

      7)
        # MariaDB 5.5
        if [ "${dbInstallMethods}" == '1' ]; then
          echo "Download MariaDB 5.5 binary package..."
          FILE_NAME=mariadb-${mariadb55_version}-${GLIBC_FLAG}-${SYS_BIT_b}.tar.gz
          if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
            DOWN_ADDR_MARIADB=https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-${mariadb55_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
            MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}')
            [ -z "${MARAIDB_TAR_MD5}" ] && { DOWN_ADDR_MARIADB=https://mirrors.ustc.edu.cn/mariadb/mariadb-${mariadb55_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}; MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}'); }
          else
            DOWN_ADDR_MARIADB=https://downloads.mariadb.org/interstitial/mariadb-${mariadb55_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
            MARAIDB_TAR_MD5=$(curl -Lk http://archive.mariadb.org/mariadb-${mariadb55_version}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}/md5sums.txt |  grep ${FILE_NAME} | awk '{print $1}')
          fi
        elif [ "${dbInstallMethods}" == '2' ]; then
          echo "Download MariaDB 5.5 source package..."
          FILE_NAME=mariadb-${mariadb55_version}.tar.gz
          if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
            DOWN_ADDR_MARIADB=https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-${mariadb55_version}/source
            MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}')
            [ -z "${MARAIDB_TAR_MD5}" ] && { DOWN_ADDR_MARIADB=https://mirrors.ustc.edu.cn/mariadb/mariadb-${mariadb55_version}/source; MARAIDB_TAR_MD5=$(curl -Lk ${DOWN_ADDR_MARIADB}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}'); }
          else
            DOWN_ADDR_MARIADB=https://downloads.mariadb.org/interstitial/mariadb-${mariadb55_version}/source
            MARAIDB_TAR_MD5=$(curl -Lk http://archive.mariadb.org/mariadb-${mariadb55_version}/source/md5sums.txt |  grep ${FILE_NAME} | awk '{print $1}')
          fi
        fi
        tryDlCount=0
        while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${MARAIDB_TAR_MD5}" ]; do
          wget -c --no-check-certificate ${DOWN_ADDR_MARIADB}/${FILE_NAME};sleep 1
          let "tryDlCount++"
          [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${MARAIDB_TAR_MD5}" -o "${tryDlCount}" == '6' ] && break || continue
        done
        if [ "${tryDlCount}" == '6' ]; then
          echo "${CFAILURE}${FILE_NAME} download failed, Please contact the author! ${CEND}"
          kill -9 $$
        else
          echo "[${CMSG}${FILE_NAME}${CEND}] found."
        fi
        ;;

      8)
        # Precona 5.7
        if [ "${dbInstallMethods}" == '1' ]; then
          echo "Download Percona 5.7 binary package..."
          FILE_NAME=Percona-Server-${percona57_version}-Linux.${SYS_BIT_b}.${sslLibVer}.tar.gz
          DOWN_ADDR_PERCONA=https://www.percona.com/downloads/Percona-Server-5.7/Percona-Server-${percona57_version}/binary/tarball
          PERCONA_TAR_MD5=$(curl -Lk https://www.percona.com/downloads/Percona-Server-5.7/Percona-Server-${percona57_version}/binary/tarball/${FILE_NAME}.md5sum |  grep ${FILE_NAME} | awk '{print $1}')
        elif [ "${dbInstallMethods}" == '2' ]; then
          echo "Download Percona 5.7 source package..."
          FILE_NAME=percona-server-${percona57_version}.tar.gz
          if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
            DOWN_ADDR_PERCONA=${mirrorLink}
            DOWN_ADDR_PERCONA_BK=https://www.percona.com/downloads/Percona-Server-5.7/Percona-Server-${percona57_version}/source/tarball
            PERCONA_TAR_MD5=$(curl -Lk ${DOWN_ADDR_PERCONA}/${FILE_NAME}.md5sum | grep ${FILE_NAME} | awk '{print $1}')
            [ -z "${PERCONA_TAR_MD5}" ] && { DOWN_ADDR_PERCONA=${DOWN_ADDR_PERCONA_BK}; PERCONA_TAR_MD5=$(curl -Lk ${DOWN_ADDR_PERCONA_BK}/${FILE_NAME}.md5sum | grep ${FILE_NAME} | awk '{print $1}'); }
          else
            DOWN_ADDR_PERCONA=https://www.percona.com/downloads/Percona-Server-5.7/Percona-Server-${percona57_version}/source/tarball
            PERCONA_TAR_MD5=$(curl -Lk ${DOWN_ADDR_PERCONA}/${FILE_NAME}.md5sum |  grep ${FILE_NAME} | awk '{print $1}')
          fi
        fi
        tryDlCount=0
        while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${PERCONA_TAR_MD5}" ]; do
          wget -c --no-check-certificate ${DOWN_ADDR_PERCONA}/${FILE_NAME}; sleep 1
          let "tryDlCount++"
          [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${PERCONA_TAR_MD5}" -o "${tryDlCount}" == '6' ] && break || continue
        done
        if [ "${tryDlCount}" == '6' ]; then
          echo "${CFAILURE}${FILE_NAME} download failed, Please contact the author! ${CEND}"
          kill -9 $$
        else
          echo "[${CMSG}${FILE_NAME}${CEND}] found."
        fi
        ;;

      9)
        # Precona 5.6
        if [ "${dbInstallMethods}" == '1' ]; then
          echo "Download Percona 5.6 binary package..."
          perconaVerStr1=$(echo ${percona56_version} | sed "s@-@-rel@")
          FILE_NAME=Percona-Server-${perconaVerStr1}-Linux.${SYS_BIT_b}.${sslLibVer}.tar.gz
          DOWN_ADDR_PERCONA=https://www.percona.com/downloads/Percona-Server-5.6/Percona-Server-${percona56_version}/binary/tarball
          PERCONA_TAR_MD5=$(curl -Lk https://www.percona.com/downloads/Percona-Server-5.6/Percona-Server-${percona56_version}/binary/tarball/${FILE_NAME}.md5sum |  grep ${FILE_NAME} | awk '{print $1}')
        elif [ "${dbInstallMethods}" == '2' ]; then
          echo "Download Percona 5.6 source package..."
          FILE_NAME=percona-server-${percona56_version}.tar.gz
          if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
            DOWN_ADDR_PERCONA=${mirrorLink}
            DOWN_ADDR_PERCONA_BK=https://www.percona.com/downloads/Percona-Server-5.6/Percona-Server-${percona56_version}/source/tarball
            PERCONA_TAR_MD5=$(curl -Lk ${DOWN_ADDR_PERCONA}/${FILE_NAME}.md5sum | grep ${FILE_NAME} | awk '{print $1}')
            [ -z "${PERCONA_TAR_MD5}" ] && { DOWN_ADDR_PERCONA=${DOWN_ADDR_PERCONA_BK}; PERCONA_TAR_MD5=$(curl -Lk ${DOWN_ADDR_PERCONA_BK}/${FILE_NAME}.md5sum | grep ${FILE_NAME} | awk '{print $1}'); }
          else
            DOWN_ADDR_PERCONA=https://www.percona.com/downloads/Percona-Server-5.6/Percona-Server-${percona56_version}/source/tarball
            PERCONA_TAR_MD5=$(curl -Lk ${DOWN_ADDR_PERCONA}/${FILE_NAME}.md5sum |  grep ${FILE_NAME} | awk '{print $1}')
          fi
        fi
        tryDlCount=0
        while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${PERCONA_TAR_MD5}" ]; do
          wget -c --no-check-certificate ${DOWN_ADDR_PERCONA}/${FILE_NAME}; sleep 1
          let "tryDlCount++"
          [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${PERCONA_TAR_MD5}" -o "${tryDlCount}" == '6' ] && break || continue
        done
        if [ "${tryDlCount}" == '6' ]; then
          echo "${CFAILURE}${FILE_NAME} download failed, Please contact the author! ${CEND}"
          kill -9 $$
        else
          echo "[${CMSG}${FILE_NAME}${CEND}] found."
        fi
        ;;

      10)
        # Percona 5.5
        if [ "${dbInstallMethods}" == '1' ]; then
          echo "Download Percona 5.5 binary package..."
          perconaVerStr1=$(echo ${percona55_version} | sed "s@-@-rel@")
          FILE_NAME=Percona-Server-${perconaVerStr1}-Linux.${SYS_BIT_b}.${sslLibVer}.tar.gz
          DOWN_ADDR_PERCONA=https://www.percona.com/downloads/Percona-Server-5.5/Percona-Server-${percona55_version}/binary/tarball
          PERCONA_TAR_MD5=$(curl -Lk https://www.percona.com/downloads/Percona-Server-5.5/Percona-Server-${percona55_version}/binary/tarball/${FILE_NAME}.md5sum |  grep ${FILE_NAME} | awk '{print $1}')
        elif [ "${dbInstallMethods}" == '2' ]; then
          echo "Download Percona 5.5 source package..."
          FILE_NAME=percona-server-${percona55_version}.tar.gz
          if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
            DOWN_ADDR_PERCONA=${mirrorLink}
            DOWN_ADDR_PERCONA_BK=https://www.percona.com/downloads/Percona-Server-5.5/Percona-Server-${percona55_version}/source/tarball
            PERCONA_TAR_MD5=$(curl -Lk ${DOWN_ADDR_PERCONA}/${FILE_NAME}.md5sum | grep ${FILE_NAME} | awk '{print $1}')
            [ -z "${PERCONA_TAR_MD5}" ] && { DOWN_ADDR_PERCONA=${DOWN_ADDR_PERCONA_BK}; PERCONA_TAR_MD5=$(curl -Lk ${DOWN_ADDR_PERCONA_BK}/${FILE_NAME}.md5sum | grep ${FILE_NAME} | awk '{print $1}'); }
          else
            DOWN_ADDR_PERCONA=https://www.percona.com/downloads/Percona-Server-5.5/Percona-Server-${percona55_version}/source/tarball
            PERCONA_TAR_MD5=$(curl -Lk ${DOWN_ADDR_PERCONA}/${FILE_NAME}.md5sum | grep ${FILE_NAME} | awk '{print $1}')
          fi
        fi
        tryDlCount=0
        while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${PERCONA_TAR_MD5}" ]; do
          wget -c --no-check-certificate ${DOWN_ADDR_PERCONA}/${FILE_NAME}; sleep 1
          let "tryDlCount++"
          [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${PERCONA_TAR_MD5}" -o "${tryDlCount}" == '6' ] && break || continue
        done
        if [ "${tryDlCount}" == '6' ]; then
          echo "${CFAILURE}${FILE_NAME} download failed, Please contact the author! ${CEND}"
          kill -9 $$
        else
          echo "[${CMSG}${FILE_NAME}${CEND}] found."
        fi
        ;;

      11)
        # AliSQL 5.6
        DOWN_ADDR_ALISQL=$mirrorLink
        echo "Download AliSQL 5.6 source package..."
        FILE_NAME=alisql-${alisql56_version}.tar.gz
        wget --tries=6 -c --no-check-certificate ${DOWN_ADDR_ALISQL}/${FILE_NAME}
        wget --tries=6 -c --no-check-certificate ${DOWN_ADDR_ALISQL}/${FILE_NAME}.md5
        ALISQL_TAR_MD5=$(awk '{print $1}' ${FILE_NAME}.md5)
        while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${ALISQL_TAR_MD5}" ];do
          wget -4c --no-check-certificate ${DOWN_ADDR_ALISQL}/${FILE_NAME};sleep 1
          [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${ALISQL_TAR_MD5}" ] && break || continue
        done
        ;;
    esac
  fi
  # PHP
  if [ "${PHP_yn}" == 'y' ]; then
    # php 5.3 5.4 5.5 5.6 5.7
    echo "PHP common..."
    src_url=http://ftp.gnu.org/pub/gnu/libiconv/libiconv-${libiconv_version}.tar.gz && Download_src
    src_url=https://curl.haxx.se/download/curl-${curl_version}.tar.gz && Download_src
    src_url=http://downloads.sourceforge.net/project/mcrypt/Libmcrypt/${libmcrypt_version}/libmcrypt-${libmcrypt_version}.tar.gz && Download_src
    src_url=http://downloads.sourceforge.net/project/mhash/mhash/${mhash_version}/mhash-${mhash_version}.tar.gz && Download_src
    src_url=http://downloads.sourceforge.net/project/mcrypt/MCrypt/${mcrypt_version}/mcrypt-${mcrypt_version}.tar.gz && Download_src
    src_url=${mirrorLink}/libiconv-glibc-2.16.patch && Download_src

    case "${PHP_version}" in
      1)
        # php 5.3
        src_url=${mirrorLink}/debian_patches_disable_SSLv2_for_openssl_1_0_0.patch && Download_src
        src_url=${mirrorLink}/php5.3patch && Download_src
        src_url=http://www.php.net/distributions/php-${php53_version}.tar.gz && Download_src
        src_url=${mirrorLink}/fpm-race-condition.patch && Download_src
        ;;
      2)
        src_url=http://www.php.net/distributions/php-${php54_version}.tar.gz && Download_src
        src_url=${mirrorLink}/fpm-race-condition.patch && Download_src
        ;;
      3)
        src_url=http://www.php.net/distributions/php-${php55_version}.tar.gz && Download_src
        src_url=${mirrorLink}/fpm-race-condition.patch && Download_src
        ;;
      4)
        src_url=http://www.php.net/distributions/php-${php56_version}.tar.gz && Download_src
        ;;
      5)
        src_url=http://www.php.net/distributions/php-${php70_version}.tar.gz && Download_src
        ;;
      6)
        src_url=http://www.php.net/distributions/php-${php71_version}.tar.gz && Download_src
        ;;
    esac
  fi

  # PHP OPCache
  case "${PHP_cache}" in
    1)
      if [[ "$PHP_version" =~ ^[1,2]$ ]]; then
        # php 5.3 5.4
        echo "Download Zend OPCache..."
        src_url=https://pecl.php.net/get/zendopcache-${zendopcache_version}.tgz && Download_src
      fi
      ;;
    2)
      if [[ "$PHP_version" =~ ^[1-4]$ ]]; then
        # php 5.3 5.4 5.5 5.6
        echo "Download xcache..."
        src_url=http://xcache.lighttpd.net/pub/Releases/${xcache_version}/xcache-${xcache_version}.tar.gz && Download_src
      fi
      ;;
    3)
      # php 5.3 5.4 5.5 5.6 7.0 7.1
      echo "Download apcu..."
      if [[ "$PHP_version" =~ ^[1-4]$ ]]; then
        src_url=http://pecl.php.net/get/apcu-${apcu_version}.tgz && Download_src
      else
        src_url=http://pecl.php.net/get/apcu-${apcu_for_php7_version}.tgz && Download_src
      fi
      ;;
    4)
      # php 5.3 5.4
      if [ "${PHP_version}" == '1' ]; then
        echo "Download eaccelerator 0.9..."
        src_url=https://github.com/downloads/eaccelerator/eaccelerator/eaccelerator-${eaccelerator_version}.tar.bz2 && Download_src
      elif [ "${PHP_version}" == '2' ]; then
        echo "Download eaccelerator 1.0 dev..."
        src_url=https://github.com/eaccelerator/eaccelerator/tarball/master && Download_src
      fi
      ;;
  esac

  # Zend Guard Loader
  if [ "${ZendGuardLoader_yn}" == 'y' -a "${armPlatform}" != 'y' ]; then
    case "${PHP_version}" in
      4)
        if [ "${OS_BIT}" == "64" ]; then
          # 64 bit
          echo "Download zend loader for php 5.6..."
          src_url=${mirrorLink}/zend-loader-php5.6-linux-x86_64.tar.gz && Download_src
        else
          # 32 bit
          echo "Download zend loader for php 5.6..."
          src_url=${mirrorLink}/zend-loader-php5.6-linux-i386.tar.gz && Download_src
        fi
        ;;
      3)
        if [ "${OS_BIT}" == "64" ]; then
          # 64 bit
          echo "Download zend loader for php 5.5..."
          src_url=${mirrorLink}/zend-loader-php5.5-linux-x86_64.tar.gz && Download_src
        else
          # 32 bit
          echo "Download zend loader for php 5.5..."
          src_url=${mirrorLink}/zend-loader-php5.5-linux-i386.tar.gz && Download_src
        fi
        ;;
      2)
        if [ "${OS_BIT}" == "64" ]; then
          # 64 bit
          echo "Download zend loader for php 5.4..."
          src_url=${mirrorLink}/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz && Download_src
        else
          # 32 bit
          echo "Download zend loader for php 5.4..."
          src_url=${mirrorLink}/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-i386.tar.gz && Download_src
        fi
        ;;
      1)
        if [ "${OS_BIT}" == "64" ]; then
          # 64 bit
          echo "Download zend loader for php 5.3..."
          src_url=${mirrorLink}/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz && Download_src
        else
          # 32 bit
          echo "Download zend loader for php 5.3..."
          src_url=${mirrorLink}/ZendGuardLoader-php-5.3-linux-glibc23-i386.tar.gz && Download_src
        fi
        ;;
    esac
  fi

  if [ "${ionCube_yn}" == 'y' ]; then
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

  if [ "${Magick_yn}" == 'y' ]; then
    if [ "${Magick}" == '1' ]; then
      echo "Download ImageMagick..."
      src_url=${mirrorLink}/ImageMagick-${ImageMagick_version}.tar.gz && Download_src
      echo "Download imagick..."
      src_url=http://pecl.php.net/get/imagick-${imagick_version}.tgz && Download_src
    else
      echo "Download graphicsmagick..."
      src_url=http://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick/${GraphicsMagick_version}/GraphicsMagick-${GraphicsMagick_version}.tar.gz && Download_src
      if [[ "$PHP_version" =~ ^[5-6]$ ]]; then
        echo "Download gmagick for php 7.x..."
        src_url=https://pecl.php.net/get/gmagick-${gmagick_for_php7_version}.tgz && Download_src
      else
        echo "Download gmagick for php..."
        src_url=http://pecl.php.net/get/gmagick-${gmagick_version}.tgz && Download_src
      fi
    fi
  fi

  if [ "${FTP_yn}" == 'y' ]; then
    echo "Download pureftpd..."
    src_url=https://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-${pureftpd_version}.tar.gz && Download_src
  fi

  if [ "${phpMyAdmin_yn}" == 'y' ]; then
    echo "Download phpMyAdmin..."
    src_url=https://files.phpmyadmin.net/phpMyAdmin/${phpMyAdmin_version}/phpMyAdmin-${phpMyAdmin_version}-all-languages.tar.gz && Download_src
  fi

  if [ "${redis_yn}" == 'y' ]; then
    echo "Download redis..."
    src_url=http://download.redis.io/releases/redis-${redis_version}.tar.gz && Download_src
    echo "Download redis pecl..."
    src_url=http://pecl.php.net/get/redis-${redis_pecl_version}.tgz && Download_src
    if [ "${OS}" == "CentOS" ]; then
      echo "Download start-stop-daemon.c for CentOS..."
      src_url=${mirrorLink}/start-stop-daemon.c && Download_src
    fi
  fi

  if [ "${memcached_yn}" == 'y' ]; then
    echo "Download memcached..."
    src_url=http://www.memcached.org/files/memcached-${memcached_version}.tar.gz && Download_src
    if [[ "$PHP_version" =~ ^[5-6]$ ]]; then
      echo "Download pecl memcache for php 7.x..."
      # src_url=https://codeload.github.com/websupport-sk/pecl-memcache/zip/php7 && Download_src
      src_url=${mirrorLink}/pecl-memcache-php7.tgz && Download_src
      echo "Download pecl memcached for php 7.x..."
      src_url=https://pecl.php.net/get/memcached-${memcached_pecl_php7_version}.tgz && Download_src
    else
      echo "Download pecl memcache for php..."
      src_url=http://pecl.php.net/get/memcache-${memcache_pecl_version}.tgz && Download_src
      echo "Download pecl memcached for php..."
      src_url=http://pecl.php.net/get/memcached-${memcached_pecl_version}.tgz && Download_src
    fi

    echo "Download libmemcached..."
    src_url=https://launchpad.net/libmemcached/1.0/${libmemcached_version}/+download/libmemcached-${libmemcached_version}.tar.gz && Download_src
  fi

  if [[ $Nginx_version =~ ^[1-3]$ ]] || [ "$DB_yn" == 'y' -a "$DB_version" != '10' ]; then
    echo "Download jemalloc..."
    src_url=${mirrorLink}/jemalloc-${jemalloc_version}.tar.bz2 && Download_src
  fi

  # others
  if [ "${downloadDepsSrc}" == '1' ]; then
    if [ "${OS}" == "CentOS" ]; then
      echo "Download tmux for CentOS..."
      src_url=${mirrorLink}/libevent-${libevent_version}.tar.gz && Download_src
      src_url=https://github.com/tmux/tmux/releases/download/${tmux_version}/tmux-${tmux_version}.tar.gz && Download_src

      echo "Download htop for CentOS..."
      src_url=http://hisham.hm/htop/releases/${htop_version}/htop-${htop_version}.tar.gz && Download_src
    fi

    if [[ "${Ubuntu_version}" =~ ^14$|^15$ ]]; then
      echo "Download bison for Ubuntu..."
      src_url=http://ftp.gnu.org/gnu/bison/bison-${bison_version}.tar.gz && Download_src
    fi
  fi

  popd
}
