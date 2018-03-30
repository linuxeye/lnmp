#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Upgrade_Nginx() {
  pushd ${oneinstack_dir}/src > /dev/null
  [ ! -e "$nginx_install_dir/sbin/nginx" ] && echo "${CWARNING}Nginx is not installed on your system! ${CEND}" && exit 1
  OLD_nginx_ver_tmp=`$nginx_install_dir/sbin/nginx -v 2>&1`
  OLD_nginx_ver=${OLD_nginx_ver_tmp##*/}
  Latest_nginx_ver=`curl -s http://nginx.org/en/CHANGES-1.12 | awk '/Changes with nginx/{print$0}' | awk '{print $4}' | head -1`
  [ -z "$Latest_nginx_ver" ] && Latest_nginx_ver=`curl -s http://nginx.org/en/CHANGES | awk '/Changes with nginx/{print$0}' | awk '{print $4}' | head -1`
  echo
  echo "Current Nginx Version: ${CMSG}$OLD_nginx_ver${CEND}"
  while :; do echo
    read -p "Please input upgrade Nginx Version(default: $Latest_nginx_ver): " NEW_nginx_ver
    [ -z "$NEW_nginx_ver" ] && NEW_nginx_ver=$Latest_nginx_ver
    if [ "$NEW_nginx_ver" != "$OLD_nginx_ver" ]; then
      [ ! -e "nginx-$NEW_nginx_ver.tar.gz" ] && wget --no-check-certificate -c http://nginx.org/download/nginx-$NEW_nginx_ver.tar.gz > /dev/null 2>&1
      if [ -e "nginx-$NEW_nginx_ver.tar.gz" ]; then
        src_url=https://www.openssl.org/source/openssl-$openssl_ver.tar.gz && Download_src
        src_url=http://mirrors.linuxeye.com/oneinstack/src/pcre-$pcre_ver.tar.gz && Download_src
        tar xzf openssl-$openssl_ver.tar.gz
        tar xzf pcre-$pcre_ver.tar.gz
        echo "Download [${CMSG}nginx-$NEW_nginx_ver.tar.gz${CEND}] successfully! "
        break
      else
        echo "${CWARNING}Nginx version does not exist! ${CEND}"
      fi
    else
      echo "${CWARNING}input error! Upgrade Nginx version is the same as the old version${CEND}"
    fi
  done

  if [ -e "nginx-$NEW_nginx_ver.tar.gz" ]; then
    echo "[${CMSG}nginx-$NEW_nginx_ver.tar.gz${CEND}] found"
    echo "Press Ctrl+c to cancel or Press any key to continue..."
    char=`get_char`
    tar xzf nginx-$NEW_nginx_ver.tar.gz
    pushd nginx-$NEW_nginx_ver
    make clean
    sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' auto/cc/gcc # close debug
    $nginx_install_dir/sbin/nginx -V &> $$
    nginx_configure_arguments=`cat $$ | grep 'configure arguments:' | awk -F: '{print $2}'`
    rm -rf $$
    ./configure $nginx_configure_arguments
    make -j ${THREAD}
    if [ -f "objs/nginx" ]; then
      /bin/mv $nginx_install_dir/sbin/nginx{,`date +%m%d`}
      /bin/cp objs/nginx $nginx_install_dir/sbin/nginx
      kill -USR2 `cat /var/run/nginx.pid`
      sleep 1
      kill -QUIT `cat /var/run/nginx.pid.oldbin`
      popd > /dev/null
      echo "You have ${CMSG}successfully${CEND} upgrade from ${CWARNING}$OLD_nginx_ver${CEND} to ${CWARNING}$NEW_nginx_ver${CEND}"
      rm -rf nginx-$NEW_nginx_ver
    else
      echo "${CFAILURE}Upgrade Nginx failed! ${CEND}"
    fi
  fi
  popd > /dev/null
}

