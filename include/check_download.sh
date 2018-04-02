#!/bin/bash
# Author:  Alpha Eva <kaneawk AT gmail.com>
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

checkDownload() {
  mirrorLink=http://mirrors.linuxeye.com/oneinstack/src
  pushd ${oneinstack_dir}/src > /dev/null
  # General system utils
  echo "Download openSSL..."
  src_url=https://www.openssl.org/source/openssl-${openssl_ver}.tar.gz && Download_src
  echo "Download cacert.pem..."
  src_url=http://curl.haxx.se/ca/cacert.pem && Download_src

  # Web
  if [ "${web_yn}" == 'y' ]; then
    case "${nginx_option}" in
      1)
        echo "Download nginx..."
        src_url=http://nginx.org/download/nginx-${nginx_ver}.tar.gz && Download_src
        ;;
      2)
        echo "Download tengine..."
        src_url=http://tengine.taobao.org/download/tengine-${tengine_ver}.tar.gz && Download_src
        ;;
      3)
        echo "Download openresty..."
        src_url=https://openresty.org/download/openresty-${openresty_ver}.tar.gz && Download_src
        ;;
    esac

    if [[ "${nginx_option}" =~ ^[1-3]$ || ${apache_option} == '1' ]]; then
      echo "Download pcre..."
      src_url=${mirrorLink}/pcre-${pcre_ver}.tar.gz && Download_src
    fi

    # apache
    if [ "${apache_option}" == '1' ]; then
      echo "Download apache 2.4..."
      src_url=http://archive.apache.org/dist/httpd/httpd-${apache24_ver}.tar.gz && Download_src
      src_url=http://archive.apache.org/dist/apr/apr-${apr_ver}.tar.gz && Download_src
      src_url=http://archive.apache.org/dist/apr/apr-util-${apr_util_ver}.tar.gz && Download_src
      src_url=http://mirrors.linuxeye.com/apache/httpd/nghttp2-${nghttp2_ver}.tar.gz && Download_src
    fi
    if [ "${apache_option}" == '2' ]; then
      echo "Download apache 2.2..."
      src_url=http://archive.apache.org/dist/httpd/httpd-${apache22_ver}.tar.gz && Download_src

      echo "Download mod_remoteip.c for apache 2.2..."
      src_url=${mirrorLink}/mod_remoteip.c && Download_src
    fi

    # tomcat
    case "${tomcat_option}" in
      1)
        echo "Download tomcat 9..."
        src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat9_ver}/apache-tomcat-${tomcat9_ver}.tar.gz && Download_src
        src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat9_ver}/catalina-jmx-remote.jar && Download_src
        ;;
      2)
        echo "Download tomcat 8..."
        src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat8_ver}/apache-tomcat-${tomcat8_ver}.tar.gz && Download_src
        src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat8_ver}/catalina-jmx-remote.jar && Download_src
        ;;
      3)
        echo "Download tomcat 7..."
        src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat7_ver}/apache-tomcat-${tomcat7_ver}.tar.gz && Download_src
        src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat7_ver}/catalina-jmx-remote.jar && Download_src
        ;;
      4)
        echo "Download tomcat 6..."
        src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat6_ver}/apache-tomcat-${tomcat6_ver}.tar.gz && Download_src
        src_url=http://mirrors.linuxeye.com/apache/tomcat/v${tomcat6_ver}/catalina-jmx-remote.jar && Download_src
        ;;
    esac

    if [[ "${jdk_option}"  =~ ^[1-4]$ ]]; then
      case "${jdk_option}" in
        1)
          echo "Download JDK 9..."
          JDK_FILE="jdk-${jdk9_ver}_linux-${SYS_BIT_j}_bin.tar.gz"
          ;;
        2)
          echo "Download JDK 1.8..."
          JDK_FILE="jdk-$(echo ${jdk18_ver} | awk -F. '{print $2}')u$(echo ${jdk18_ver} | awk -F_ '{print $NF}')-linux-${SYS_BIT_j}.tar.gz"
          ;;
        3)
          echo "Download JDK 1.7..."
          JDK_FILE="jdk-$(echo ${jdk17_ver} | awk -F. '{print $2}')u$(echo ${jdk17_ver} | awk -F_ '{print $NF}')-linux-${SYS_BIT_j}.tar.gz"
          ;;
        4)
          echo "Download JDK 1.6..."
          JDK_FILE="jdk-$(echo ${jdk16_ver} | awk -F. '{print $2}')u$(echo ${jdk16_ver} | awk -F_ '{print $NF}')-linux-${SYS_BIT_j}.bin"
          ;;
      esac
      src_url=http://mirrors.linuxeye.com/jdk/${JDK_FILE} && Download_src
      echo "Download apr..."
      src_url=http://archive.apache.org/dist/apr/apr-${apr_ver}.tar.gz && Download_src
    fi
  fi

  if [ "${db_yn}" == 'y' ]; then
    if [[ "${db_option}" =~ ^[1,4,8]$ ]] && [ "${dbinstallmethod}" == "2" ]; then
      echo "Download boost..."
      [ "${IPADDR_COUNTRY}"x == "CN"x ] && DOWN_ADDR_BOOST=${mirrorLink} || DOWN_ADDR_BOOST=http://downloads.sourceforge.net/project/boost/boost/${boost_ver}
      boostVersion2=$(echo ${boost_ver} | awk -F. '{print $1}')_$(echo ${boost_ver} | awk -F. '{print $2}')_$(echo ${boost_ver} | awk -F. '{print $3}')
      src_url=${DOWN_ADDR_BOOST}/boost_${boostVersion2}.tar.gz && Download_src
    fi

    case "${db_option}" in
      1)
        # MySQL 5.7
        if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
          DOWN_ADDR_MYSQL=https://mirrors.tuna.tsinghua.edu.cn/mysql/downloads/MySQL-5.7
          DOWN_ADDR_MYSQL_BK=http://mirrors.ustc.edu.cn/mysql-ftp/Downloads/MySQL-5.7
        else
          DOWN_ADDR_MYSQL=http://cdn.mysql.com/Downloads/MySQL-5.7
          DOWN_ADDR_MYSQL_BK=http://mysql.he.net/Downloads/MySQL-5.7
        fi

        if [ "${dbinstallmethod}" == '1' ]; then
          echo "Download MySQL 5.7 binary package..."
          FILE_NAME=mysql-${mysql57_ver}-linux-glibc2.12-${SYS_BIT_b}.tar.gz
        elif [ "${dbinstallmethod}" == '2' ]; then
          echo "Download MySQL 5.7 source package..."
          FILE_NAME=mysql-${mysql57_ver}.tar.gz
        fi
        # start download
        src_url=${DOWN_ADDR_MYSQL}/${FILE_NAME} && Download_src
        src_url=${DOWN_ADDR_MYSQL}/${FILE_NAME}.md5 && Download_src
        # verifying download
        MYSQL_TAR_MD5=$(awk '{print $1}' ${FILE_NAME}.md5)
        [ -z "${MYSQL_TAR_MD5}" ] && MYSQL_TAR_MD5=$(curl -s ${DOWN_ADDR_MYSQL_BK}/${FILE_NAME}.md5 | grep ${FILE_NAME} | awk '{print $1}')
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
        if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
          DOWN_ADDR_MYSQL=https://mirrors.tuna.tsinghua.edu.cn/mysql/downloads/MySQL-5.6
          DOWN_ADDR_MYSQL_BK=http://mirrors.ustc.edu.cn/mysql-ftp/Downloads/MySQL-5.6
        else
          DOWN_ADDR_MYSQL=http://cdn.mysql.com/Downloads/MySQL-5.6
          DOWN_ADDR_MYSQL_BK=http://mysql.he.net/Downloads/MySQL-5.6
        fi

        if [ "${dbinstallmethod}" == '1' ]; then
          echo "Download MySQL 5.6 binary package..."
          FILE_NAME=mysql-${mysql56_ver}-linux-glibc2.12-${SYS_BIT_b}.tar.gz
        elif [ "${dbinstallmethod}" == '2' ]; then
          echo "Download MySQL 5.6 source package..."
          FILE_NAME=mysql-${mysql56_ver}.tar.gz
        fi
        # start download
        src_url=${DOWN_ADDR_MYSQL}/${FILE_NAME} && Download_src
        src_url=${DOWN_ADDR_MYSQL}/${FILE_NAME}.md5 && Download_src
        # verifying download
        MYSQL_TAR_MD5=$(awk '{print $1}' ${FILE_NAME}.md5)
        [ -z "${MYSQL_TAR_MD5}" ] && MYSQL_TAR_MD5=$(curl -s ${DOWN_ADDR_MYSQL_BK}/${FILE_NAME}.md5 | grep ${FILE_NAME} | awk '{print $1}')
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
        if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
          DOWN_ADDR_MYSQL=https://mirrors.tuna.tsinghua.edu.cn/mysql/downloads/MySQL-5.5
          DOWN_ADDR_MYSQL_BK=http://mirrors.ustc.edu.cn/mysql-ftp/Downloads/MySQL-5.5
        else
          DOWN_ADDR_MYSQL=http://cdn.mysql.com/Downloads/MySQL-5.5
          DOWN_ADDR_MYSQL_BK=http://mysql.he.net/Downloads/MySQL-5.5
        fi

        if [ "${dbinstallmethod}" == '1' ]; then
          echo "Download MySQL 5.5 binary package..."
          FILE_NAME=mysql-${mysql55_ver}-linux-glibc2.12-${SYS_BIT_b}.tar.gz
        elif [ "${dbinstallmethod}" == '2' ]; then
          echo "Download MySQL 5.5 source package..."
          FILE_NAME=mysql-${mysql55_ver}.tar.gz
          src_url=${mirrorLink}/mysql-5.5-fix-arm-client_plugin.patch && Download_src
        fi
        # start download
        src_url=${DOWN_ADDR_MYSQL}/${FILE_NAME} && Download_src
        src_url=${DOWN_ADDR_MYSQL}/${FILE_NAME}.md5 && Download_src
        # verifying download
        MYSQL_TAR_MD5=$(awk '{print $1}' ${FILE_NAME}.md5)
        [ -z "${MYSQL_TAR_MD5}" ] && MYSQL_TAR_MD5=$(curl -s ${DOWN_ADDR_MYSQL_BK}/${FILE_NAME}.md5 | grep ${FILE_NAME} | awk '{print $1}')
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
        if [ "${dbinstallmethod}" == '1' ]; then
          echo "Download MariaDB 10.2 binary package..."
          FILE_NAME=mariadb-${mariadb102_ver}-${GLIBC_FLAG}-${SYS_BIT_b}.tar.gz
          if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
            DOWN_ADDR_MARIADB=https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-${mariadb102_ver}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
            DOWN_ADDR_MARIADB_BK=https://mirrors.ustc.edu.cn/mariadb/mariadb-${mariadb102_ver}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
          else
            DOWN_ADDR_MARIADB=http://ftp.osuosl.org/pub/mariadb/mariadb-${mariadb102_ver}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
            DOWN_ADDR_MARIADB_BK=http://mirror.nodesdirect.com/mariadb/mariadb-${mariadb102_ver}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
          fi
        elif [ "${dbinstallmethod}" == '2' ]; then
          echo "Download MariaDB 10.2 source package..."
          FILE_NAME=mariadb-${mariadb102_ver}.tar.gz
          if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
            DOWN_ADDR_MARIADB=https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-${mariadb102_ver}/source
            DOWN_ADDR_MARIADB_BK=https://mirrors.ustc.edu.cn/mariadb/mariadb-${mariadb102_ver}/source
          else
            DOWN_ADDR_MARIADB=http://ftp.osuosl.org/pub/mariadb/mariadb-${mariadb102_ver}/source
            DOWN_ADDR_MARIADB_BK=http://mirror.nodesdirect.com/mariadb/mariadb-${mariadb102_ver}/source
          fi
        fi
        src_url=${DOWN_ADDR_MARIADB}/${FILE_NAME} && Download_src
        wget -4 --tries=6 -c --no-check-certificate ${DOWN_ADDR_MARIADB}/md5sums.txt -O ${FILE_NAME}.md5
        MARAIDB_TAR_MD5=$(awk '{print $1}' ${FILE_NAME}.md5)
        [ -z "${MARAIDB_TAR_MD5}" ] && MARAIDB_TAR_MD5=$(curl -s ${DOWN_ADDR_MARIADB_BK}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}')
        tryDlCount=0
        while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${MARAIDB_TAR_MD5}" ]; do
          wget -c --no-check-certificate ${DOWN_ADDR_MARIADB_BK}/${FILE_NAME};sleep 1
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
        if [ "${dbinstallmethod}" == '1' ]; then
          echo "Download MariaDB 10.1 binary package..."
          FILE_NAME=mariadb-${mariadb101_ver}-${GLIBC_FLAG}-${SYS_BIT_b}.tar.gz
          if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
            DOWN_ADDR_MARIADB=https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-${mariadb101_ver}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
            DOWN_ADDR_MARIADB_BK=https://mirrors.ustc.edu.cn/mariadb/mariadb-${mariadb101_ver}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
          else
            DOWN_ADDR_MARIADB=http://ftp.osuosl.org/pub/mariadb/mariadb-${mariadb101_ver}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
            DOWN_ADDR_MARIADB_BK=http://mirror.nodesdirect.com/mariadb/mariadb-${mariadb101_ver}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
          fi
        elif [ "${dbinstallmethod}" == '2' ]; then
          echo "Download MariaDB 10.1 source package..."
          FILE_NAME=mariadb-${mariadb101_ver}.tar.gz
          if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
            DOWN_ADDR_MARIADB=https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-${mariadb101_ver}/source
            DOWN_ADDR_MARIADB_BK=https://mirrors.ustc.edu.cn/mariadb/mariadb-${mariadb101_ver}/source
          else
            DOWN_ADDR_MARIADB=http://ftp.osuosl.org/pub/mariadb/mariadb-${mariadb101_ver}/source
            DOWN_ADDR_MARIADB_BK=http://mirror.nodesdirect.com/mariadb/mariadb-${mariadb101_ver}/source
          fi
        fi
        src_url=${DOWN_ADDR_MARIADB}/${FILE_NAME} && Download_src
        wget -4 --tries=6 -c --no-check-certificate ${DOWN_ADDR_MARIADB}/md5sums.txt -O ${FILE_NAME}.md5
        MARAIDB_TAR_MD5=$(awk '{print $1}' ${FILE_NAME}.md5)
        [ -z "${MARAIDB_TAR_MD5}" ] && MARAIDB_TAR_MD5=$(curl -s ${DOWN_ADDR_MARIADB_BK}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}')
        tryDlCount=0
        while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${MARAIDB_TAR_MD5}" ]; do
          wget -c --no-check-certificate ${DOWN_ADDR_MARIADB_BK}/${FILE_NAME};sleep 1
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
        if [ "${dbinstallmethod}" == '1' ]; then
          echo "Download MariaDB 10.0 binary package..."
          FILE_NAME=mariadb-${mariadb100_ver}-${GLIBC_FLAG}-${SYS_BIT_b}.tar.gz
          if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
            DOWN_ADDR_MARIADB=https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-${mariadb100_ver}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
            DOWN_ADDR_MARIADB_BK=https://mirrors.ustc.edu.cn/mariadb/mariadb-${mariadb100_ver}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
          else
            DOWN_ADDR_MARIADB=http://ftp.osuosl.org/pub/mariadb/mariadb-${mariadb100_ver}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
            DOWN_ADDR_MARIADB_BK=http://mirror.nodesdirect.com/mariadb/mariadb-${mariadb100_ver}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
          fi
        elif [ "${dbinstallmethod}" == '2' ]; then
          echo "Download MariaDB 10.0 source package..."
          FILE_NAME=mariadb-${mariadb100_ver}.tar.gz
          if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
            DOWN_ADDR_MARIADB=https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-${mariadb100_ver}/source
            DOWN_ADDR_MARIADB_BK=https://mirrors.ustc.edu.cn/mariadb/mariadb-${mariadb100_ver}/source
          else
            DOWN_ADDR_MARIADB=http://ftp.osuosl.org/pub/mariadb/mariadb-${mariadb100_ver}/source
            DOWN_ADDR_MARIADB_BK=http://mirror.nodesdirect.com/mariadb/mariadb-${mariadb100_ver}/source
          fi
        fi
        src_url=${DOWN_ADDR_MARIADB}/${FILE_NAME} && Download_src
        wget -4 --tries=6 -c --no-check-certificate ${DOWN_ADDR_MARIADB}/md5sums.txt -O ${FILE_NAME}.md5
        MARAIDB_TAR_MD5=$(awk '{print $1}' ${FILE_NAME}.md5)
        [ -z "${MARAIDB_TAR_MD5}" ] && MARAIDB_TAR_MD5=$(curl -s ${DOWN_ADDR_MARIADB_BK}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}')
        tryDlCount=0
        while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${MARAIDB_TAR_MD5}" ]; do
          wget -c --no-check-certificate ${DOWN_ADDR_MARIADB_BK}/${FILE_NAME};sleep 1
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
        if [ "${dbinstallmethod}" == '1' ]; then
          echo "Download MariaDB 5.5 binary package..."
          FILE_NAME=mariadb-${mariadb55_ver}-${GLIBC_FLAG}-${SYS_BIT_b}.tar.gz
          if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
            DOWN_ADDR_MARIADB=https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-${mariadb55_ver}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
            DOWN_ADDR_MARIADB_BK=https://mirrors.ustc.edu.cn/mariadb/mariadb-${mariadb55_ver}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
          else
            DOWN_ADDR_MARIADB=http://ftp.osuosl.org/pub/mariadb/mariadb-${mariadb55_ver}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
            DOWN_ADDR_MARIADB_BK=http://mirror.nodesdirect.com/mariadb/mariadb-${mariadb55_ver}/bintar-${GLIBC_FLAG}-${SYS_BIT_a}
          fi
        elif [ "${dbinstallmethod}" == '2' ]; then
          echo "Download MariaDB 5.5 source package..."
          FILE_NAME=mariadb-${mariadb55_ver}.tar.gz
          if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
            DOWN_ADDR_MARIADB=https://mirrors.tuna.tsinghua.edu.cn/mariadb/mariadb-${mariadb55_ver}/source
            DOWN_ADDR_MARIADB_BK=https://mirrors.ustc.edu.cn/mariadb/mariadb-${mariadb55_ver}/source
          else
            DOWN_ADDR_MARIADB=http://ftp.osuosl.org/pub/mariadb/mariadb-${mariadb55_ver}/source
            DOWN_ADDR_MARIADB_BK=http://mirror.nodesdirect.com/mariadb/mariadb-${mariadb55_ver}/source
          fi
        fi
        src_url=${DOWN_ADDR_MARIADB}/${FILE_NAME} && Download_src
        wget -4 --tries=6 -c --no-check-certificate ${DOWN_ADDR_MARIADB}/md5sums.txt -O ${FILE_NAME}.md5
        MARAIDB_TAR_MD5=$(awk '{print $1}' ${FILE_NAME}.md5)
        [ -z "${MARAIDB_TAR_MD5}" ] && MARAIDB_TAR_MD5=$(curl -s ${DOWN_ADDR_MARIADB_BK}/md5sums.txt | grep ${FILE_NAME} | awk '{print $1}')
        tryDlCount=0
        while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${MARAIDB_TAR_MD5}" ]; do
          wget -c --no-check-certificate ${DOWN_ADDR_MARIADB_BK}/${FILE_NAME};sleep 1
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
        if [ "${dbinstallmethod}" == '1' ]; then
          echo "Download Percona 5.7 binary package..."
          FILE_NAME=Percona-Server-${percona57_ver}-Linux.${SYS_BIT_b}.${sslLibVer}.tar.gz
          DOWN_ADDR_PERCONA=https://www.percona.com/downloads/Percona-Server-5.7/Percona-Server-${percona57_ver}/binary/tarball
        elif [ "${dbinstallmethod}" == '2' ]; then
          echo "Download Percona 5.7 source package..."
          FILE_NAME=percona-server-${percona57_ver}.tar.gz
          if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
            DOWN_ADDR_PERCONA=${mirrorLink}
          else
            DOWN_ADDR_PERCONA=https://www.percona.com/downloads/Percona-Server-5.7/Percona-Server-${percona57_ver}/source/tarball
          fi
        fi
        # start download
        src_url=${DOWN_ADDR_PERCONA}/${FILE_NAME} && Download_src
        src_url=${DOWN_ADDR_PERCONA}/${FILE_NAME}.md5sum && Download_src
        # verifying download
        PERCONA_TAR_MD5=$(awk '{print $1}' ${FILE_NAME}.md5sum)
        [ -z "${PERCONA_TAR_MD5}" ] && PERCONA_TAR_MD5=$(curl -s ${DOWN_ADDR_PERCONA}/${FILE_NAME}.md5sum |  grep ${FILE_NAME} | awk '{print $1}')
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
        if [ "${dbinstallmethod}" == '1' ]; then
          echo "Download Percona 5.6 binary package..."
          perconaVerStr1=$(echo ${percona56_ver} | sed "s@-@-rel@")
          FILE_NAME=Percona-Server-${perconaVerStr1}-Linux.${SYS_BIT_b}.${sslLibVer}.tar.gz
          DOWN_ADDR_PERCONA=https://www.percona.com/downloads/Percona-Server-5.6/Percona-Server-${percona56_ver}/binary/tarball
        elif [ "${dbinstallmethod}" == '2' ]; then
          echo "Download Percona 5.6 source package..."
          FILE_NAME=percona-server-${percona56_ver}.tar.gz
          if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
            DOWN_ADDR_PERCONA=${mirrorLink}
          else
            DOWN_ADDR_PERCONA=https://www.percona.com/downloads/Percona-Server-5.6/Percona-Server-${percona56_ver}/source/tarball
          fi
        fi
        # start download
        src_url=${DOWN_ADDR_PERCONA}/${FILE_NAME} && Download_src
        src_url=${DOWN_ADDR_PERCONA}/${FILE_NAME}.md5sum && Download_src
        # verifying download
        PERCONA_TAR_MD5=$(awk '{print $1}' ${FILE_NAME}.md5sum)
        [ -z "${PERCONA_TAR_MD5}" ] && PERCONA_TAR_MD5=$(curl -s ${DOWN_ADDR_PERCONA}/${FILE_NAME}.md5sum |  grep ${FILE_NAME} | awk '{print $1}')
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
        if [ "${dbinstallmethod}" == '1' ]; then
          echo "Download Percona 5.5 binary package..."
          perconaVerStr1=$(echo ${percona55_ver} | sed "s@-@-rel@")
          FILE_NAME=Percona-Server-${perconaVerStr1}-Linux.${SYS_BIT_b}.${sslLibVer}.tar.gz
          DOWN_ADDR_PERCONA=https://www.percona.com/downloads/Percona-Server-5.5/Percona-Server-${percona55_ver}/binary/tarball
        elif [ "${dbinstallmethod}" == '2' ]; then
          echo "Download Percona 5.5 source package..."
          FILE_NAME=percona-server-${percona55_ver}.tar.gz
          if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
            DOWN_ADDR_PERCONA=${mirrorLink}
          else
            DOWN_ADDR_PERCONA=https://www.percona.com/downloads/Percona-Server-5.5/Percona-Server-${percona55_ver}/source/tarball
          fi
        fi
        # start download
        src_url=${DOWN_ADDR_PERCONA}/${FILE_NAME} && Download_src
        src_url=${DOWN_ADDR_PERCONA}/${FILE_NAME}.md5sum && Download_src
        # verifying download
        PERCONA_TAR_MD5=$(awk '{print $1}' ${FILE_NAME}.md5sum)
        [ -z "${PERCONA_TAR_MD5}" ] && PERCONA_TAR_MD5=$(curl -s ${DOWN_ADDR_PERCONA}/${FILE_NAME}.md5sum |  grep ${FILE_NAME} | awk '{print $1}')
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
        FILE_NAME=alisql-${alisql_ver}.tar.gz
        src_url=${DOWN_ADDR_ALISQL}/${FILE_NAME} && Download_src
        src_url=${DOWN_ADDR_ALISQL}/${FILE_NAME}.md5 && Download_src
        ALISQL_TAR_MD5=$(awk '{print $1}' ${FILE_NAME}.md5)
        while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${ALISQL_TAR_MD5}" ];do
          wget -4c --no-check-certificate ${DOWN_ADDR_ALISQL}/${FILE_NAME};sleep 1
          [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${ALISQL_TAR_MD5}" ] && break || continue
        done
        ;;
      12)
        # PostgreSQL
        echo "Download PostgreSQL source package..."
        FILE_NAME=postgresql-${pgsql_ver}.tar.gz
        if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
          DOWN_ADDR_PGSQL=https://mirrors.tuna.tsinghua.edu.cn/postgresql/source/v${pgsql_ver}
          DOWN_ADDR_PGSQL_BK=https://mirrors.ustc.edu.cn/postgresql/source/v${pgsql_ver}
        else
          DOWN_ADDR_PGSQL=https://ftp.postgresql.org/pub/source/v${pgsql_ver}
          DOWN_ADDR_PGSQL_BK=https://ftp.heanet.ie/mirrors/postgresql/source/v${pgsql_ver}
        fi
        src_url=${DOWN_ADDR_PGSQL}/${FILE_NAME} && Download_src
        src_url=${DOWN_ADDR_PGSQL}/${FILE_NAME}.md5 && Download_src
        PGSQL_TAR_MD5=$(awk '{print $1}' ${FILE_NAME}.md5)
        [ -z "${PGSQL_TAR_MD5}" ] && PGSQL_TAR_MD5=$(curl -s ${DOWN_ADDR_PGSQL_BK}/${FILE_NAME}.md5 | grep ${FILE_NAME} | awk '{print $1}')
        tryDlCount=0
        while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${PGSQL_TAR_MD5}" ]; do
          wget -c --no-check-certificate ${DOWN_ADDR_PGSQL_BK}/${FILE_NAME};sleep 1
          let "tryDlCount++"
          [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${PGSQL_TAR_MD5}" -o "${tryDlCount}" == '6' ] && break || continue
        done
        if [ "${tryDlCount}" == '6' ]; then
          echo "${CFAILURE}${FILE_NAME} download failed, Please contact the author! ${CEND}"
          kill -9 $$
        else
          echo "[${CMSG}${FILE_NAME}${CEND}] found."
        fi
        ;;
      13)
        # MongoDB
        echo "Download MongoDB binary package..."
        FILE_NAME=mongodb-linux-${SYS_BIT_b}-${mongodb_ver}.tgz
        if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
          DOWN_ADDR_MongoDB=${mirrorLink}
        else
          DOWN_ADDR_MongoDB=https://fastdl.mongodb.org/linux
        fi
        src_url=${DOWN_ADDR_MongoDB}/${FILE_NAME} && Download_src
        src_url=${DOWN_ADDR_MongoDB}/${FILE_NAME}.md5 && Download_src
        MongoDB_TAR_MD5=$(awk '{print $1}' ${FILE_NAME}.md5)
        [ -z "${MongoDB_TAR_MD5}" ] && MongoDB_TAR_MD5=$(curl -s ${DOWN_ADDR_MongoDB}/${FILE_NAME}.md5 | grep ${FILE_NAME} | awk '{print $1}')
        tryDlCount=0
        while [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" != "${MongoDB_TAR_MD5}" ]; do
          wget -c --no-check-certificate ${DOWN_ADDR_MongoDB}/${FILE_NAME};sleep 1
          let "tryDlCount++"
          [ "$(md5sum ${FILE_NAME} | awk '{print $1}')" == "${MongoDB_TAR_MD5}" -o "${tryDlCount}" == '6' ] && break || continue
        done
        if [ "${tryDlCount}" == '6' ]; then
          echo "${CFAILURE}${FILE_NAME} download failed, Please contact the author! ${CEND}"
          kill -9 $$
        else
          echo "[${CMSG}${FILE_NAME}${CEND}] found."
        fi
        ;;
    esac
  fi
  # PHP
  if [ "${php_yn}" == 'y' ]; then
    # php 5.3 5.4 5.5 5.6 5.7
    echo "PHP common..."
    src_url=http://ftp.gnu.org/pub/gnu/libiconv/libiconv-${libiconv_ver}.tar.gz && Download_src
    src_url=https://curl.haxx.se/download/curl-${curl_ver}.tar.gz && Download_src
    src_url=http://downloads.sourceforge.net/project/mcrypt/Libmcrypt/${libmcrypt_ver}/libmcrypt-${libmcrypt_ver}.tar.gz && Download_src
    src_url=http://downloads.sourceforge.net/project/mhash/mhash/${mhash_ver}/mhash-${mhash_ver}.tar.gz && Download_src
    src_url=http://downloads.sourceforge.net/project/mcrypt/MCrypt/${mcrypt_ver}/mcrypt-${mcrypt_ver}.tar.gz && Download_src
    src_url=${mirrorLink}/libiconv-glibc-2.16.patch && Download_src

    case "${php_option}" in
      1)
        # php 5.3
        src_url=${mirrorLink}/debian_patches_disable_SSLv2_for_openssl_1_0_0.patch && Download_src
        src_url=${mirrorLink}/php5.3patch && Download_src
        src_url=http://www.php.net/distributions/php-${php53_ver}.tar.gz && Download_src
        src_url=${mirrorLink}/fpm-race-condition.patch && Download_src
        ;;
      2)
        src_url=http://www.php.net/distributions/php-${php54_ver}.tar.gz && Download_src
        src_url=${mirrorLink}/fpm-race-condition.patch && Download_src
        ;;
      3)
        src_url=http://www.php.net/distributions/php-${php55_ver}.tar.gz && Download_src
        src_url=${mirrorLink}/fpm-race-condition.patch && Download_src
        ;;
      4)
        src_url=http://www.php.net/distributions/php-${php56_ver}.tar.gz && Download_src
        ;;
      5)
        src_url=http://www.php.net/distributions/php-${php70_ver}.tar.gz && Download_src
        ;;
      6)
        src_url=http://www.php.net/distributions/php-${php71_ver}.tar.gz && Download_src
        ;;
      7)
        src_url=http://www.php.net/distributions/php-${php72_ver}.tar.gz && Download_src
        src_url=http://mirrors.linuxeye.com/oneinstack/src/argon2-${argon2_ver}.tar.gz && Download_src
        src_url=http://mirrors.linuxeye.com/oneinstack/src/libsodium-${libsodium_ver}.tar.gz && Download_src
        ;;
    esac
  fi

  # PHP OPCache
  case "${phpcache_option}" in
    1)
      if [[ "${php_option}" =~ ^[1-2]$ ]]; then
        # php 5.3 5.4
        echo "Download Zend OPCache..."
        src_url=https://pecl.php.net/get/zendopcache-${zendopcache_ver}.tgz && Download_src
      fi
      ;;
    2)
      if [[ "${php_option}" =~ ^[1-4]$ ]]; then
        # php 5.3 5.4 5.5 5.6
        echo "Download xcache..."
        src_url=http://xcache.lighttpd.net/pub/Releases/${xcache_ver}/xcache-${xcache_ver}.tar.gz && Download_src
      fi
      ;;
    3)
      # php 5.3 5.4 5.5 5.6 7.0 7.1 7.2
      echo "Download apcu..."
      if [[ "${php_option}" =~ ^[1-4]$ ]]; then
        src_url=https://pecl.php.net/get/apcu-${apcu_ver}.tgz && Download_src
      else
        src_url=https://pecl.php.net/get/apcu-${apcu_for_php7_ver}.tgz && Download_src
      fi
      ;;
    4)
      # php 5.3 5.4
      if [ "${php_option}" == '1' ]; then
        echo "Download eaccelerator 0.9..."
        src_url=https://github.com/downloads/eaccelerator/eaccelerator/eaccelerator-${eaccelerator_ver}.tar.bz2 && Download_src
      elif [ "${php_option}" == '2' ]; then
        echo "Download eaccelerator 1.0 dev..."
        src_url=https://github.com/eaccelerator/eaccelerator/tarball/master && Download_src
      fi
      ;;
  esac

  # Zend Guard Loader
  if [ "${zendguardloader_yn}" == 'y' -a "${armplatform}" != 'y' ]; then
    case "${php_option}" in
      4)
        echo "Download zend loader for php 5.6..."
        src_url=${mirrorLink}/zend-loader-php5.6-linux-${SYS_BIT_c}.tar.gz && Download_src
        ;;
      3)
        echo "Download zend loader for php 5.5..."
        src_url=${mirrorLink}/zend-loader-php5.5-linux-${SYS_BIT_c}.tar.gz && Download_src
        ;;
      2)
        echo "Download zend loader for php 5.4..."
        src_url=${mirrorLink}/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-${SYS_BIT_c}.tar.gz && Download_src
        ;;
      1)
        echo "Download zend loader for php 5.3..."
        src_url=${mirrorLink}/ZendGuardLoader-php-5.3-linux-glibc23-${SYS_BIT_c}.tar.gz && Download_src
        ;;
    esac
  fi

  if [ "${db_option}" == '13' ]; then
    if [[ "${php_option}" =~ ^[1-2]$ ]]; then
      echo "Download pecl mongo for php..."
      src_url=https://pecl.php.net/get/mongo-${mongo_pecl_ver}.tgz && Download_src
    else
      echo "Download pecl mongodb for php..."
      src_url=https://pecl.php.net/get/mongodb-${mongodb_pecl_ver}.tgz && Download_src
    fi
  fi

  if [ "${ioncube_yn}" == 'y' ]; then
    echo "Download ioncube..."
    if [ "${TARGET_ARCH}" == "armv7" ]; then
      src_url=https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_armv7l.tar.gz && Download_src
    else
      src_url=https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_${SYS_BIT_d}.tar.gz && Download_src
    fi
  fi

  if [ "${magick_yn}" == 'y' ]; then
    if [ "${magick_option}" == '1' ]; then
      echo "Download ImageMagick..."
      src_url=${mirrorLink}/ImageMagick-${imagemagick_ver}.tar.gz && Download_src
      echo "Download imagick..."
      src_url=https://pecl.php.net/get/imagick-${imagick_ver}.tgz && Download_src
    else
      echo "Download graphicsmagick..."
      src_url=http://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick/${graphicsmagick_ver}/GraphicsMagick-${graphicsmagick_ver}.tar.gz && Download_src
      if [[ "${php_option}" =~ ^[5-7]$ ]]; then
        echo "Download gmagick for php 7.x..."
        src_url=https://pecl.php.net/get/gmagick-${gmagick_for_php7_ver}.tgz && Download_src
      else
        echo "Download gmagick for php..."
        src_url=https://pecl.php.net/get/gmagick-${gmagick_ver}.tgz && Download_src
      fi
    fi
  fi

  if [ "${ftp_yn}" == 'y' ]; then
    echo "Download pureftpd..."
    src_url=https://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-${pureftpd_ver}.tar.gz && Download_src
  fi

  if [ "${phpmyadmin_yn}" == 'y' ]; then
    echo "Download phpMyAdmin..."
    src_url=https://files.phpmyadmin.net/phpMyAdmin/${phpmyadmin_ver}/phpMyAdmin-${phpmyadmin_ver}-all-languages.tar.gz && Download_src
  fi

  if [ "${redis_yn}" == 'y' ]; then
    echo "Download redis..."
    src_url=http://download.redis.io/releases/redis-${redis_ver}.tar.gz && Download_src
    echo "Download redis pecl..."
    src_url=https://pecl.php.net/get/redis-${redis_pecl_ver}.tgz && Download_src
    if [ "${OS}" == "CentOS" ]; then
      echo "Download start-stop-daemon.c for CentOS..."
      src_url=${mirrorLink}/start-stop-daemon.c && Download_src
    fi
  fi

  if [ "${memcached_yn}" == 'y' ]; then
    echo "Download memcached..."
    [ "$IPADDR_COUNTRY"x == "CN"x ] && DOWN_ADDR=${mirrorLink} || DOWN_ADDR=http://www.memcached.org/files
    src_url=${DOWN_ADDR}/memcached-${memcached_ver}.tar.gz && Download_src
    if [[ "${php_option}" =~ ^[5-7]$ ]]; then
      echo "Download pecl memcache for php 7.x..."
      # src_url=https://codeload.github.com/websupport-sk/pecl-memcache/zip/php7 && Download_src
      src_url=${mirrorLink}/pecl-memcache-php7.tgz && Download_src
      echo "Download pecl memcached for php 7.x..."
      src_url=https://pecl.php.net/get/memcached-${memcached_pecl_php7_ver}.tgz && Download_src
    else
      echo "Download pecl memcache for php..."
      src_url=https://pecl.php.net/get/memcache-${memcache_pecl_ver}.tgz && Download_src
      echo "Download pecl memcached for php..."
      src_url=https://pecl.php.net/get/memcached-${memcached_pecl_ver}.tgz && Download_src
    fi

    echo "Download libmemcached..."
    src_url=https://launchpad.net/libmemcached/1.0/${libmemcached_ver}/+download/libmemcached-${libmemcached_ver}.tar.gz && Download_src
  fi

  if [[ ${nginx_option} =~ ^[1-3]$ ]] || [ "$db_yn" == 'y' -a "${db_option}" != '10' ]; then
    echo "Download jemalloc..."
    src_url=${mirrorLink}/jemalloc-${jemalloc_ver}.tar.bz2 && Download_src
  fi

  # others
  if [ "${downloadDepsSrc}" == '1' ]; then
    if [ "${OS}" == "CentOS" ]; then
      echo "Download tmux for CentOS..."
      src_url=${mirrorLink}/libevent-${libevent_ver}.tar.gz && Download_src
      src_url=https://github.com/tmux/tmux/releases/download/${tmux_ver}/tmux-${tmux_ver}.tar.gz && Download_src

      echo "Download htop for CentOS..."
      src_url=http://hisham.hm/htop/releases/${htop_ver}/htop-${htop_ver}.tar.gz && Download_src
    fi

    if [[ "${Ubuntu_ver}" =~ ^14$|^15$ ]]; then
      echo "Download bison for Ubuntu..."
      src_url=http://ftp.gnu.org/gnu/bison/bison-${bison_ver}.tar.gz && Download_src
    fi
  fi

  popd
}
