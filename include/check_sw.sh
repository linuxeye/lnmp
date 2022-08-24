#!/bin/bash
# Author:  Alpha Eva <kaneawk AT gmail.com>
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

installDepsDebian() {
  echo "${CMSG}Removing the conflicting packages...${CEND}"
  if [ "${apache_flag}" == 'y' ]; then
    killall apache2
    pkgList="apache2 apache2-doc apache2-utils apache2.2-common apache2.2-bin apache2-mpm-prefork apache2-doc apache2-mpm-worker php5 php5-common php5-cgi php5-cli php5-mysql php5-curl php5-gd"
    for Package in ${pkgList};do
      apt-get -y purge ${Package}
    done
    dpkg -l | grep ^rc | awk '{print $2}' | xargs dpkg -P
  fi

  if [[ "${db_option}" =~ ^[1-9]$|^1[0-2]$ ]]; then
    pkgList="mysql-client mysql-server mysql-common mysql-server-core-5.5 mysql-client-5.5 mariadb-client mariadb-server mariadb-common"
    for Package in ${pkgList};do
      apt-get -y purge ${Package}
    done
    dpkg -l | grep ^rc | awk '{print $2}' | xargs dpkg -P
  fi

  echo "${CMSG}Installing dependencies packages...${CEND}"
  apt-get -y update
  apt-get -y autoremove
  apt-get -yf install
  export DEBIAN_FRONTEND=noninteractive

  # critical security updates
  grep security /etc/apt/sources.list > /tmp/security.sources.list
  apt-get -y upgrade -o Dir::Etc::SourceList=/tmp/security.sources.list

  # Install needed packages
  case "${Debian_ver}" in
    8)
      pkgList="debian-keyring debian-archive-keyring build-essential gcc g++ make cmake autoconf libjpeg8 libjpeg62-turbo-dev libjpeg-dev libpng12-0 libpng12-dev libpng3 libgd-dev libxml2 libxml2-dev zlib1g zlib1g-dev libc6 libc6-dev libc-client2007e-dev libglib2.0-0 libglib2.0-dev bzip2 libzip-dev libbz2-1.0 libncurses5 libncurses5-dev libaio1 libaio-dev numactl libreadline-dev curl libcurl3-gnutls libcurl4-openssl-dev e2fsprogs libkrb5-3 libkrb5-dev libltdl-dev libidn11 libidn11-dev openssl net-tools libssl-dev libtool libevent-dev bison re2c libsasl2-dev libxslt1-dev libxslt-dev libicu-dev locales libcloog-ppl0 patch vim zip unzip tmux htop bc dc expect libexpat1-dev libonig-dev libtirpc-dev nss rsync git lsof lrzsz iptables rsyslog cron logrotate chrony ntpdate libsqlite3-dev psmisc wget sysv-rc apt-transport-https ca-certificates software-properties-common"
      ;;
    9|10|11)
      pkgList="debian-keyring debian-archive-keyring build-essential gcc g++ make cmake autoconf libjpeg62-turbo-dev libjpeg-dev libpng-dev libgd-dev libxml2 libxml2-dev zlib1g zlib1g-dev libc6 libc6-dev libc-client2007e-dev libglib2.0-0 libglib2.0-dev bzip2 libzip-dev libbz2-1.0 libncurses5 libncurses5-dev libaio1 libaio-dev numactl libreadline-dev curl libcurl3-gnutls libcurl4-openssl-dev e2fsprogs libkrb5-3 libkrb5-dev libltdl-dev libidn11 libidn11-dev openssl net-tools libssl-dev libtool libevent-dev bison re2c libsasl2-dev libxslt1-dev libicu-dev locales patch vim zip unzip tmux htop bc dc expect libexpat1-dev libonig-dev libtirpc-dev rsync git lsof lrzsz iptables rsyslog cron logrotate chrony ntpdate libsqlite3-dev psmisc wget sysv-rc apt-transport-https ca-certificates software-properties-common"
      ;;
    *)
      echo "${CFAILURE}Your system Debian ${Debian_ver} are not supported!${CEND}"
      kill -9 $$; exit 1;
      ;;
  esac
  for Package in ${pkgList}; do
    apt-get --no-install-recommends -y install ${Package}
  done
}