Upgrade_Tengine() {
  pushd ${oneinstack_dir}/src > /dev/null
  [ ! -e "$tengine_install_dir/sbin/nginx" ] && echo "${CWARNING}Tengine is not installed on your system! ${CEND}" && exit 1
  OLD_tengine_ver_tmp=`$tengine_install_dir/sbin/nginx -v 2>&1`
  OLD_tengine_ver="`echo ${OLD_tengine_ver_tmp#*/} | awk '{print $1}'`"
  Latest_tengine_ver=`curl -s http://tengine.taobao.org/changelog.html | grep -oE "[0-9]\.[0-9]\.[0-9]+" | head -1`
  echo
  echo "Current Tengine Version: ${CMSG}$OLD_tengine_ver${CEND}"
  while :; do echo
    read -p "Please input upgrade Tengine Version(default: $Latest_tengine_ver): " NEW_tengine_ver
    [ -z "$NEW_tengine_ver" ] && NEW_tengine_ver=$Latest_tengine_ver
    if [ "$NEW_tengine_ver" != "$OLD_tengine_ver" ]; then
      [ ! -e "tengine-$NEW_tengine_ver.tar.gz" ] && wget --no-check-certificate -c http://tengine.taobao.org/download/tengine-$NEW_tengine_ver.tar.gz > /dev/null 2>&1
      if [ -e "tengine-$NEW_tengine_ver.tar.gz" ]; then
        src_url=https://www.openssl.org/source/openssl-$openssl_ver.tar.gz && Download_src
        src_url=http://mirrors.linuxeye.com/oneinstack/src/pcre-$pcre_ver.tar.gz && Download_src
        tar xzf openssl-$openssl_ver.tar.gz
        tar xzf pcre-$pcre_ver.tar.gz
        echo "Download [${CMSG}tengine-$NEW_tengine_ver.tar.gz${CEND}] successfully! "
        break
      else
        echo "${CWARNING}Tengine version does not exist! ${CEND}"
      fi
    else
      echo "${CWARNING}input error! Upgrade Tengine version is the same as the old version${CEND}"
    fi
  done

  if [ -e "tengine-$NEW_tengine_ver.tar.gz" ]; then
    echo "[${CMSG}tengine-$NEW_tengine_ver.tar.gz${CEND}] found"
    echo "Press Ctrl+c to cancel or Press any key to continue..."
    char=`get_char`
    tar xzf tengine-$NEW_tengine_ver.tar.gz
    pushd tengine-$NEW_tengine_ver
    make clean
    sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' auto/cc/gcc # close debug
    $tengine_install_dir/sbin/nginx -V &> $$
    tengine_configure_arguments=`cat $$ | grep 'configure arguments:' | awk -F: '{print $2}'`
    rm -rf $$
    ./configure $tengine_configure_arguments
    make -j ${THREAD}
    if [ -f "objs/nginx" ]; then
      /bin/mv $tengine_install_dir/sbin/nginx{,`date +%m%d`}
      /bin/mv $tengine_install_dir/sbin/dso_tool{,`date +%m%d`}
      /bin/mv $tengine_install_dir/modules{,`date +%m%d`}
      /bin/cp objs/nginx $tengine_install_dir/sbin/nginx
      /bin/cp objs/dso_tool $tengine_install_dir/sbin/dso_tool
      chmod +x $tengine_install_dir/sbin/*
      make install
      kill -USR2 `cat /var/run/nginx.pid`
      sleep 1
      kill -QUIT `cat /var/run/nginx.pid.oldbin`
      popd > /dev/null
      echo "You have ${CMSG}successfully${CEND} upgrade from ${CWARNING}$OLD_tengine_ver${CEND} to ${CWARNING}$NEW_tengine_ver${CEND}"
      rm -rf tengine-$NEW_tengine_ver
    else
      echo "${CFAILURE}Upgrade Tengine failed! ${CEND}"
    fi
  fi
  popd > /dev/null
}

Upgrade_OpenResty() {
  pushd ${oneinstack_dir}/src > /dev/null
  [ ! -e "$openresty_install_dir/nginx/sbin/nginx" ] && echo "${CWARNING}OpenResty is not installed on your system! ${CEND}" && exit 1
  OLD_openresy_ver_tmp=`$openresty_install_dir/nginx/sbin/nginx -v 2>&1`
  OLD_openresy_ver="`echo ${OLD_openresy_ver_tmp#*/} | awk '{print $1}'`"
  Latest_openresy_ver=`curl -s https://openresty.org/en/download.html | awk '/download\/openresty-/{print $0}' |  grep -oE "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | head -1`
  echo
  echo "Current OpenResty Version: ${CMSG}$OLD_openresy_ver${CEND}"
  while :; do echo
    read -p "Please input upgrade OpenResty Version(default: $Latest_openresy_ver): " NEW_openresy_ver
    [ -z "$NEW_openresy_ver" ] && NEW_openresy_ver=$Latest_openresy_ver
    if [ "$NEW_openresy_ver" != "$OLD_openresy_ver" ]; then
      [ ! -e "openresty-$NEW_openresy_ver.tar.gz" ] && wget --no-check-certificate -c https://openresty.org/download/openresty-$NEW_openresy_ver.tar.gz > /dev/null 2>&1
      if [ -e "openresty-$NEW_openresy_ver.tar.gz" ]; then
        src_url=https://www.openssl.org/source/openssl-$openssl_ver.tar.gz && Download_src
        src_url=http://mirrors.linuxeye.com/oneinstack/src/pcre-$pcre_ver.tar.gz && Download_src
        tar xzf openssl-$openssl_ver.tar.gz
        tar xzf pcre-$pcre_ver.tar.gz
        echo "Download [${CMSG}openresty-$NEW_openresy_ver.tar.gz${CEND}] successfully! "
        break
      else
        echo "${CWARNING}OpenResty version does not exist! ${CEND}"
      fi
    else
      echo "${CWARNING}input error! Upgrade OpenResty version is the same as the old version${CEND}"
    fi
  done

  if [ -e "openresty-$NEW_openresy_ver.tar.gz" ]; then
    echo "[${CMSG}openresty-$NEW_openresy_ver.tar.gz${CEND}] found"
    echo "Press Ctrl+c to cancel or Press any key to continue..."
    char=`get_char`
    tar xzf openresty-$NEW_openresy_ver.tar.gz
    pushd openresty-$NEW_openresy_ver
    make clean
    openresty_ver_tmp=${NEW_openresy_ver%.*}
    sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' bundle/nginx-$openresty_ver_tmp/auto/cc/gcc # close debug
    $openresty_install_dir/nginx/sbin/nginx -V &> $$
    ./configure --prefix=$openresty_install_dir --user=${run_user} --group=${run_user} --with-http_stub_status_module --with-http_v2_module --with-http_ssl_module --with-http_gzip_static_module --with-http_realip_module --with-http_flv_module --with-http_mp4_module --with-openssl=../openssl-$openssl_ver --with-pcre=../pcre-$pcre_ver --with-pcre-jit --with-ld-opt='-ljemalloc' $nginx_modules_options
    make -j ${THREAD}
    if [ -f "build/nginx-$openresty_ver_tmp/objs/nginx" ]; then
      /bin/mv $openresty_install_dir/nginx/sbin/nginx{,`date +%m%d`}
      make install
      kill -USR2 `cat /var/run/nginx.pid`
      sleep 1
      kill -QUIT `cat /var/run/nginx.pid.oldbin`
      popd > /dev/null
      echo "You have ${CMSG}successfully${CEND} upgrade from ${CWARNING}$OLD_openresy_ver${CEND} to ${CWARNING}$NEW_openresy_ver${CEND}"
      rm -rf openresty-$NEW_openresy_ver
    else
      echo "${CFAILURE}Upgrade OpenResty failed! ${CEND}"
    fi
  fi
  popd > /dev/null
}

