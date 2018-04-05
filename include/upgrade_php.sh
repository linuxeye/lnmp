#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Upgrade_PHP() {
  pushd ${oneinstack_dir}/src > /dev/null
  [ ! -e "${php_install_dir}" ] && echo "${CWARNING}PHP is not installed on your system! ${CEND}" && exit 1
  OLD_php_ver=`${php_install_dir}/bin/php -r 'echo PHP_VERSION;'`
  Latest_php_ver=`curl -s http://php.net/downloads.php | awk '/Changelog/{print $2}' | grep "${OLD_php_ver%.*}"`
  [ -z "$Latest_php_ver" ] && Latest_php_ver=5.5.38
  echo
  echo "Current PHP Version: ${CMSG}$OLD_php_ver${CEND}"
  while :; do echo
    read -p "Please input upgrade PHP Version(Default: $Latest_php_ver): " NEW_php_ver
    [ -z "$NEW_php_ver" ] && NEW_php_ver=$Latest_php_ver
    if [ "${NEW_php_ver%.*}" == "${OLD_php_ver%.*}" ]; then
      [ ! -e "php-${NEW_php_ver}.tar.gz" ] && wget --no-check-certificate -c http://www.php.net/distributions/php-${NEW_php_ver}.tar.gz > /dev/null 2>&1
      if [ -e "php-${NEW_php_ver}.tar.gz" ]; then
        echo "Download [${CMSG}php-${NEW_php_ver}.tar.gz${CEND}] successfully! "
      else
        echo "${CWARNING}PHP version does not exist! ${CEND}"
      fi
      break
    else
      echo "${CWARNING}input error! ${CEND}Please only input '${CMSG}${OLD_php_ver%.*}.xx${CEND}'"
    fi
  done

  if [ -e "php-${NEW_php_ver}.tar.gz" ]; then
    echo "[${CMSG}php-${NEW_php_ver}.tar.gz${CEND}] found"
    echo "Press Ctrl+c to cancel or Press any key to continue..."
    char=`get_char`
    tar xzf php-${NEW_php_ver}.tar.gz
    src_url=http://mirrors.linuxeye.com/oneinstack/src/fpm-race-condition.patch && Download_src
    patch -d php-${NEW_php_ver} -p0 < fpm-race-condition.patch
    pushd php-${NEW_php_ver}
    make clean
    ${php_install_dir}/bin/php -i |grep 'Configure Command' | awk -F'=>' '{print $2}' | bash
    make ZEND_EXTRA_LIBS='-liconv'
    if [ -e "${apache_install_dir}/bin/apachectl" ]; then
      echo "Stoping apache..."
      service httpd stop
      make install
      echo "Starting apache..."
      service httpd start
    else
      echo "Stoping php-fpm..."
      service php-fpm stop
      make install
      echo "Starting php-fpm..."
      service php-fpm start
    fi
    popd > /dev/null
    echo "You have ${CMSG}successfully${CEND} upgrade from ${CWARNING}$OLD_php_ver${CEND} to ${CWARNING}${NEW_php_ver}${CEND}"
    rm -rf php-${NEW_php_ver}
  fi
  popd > /dev/null
}