installDepsRHEL() {
  [ -e '/etc/yum.conf' ] && sed -i 's@^exclude@#exclude@' /etc/yum.conf
  if [ "${RHEL_ver}" == '8' ]; then
    if [[ "${Platform}" =~ "RedHat" ]]; then
      subscription-manager repos --enable codeready-builder-for-rhel-8-${ARCH}-rpms
      dnf -y install chrony oniguruma-devel rpcgen
    elif [[ "${Platform}" =~ "Oracle" ]]; then
      dnf config-manager --set-enabled ol8_codeready_builder
      dnf -y install chrony oniguruma-devel rpcgen
    else
      [ -z "`grep -w epel /etc/yum.repos.d/*.repo`" ] && yum -y install epel-release
      if grep -qw "^\[PowerTools\]" /etc/yum.repos.d/*.repo; then
        dnf -y --enablerepo=PowerTools install chrony oniguruma-devel rpcgen
      else
        dnf -y --enablerepo=powertools install chrony oniguruma-devel rpcgen
      fi
    fi
    systemctl enable chronyd
    systemctl stop firewalld && systemctl mask firewalld.service
  elif [ "${RHEL_ver}" == '7' ]; then
    [ -z "`grep -w epel /etc/yum.repos.d/*.repo`" ] && yum -y install epel-release
    yum -y groupremove "Basic Web Server" "MySQL Database server" "MySQL Database client"
    systemctl stop firewalld && systemctl mask firewalld.service
  fi
  [ "${RHEL_ver}" == '9' ] && dnf -y --enablerepo=crb install chrony oniguruma-devel rpcgen

  if [ ${RHEL_ver} -ge 7 >/dev/null 2>&1 ] && [ "${iptables_flag}" == 'y' ]; then
    yum -y install iptables-services
    systemctl enable iptables.service
    systemctl enable ip6tables.service
  fi

  echo "${CMSG}Installing dependencies packages...${CEND}"
  # Install needed packages
  pkgList="deltarpm drpm gcc gcc-c++ make cmake autoconf libjpeg libjpeg-devel libjpeg-turbo libjpeg-turbo-devel libpng libpng-devel libxml2 libxml2-devel zlib zlib-devel libzip libzip-devel glibc glibc-devel krb5-devel libc-client libc-client-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel libaio numactl numactl-libs readline-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssl-devel net-tools libxslt-devel libicu-devel libevent-devel libtool libtool-ltdl bison gd-devel vim-enhanced pcre-devel libmcrypt libmcrypt-devel mhash mhash-devel mcrypt zip unzip chrony ntpdate sqlite-devel sysstat patch bc expect expat-devel perl-devel oniguruma oniguruma-devel libtirpc-devel nss libnsl rsync rsyslog git lsof lrzsz psmisc wget which libatomic tmux chkconfig"
  for Package in ${pkgList}; do
    yum -y install ${Package}
  done
  [ ${RHEL_ver} -lt 8 >/dev/null 2>&1 ] && yum -y install cmake3

  yum -y update bash openssl glibc
}

installDepsUbuntu() {
  # Uninstall the conflicting software
  echo "${CMSG}Removing the conflicting packages...${CEND}"
  if [ "${apache_flag}" == 'y' ]; then
    killall apache2
    pkgList="apache2 apache2-doc apache2-utils apache2.2-common apache2.2-bin apache2-mpm-prefork apache2-doc apache2-mpm-worker php5 php5-common php5-cgi php5-cli php5-mysql php5-curl php5-gd"
    for Package in ${pkgList};do
      apt-get -y purge ${Package}
    done
    dpkg -l | grep ^rc | awk '{print $2}' | xargs dpkg -P
  fi

  if [[ "${db_option}" =~ ^[1-9]$|^1[0-2]$ ]]; then
    pkgList="mysql-client mysql-server mysql-common mysql-server-core-5.5 mysql-client-5.5 mariadb-client mariadb-server mariadb-common"
    for Package in ${pkgList};do
      apt-get -y purge ${Package}
    done
    dpkg -l | grep ^rc | awk '{print $2}' | xargs dpkg -P
  fi

  echo "${CMSG}Installing dependencies packages...${CEND}"
  apt-get -y update
  apt-get -y autoremove
  apt-get -yf install
  export DEBIAN_FRONTEND=noninteractive

  # critical security updates
  grep security /etc/apt/sources.list > /tmp/security.sources.list
  apt-get -y upgrade -o Dir::Etc::SourceList=/tmp/security.sources.list

  # Install needed packages
  pkgList="libperl-dev debian-keyring debian-archive-keyring build-essential gcc g++ make cmake autoconf libjpeg8 libjpeg8-dev libpng-dev libpng12-0 libpng12-dev libpng3 libxml2 libxml2-dev zlib1g zlib1g-dev libc6 libc6-dev libc-client2007e-dev libglib2.0-0 libglib2.0-dev bzip2 libzip-dev libbz2-1.0 libncurses5 libncurses5-dev libaio1 libaio-dev numactl libreadline-dev curl libcurl3-gnutls libcurl4-gnutls-dev libcurl4-openssl-dev e2fsprogs libkrb5-3 libkrb5-dev libltdl-dev libidn11 libidn11-dev openssl net-tools libssl-dev libtool libevent-dev re2c libsasl2-dev libxslt1-dev libicu-dev libsqlite3-dev libcloog-ppl1 bison patch vim zip unzip tmux htop bc dc expect libexpat1-dev iptables rsyslog libonig-dev libtirpc-dev libnss3 rsync git lsof lrzsz chrony ntpdate psmisc wget sysv-rc apt-transport-https ca-certificates software-properties-common"
  export DEBIAN_FRONTEND=noninteractive
  for Package in ${pkgList}; do
    apt-get --no-install-recommends -y install ${Package}
  done
}

installDepsBySrc() {
  pushd ${oneinstack_dir}/src > /dev/null
  if ! command -v icu-config > /dev/null 2>&1 || icu-config --version | grep '^3.' || [ "${Ubuntu_ver}" == "20" ]; then
    tar xzf icu4c-${icu4c_ver}-src.tgz
    pushd icu/source > /dev/null
    ./configure --prefix=/usr/local
    make -j ${THREAD} && make install
    popd > /dev/null
    rm -rf icu
  fi

  if command -v lsof >/dev/null 2>&1; then
    echo 'already initialize' > ~/.oneinstack
  else
    echo "${CFAILURE}${PM} config error parsing file failed${CEND}"
    kill -9 $$; exit 1;
  fi

  popd > /dev/null
}