Upgrade_Apache() {
  pushd ${oneinstack_dir}/src > /dev/null
  [ ! -e "${apache_install_dir}/bin/httpd" ] && echo "${CWARNING}Apache is not installed on your system! ${CEND}" && exit 1
  OLD_apache_ver="`/usr/local/apache/bin/httpd -v | grep version | awk -F'/| ' '{print $4}'`"
  Apache_flag="`echo ${OLD_apache_ver} | awk -F. '{print $1 $2}'`"
  Latest_apache_ver=`curl -s http://httpd.apache.org/download.cgi | awk "/#apache${Apache_flag}/{print $2}" | head -1 | grep -oE "2\.[24]\.[0-9]+"`
  [ -z "${Latest_apache_ver}" ] && Latest_apache_ver=${apache22_ver}
  echo
  echo "Current Apache Version: ${CMSG}${OLD_apache_ver}${CEND}"
  while :; do echo
    read -p "Please input upgrade Apache Version(Default: ${Latest_apache_ver}): " NEW_apache_ver
    if [ `echo ${NEW_apache_ver} | awk -F. '{print $1$2}'` == "${Apache_flag}" ]; then
      [ -z "${NEW_apache_ver}" ] && NEW_apache_ver=${Latest_apache_ver}
      if [ "${NEW_apache_ver}" != "${OLD_apache_ver}" ]; then
        if [ "${Apache_flag}" == '24' ]; then
          src_url=http://archive.apache.org/dist/apr/apr-${apr_ver}.tar.gz && Download_src
          src_url=http://archive.apache.org/dist/apr/apr-util-${apr_util_ver}.tar.gz && Download_src
          tar xzf apr-${apr_ver}.tar.gz
          tar xzf apr-util-${apr_util_ver}.tar.gz
        fi
        [ ! -e "httpd-${NEW_apache_ver}.tar.gz" ] && wget --no-check-certificate -c http://archive.apache.org/dist/httpd/httpd-${NEW_apache_ver}.tar.gz > /dev/null 2>&1
        if [ -e "httpd-${NEW_apache_ver}.tar.gz" ]; then
          echo "Download [${CMSG}apache-${NEW_apache_ver}.tar.gz${CEND}] successfully! "
          break
        else
          echo "${CWARNING}Apache version does not exist! ${CEND}"
        fi
      else
        echo "${CWARNING}input error! Upgrade Apache version is the same as the old version${CEND}"
      fi
    else
      echo "${CWARNING}input error! ${CEND}Please only input '${CMSG}${OLD_apache_ver%.*}.xx${CEND}'"
    fi
  done

  if [ -e "httpd-${NEW_apache_ver}.tar.gz" ]; then
    echo "[${CMSG}httpd-${NEW_apache_ver}.tar.gz${CEND}] found"
    echo "Press Ctrl+c to cancel or Press any key to continue..."
    char=`get_char`
    tar xzf httpd-${NEW_apache_ver}.tar.gz
    pushd httpd-${NEW_apache_ver}
    make clean
    if [ "${Apache_flag}" == '24' ]; then
      /bin/cp -R ../apr-${apr_ver} ./srclib/apr
      /bin/cp -R ../apr-util-${apr_util_ver} ./srclib/apr-util
      [ -e "${php_install_dir}/bin/phpize" ] && { PHP_detail_ver=`${php_install_dir}/bin/php -r 'echo PHP_VERSION;'`; PHP_master_ver=${PHP_detail_ver%%.*}; }
      [ "${PHP_master_ver}" == '5' ] && Apache_mpm_arg='--with-mpm=prefork'
      LDFLAGS=-ldl LD_LIBRARY_PATH=${openssl_install_dir}/lib ./configure --prefix=${apache_install_dir} ${Apache_mpm_arg} --enable-mpms-shared=all --with-included-apr --enable-headers --enable-deflate --enable-so --enable-dav --enable-rewrite --enable-ssl --with-ssl=${openssl_install_dir} --enable-http2 --with-nghttp2=/usr/local --enable-expires --enable-static-support --enable-suexec --enable-modules=all --enable-mods-shared=all
    elif [ "${Apache_flag}" == '22' ]; then
      [ "${Ubuntu_ver}" == "12" ] && sed -i '@SSL_PROTOCOL_SSLV2@d' modules/ssl/ssl_engine_io.c
      LDFLAGS=-ldl ./configure --prefix=${apache_install_dir} --with-mpm=prefork --with-included-apr --enable-headers --enable-deflate --enable-so --enable-rewrite --enable-ssl--with-ssl=${openssl_install_dir} --enable-expires --enable-static-support --enable-suexec --enable-modules=all --enable-mods-shared=all
    fi
    make -j ${THREAD}
    if [ -e 'httpd' ]; then
      [[ -d ${apache_install_dir}.bak && -d ${apache_install_dir} ]] && rm -rf ${apache_install_dir}.bak
      /etc/init.d/httpd stop
      /bin/cp -R ${apache_install_dir}{,bak}
      make install && unset LDFLAGS
      /etc/init.d/httpd start
      popd > /dev/null
      echo "You have ${CMSG}successfully${CEND} upgrade from ${CWARNING}${OLD_apache_ver}${CEND} to ${CWARNING}${NEW_apache_ver}${CEND}"
      rm -rf httpd-${NEW_apache_ver} apr-${apr_ver} apr-util-${apr_util_ver}
    else
      echo "${CFAILURE}Upgrade Apache failed! ${CEND}"
    fi
  fi
  popd > /dev/null
}
