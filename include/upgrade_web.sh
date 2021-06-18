#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Upgrade_Nginx() {
  pushd ${oneinstack_dir}/src > /dev/null
  [ ! -e "${nginx_install_dir}/sbin/nginx" ] && echo "${CWARNING}Nginx is not installed on your system! ${CEND}" && exit 1
  OLD_nginx_ver_tmp=`${nginx_install_dir}/sbin/nginx -v 2>&1`
  OLD_nginx_ver=${OLD_nginx_ver_tmp##*/}
  Latest_nginx_ver=`curl --connect-timeout 2 -m 3 -s http://nginx.org/en/CHANGES-1.20 | awk '/Changes with nginx/{print$0}' | awk '{print $4}' | head -1`
  [ -z "${Latest_nginx_ver}" ] && Latest_nginx_ver=`curl --connect-timeout 2 -m 3 -s http://nginx.org/en/CHANGES | awk '/Changes with nginx/{print$0}' | awk '{print $4}' | head -1`
  echo
  echo "Current Nginx Version: ${CMSG}${OLD_nginx_ver}${CEND}"
  while :; do echo
    [ "${nginx_flag}" != 'y' ] && read -e -p "Please input upgrade Nginx Version(default: ${Latest_nginx_ver}): " NEW_nginx_ver
    NEW_nginx_ver=${NEW_nginx_ver:-${Latest_nginx_ver}}
    if [ "${NEW_nginx_ver}" != "${OLD_nginx_ver}" ]; then
      [ ! -e "nginx-${NEW_nginx_ver}.tar.gz" ] && wget --no-check-certificate -c http://nginx.org/download/nginx-${NEW_nginx_ver}.tar.gz > /dev/null 2>&1
      if [ -e "nginx-${NEW_nginx_ver}.tar.gz" ]; then
        src_url=https://www.openssl.org/source/openssl-${openssl11_ver}.tar.gz && Download_src
        src_url=http://mirrors.linuxeye.com/oneinstack/src/pcre-${pcre_ver}.tar.gz && Download_src
        tar xzf openssl-${openssl11_ver}.tar.gz
        tar xzf pcre-${pcre_ver}.tar.gz
        echo "Download [${CMSG}nginx-${NEW_nginx_ver}.tar.gz${CEND}] successfully! "
        break
      else
        echo "${CWARNING}Nginx version does not exist! ${CEND}"
      fi
    else
      echo "${CWARNING}input error! Upgrade Nginx version is the same as the old version${CEND}"
      exit
    fi
  done

  if [ -e "nginx-${NEW_nginx_ver}.tar.gz" ]; then
    echo "[${CMSG}nginx-${NEW_nginx_ver}.tar.gz${CEND}] found"
    if [ "${nginx_flag}" != 'y' ]; then
      echo "Press Ctrl+c to cancel or Press any key to continue..."
      char=`get_char`
    fi
    tar xzf nginx-${NEW_nginx_ver}.tar.gz
    pushd nginx-${NEW_nginx_ver}
    make clean
    sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' auto/cc/gcc # close debug
    ${nginx_install_dir}/sbin/nginx -V &> $$
    nginx_configure_args_tmp=`cat $$ | grep 'configure arguments:' | awk -F: '{print $2}'`
    rm -rf $$
    nginx_configure_args=`echo ${nginx_configure_args_tmp} | sed "s@--with-openssl=../openssl-\w.\w.\w\+ @--with-openssl=../openssl-${openssl11_ver} @" | sed "s@--with-pcre=../pcre-\w.\w\+ @--with-pcre=../pcre-${pcre_ver} @"`
    export LUAJIT_LIB=/usr/local/lib
    export LUAJIT_INC=/usr/local/include/luajit-2.1
    ./configure ${nginx_configure_args}
    make -j ${THREAD}
    if [ -f "objs/nginx" ]; then
      /bin/mv ${nginx_install_dir}/sbin/nginx{,`date +%m%d`}
      /bin/cp objs/nginx ${nginx_install_dir}/sbin/nginx
      kill -USR2 `cat /var/run/nginx.pid`
      sleep 1
      kill -QUIT `cat /var/run/nginx.pid.oldbin`
      popd > /dev/null
      echo "You have ${CMSG}successfully${CEND} upgrade from ${CWARNING}${OLD_nginx_ver}${CEND} to ${CWARNING}${NEW_nginx_ver}${CEND}"
      rm -rf nginx-${NEW_nginx_ver}
    else
      echo "${CFAILURE}Upgrade Nginx failed! ${CEND}"
    fi
  fi
  popd > /dev/null
}

Upgrade_Tengine() {
  pushd ${oneinstack_dir}/src > /dev/null
  [ ! -e "${tengine_install_dir}/sbin/nginx" ] && echo "${CWARNING}Tengine is not installed on your system! ${CEND}" && exit 1
  OLD_tengine_ver_tmp=`${tengine_install_dir}/sbin/nginx -v 2>&1`
  OLD_tengine_ver="`echo ${OLD_tengine_ver_tmp#*/} | awk '{print $1}'`"
  Latest_tengine_ver=`curl --connect-timeout 2 -m 3 -s http://tengine.taobao.org/changelog.html | grep -v generator | grep -oE "[0-9]\.[0-9]\.[0-9]+" | head -1`
  echo
  echo "Current Tengine Version: ${CMSG}${OLD_tengine_ver}${CEND}"
  while :; do echo
    [ "${tengine_flag}" != 'y' ] && read -e -p "Please input upgrade Tengine Version(default: ${Latest_tengine_ver}): " NEW_tengine_ver
    NEW_tengine_ver=${NEW_tengine_ver:-${Latest_tengine_ver}}
    if [ "${NEW_tengine_ver}" != "${OLD_tengine_ver}" ]; then
      [ ! -e "tengine-${NEW_tengine_ver}.tar.gz" ] && wget --no-check-certificate -c http://tengine.taobao.org/download/tengine-${NEW_tengine_ver}.tar.gz > /dev/null 2>&1
      if [ -e "tengine-${NEW_tengine_ver}.tar.gz" ]; then
        src_url=https://www.openssl.org/source/openssl-${openssl11_ver}.tar.gz && Download_src
        src_url=http://mirrors.linuxeye.com/oneinstack/src/pcre-${pcre_ver}.tar.gz && Download_src
        tar xzf openssl-${openssl11_ver}.tar.gz
        tar xzf pcre-${pcre_ver}.tar.gz
        echo "Download [${CMSG}tengine-${NEW_tengine_ver}.tar.gz${CEND}] successfully! "
        break
      else
        echo "${CWARNING}Tengine version does not exist! ${CEND}"
      fi
    else
      echo "${CWARNING}input error! Upgrade Tengine version is the same as the old version${CEND}"
      exit
    fi
  done

  if [ -e "tengine-${NEW_tengine_ver}.tar.gz" ]; then
    echo "[${CMSG}tengine-${NEW_tengine_ver}.tar.gz${CEND}] found"
    if [ "${tengine_flag}" != 'y' ]; then
      echo "Press Ctrl+c to cancel or Press any key to continue..."
      char=`get_char`
    fi
    tar xzf tengine-${NEW_tengine_ver}.tar.gz
    pushd tengine-${NEW_tengine_ver}
    make clean
    ${tengine_install_dir}/sbin/nginx -V &> $$
    tengine_configure_args_tmp=`cat $$ | grep 'configure arguments:' | awk -F: '{print $2}'`
    rm -rf $$
    tengine_configure_args=`echo ${tengine_configure_args_tmp} | sed "s@--with-openssl=../openssl-\w.\w.\w\+ @--with-openssl=../openssl-${openssl11_ver} @" | sed "s@--with-pcre=../pcre-\w.\w\+ @--with-pcre=../pcre-${pcre_ver} @"`
    export LUAJIT_LIB=/usr/local/lib
    export LUAJIT_INC=/usr/local/include/luajit-2.1
    ./configure ${tengine_configure_args}
    make
    if [ -f "objs/nginx" ]; then
      /bin/mv ${tengine_install_dir}/sbin/nginx{,`date +%m%d`}
      /bin/mv ${tengine_install_dir}/modules{,`date +%m%d`}
      /bin/cp objs/nginx ${tengine_install_dir}/sbin/nginx
      chmod +x ${tengine_install_dir}/sbin/*
      make install
      kill -USR2 `cat /var/run/nginx.pid`
      sleep 1
      kill -QUIT `cat /var/run/nginx.pid.oldbin`
      popd > /dev/null
      echo "You have ${CMSG}successfully${CEND} upgrade from ${CWARNING}$OLD_tengine_ver${CEND} to ${CWARNING}${NEW_tengine_ver}${CEND}"
      rm -rf tengine-${NEW_tengine_ver}
    else
      echo "${CFAILURE}Upgrade Tengine failed! ${CEND}"
    fi
  fi
  popd > /dev/null
}

Upgrade_OpenResty() {
  pushd ${oneinstack_dir}/src > /dev/null
  [ ! -e "${openresty_install_dir}/nginx/sbin/nginx" ] && echo "${CWARNING}OpenResty is not installed on your system! ${CEND}" && exit 1
  OLD_openresy_ver_tmp=`${openresty_install_dir}/nginx/sbin/nginx -v 2>&1`
  OLD_openresy_ver="`echo ${OLD_openresy_ver_tmp#*/} | awk '{print $1}'`"
  Latest_openresy_ver=`curl --connect-timeout 2 -m 3 -s https://openresty.org/en/download.html | awk '/download\/openresty-/{print $0}' |  grep -oE "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | head -1`
  echo
  echo "Current OpenResty Version: ${CMSG}${OLD_openresy_ver}${CEND}"
  while :; do echo
    [ "${openresty_flag}" != 'y' ] && read -e -p "Please input upgrade OpenResty Version(default: ${Latest_openresy_ver}): " NEW_openresy_ver
    NEW_openresy_ver=${NEW_openresy_ver:-${Latest_openresy_ver}}
    if [ "${NEW_openresy_ver}" != "${OLD_openresy_ver}" ]; then
      [ ! -e "openresty-${NEW_openresy_ver}.tar.gz" ] && wget --no-check-certificate -c https://openresty.org/download/openresty-${NEW_openresy_ver}.tar.gz > /dev/null 2>&1
      if [ -e "openresty-${NEW_openresy_ver}.tar.gz" ]; then
        src_url=https://www.openssl.org/source/openssl-${openssl11_ver}.tar.gz && Download_src
        src_url=http://mirrors.linuxeye.com/oneinstack/src/pcre-${pcre_ver}.tar.gz && Download_src
        tar xzf openssl-${openssl11_ver}.tar.gz
        tar xzf pcre-${pcre_ver}.tar.gz
        echo "Download [${CMSG}openresty-${NEW_openresy_ver}.tar.gz${CEND}] successfully! "
        break
      else
        echo "${CWARNING}OpenResty version does not exist! ${CEND}"
      fi
    else
      echo "${CWARNING}input error! Upgrade OpenResty version is the same as the old version${CEND}"
      exit
    fi
  done

  if [ -e "openresty-${NEW_openresy_ver}.tar.gz" ]; then
    echo "[${CMSG}openresty-${NEW_openresy_ver}.tar.gz${CEND}] found"
    if [ "${openresty_flag}" != 'y' ]; then
      echo "Press Ctrl+c to cancel or Press any key to continue..."
      char=`get_char`
    fi
    tar xzf openresty-${NEW_openresy_ver}.tar.gz
    pushd openresty-${NEW_openresy_ver}
    make clean
    sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' bundle/nginx-${NEW_openresy_ver%.*}/auto/cc/gcc # close debug
    ${openresty_install_dir}/nginx/sbin/nginx -V &> $$
    ./configure --prefix=${openresty_install_dir} --user=${run_user} --group=${run_user} --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-http_ssl_module --with-http_gzip_static_module --with-http_realip_module --with-http_flv_module --with-http_mp4_module --with-openssl=../openssl-${openssl11_ver} --with-pcre=../pcre-${pcre_ver} --with-pcre-jit --with-ld-opt='-ljemalloc -Wl,-u,pcre_version' ${nginx_modules_options}
    make -j ${THREAD}
    if [ -f "build/nginx-${NEW_openresy_ver%.*}/objs/nginx" ]; then
      /bin/mv ${openresty_install_dir}/nginx/sbin/nginx{,`date +%m%d`}
      make install
      kill -USR2 `cat /var/run/nginx.pid`
      sleep 1
      kill -QUIT `cat /var/run/nginx.pid.oldbin`
      popd > /dev/null
      echo "You have ${CMSG}successfully${CEND} upgrade from ${CWARNING}${OLD_openresy_ver}${CEND} to ${CWARNING}${NEW_openresy_ver}${CEND}"
      rm -rf openresty-${NEW_openresy_ver}
    else
      echo "${CFAILURE}Upgrade OpenResty failed! ${CEND}"
    fi
  fi
  popd > /dev/null
}

Upgrade_Apache() {
  pushd ${oneinstack_dir}/src > /dev/null
  [ ! -e "${apache_install_dir}/bin/httpd" ] && echo "${CWARNING}Apache is not installed on your system! ${CEND}" && exit 1
  OLD_apache_ver="`${apache_install_dir}/bin/httpd -v | grep version | awk -F'/| ' '{print $4}'`"
  Apache_main_ver="`echo ${OLD_apache_ver} | awk -F. '{print $1 $2}'`"
  Latest_apache_ver=`curl --connect-timeout 2 -m 3 -s http://httpd.apache.org/download.cgi | awk "/#apache${Apache_main_ver}/{print $2}" | head -1 | grep -oE "2\.[24]\.[0-9]+"`
  Latest_apache_ver=${Latest_apache_ver:-${apache22_ver}}
  echo
  echo "Current Apache Version: ${CMSG}${OLD_apache_ver}${CEND}"
  while :; do echo
    [ "${apache_flag}" != 'y' ] && read -e -p "Please input upgrade Apache Version(Default: ${Latest_apache_ver}): " NEW_apache_ver
    NEW_apache_ver=${NEW_apache_ver:-${Latest_apache_ver}}
    if [ `echo ${NEW_apache_ver} | awk -F. '{print $1$2}'` == "${Apache_main_ver}" ]; then
      if [ "${NEW_apache_ver}" != "${OLD_apache_ver}" ]; then
        if [ "${Apache_main_ver}" == '24' ]; then
          src_url=http://archive.apache.org/dist/apr/apr-${apr_ver}.tar.gz && Download_src
          src_url=http://archive.apache.org/dist/apr/apr-util-${apr_util_ver}.tar.gz && Download_src
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
        exit
      fi
    else
      echo "${CWARNING}input error! ${CEND}Please only input '${CMSG}${OLD_apache_ver%.*}.xx${CEND}'"
      [ "${apache_flag}" == 'y' ] && exit
    fi
  done

  if [ -e "httpd-${NEW_apache_ver}.tar.gz" ]; then
    echo "[${CMSG}httpd-${NEW_apache_ver}.tar.gz${CEND}] found"
    if [ "${apache_flag}" != 'y' ]; then
      echo "Press Ctrl+c to cancel or Press any key to continue..."
      char=`get_char`
    fi
    if [ "${Apache_main_ver}" == '24' ]; then
      # install apr
      if [ ! -e "${apr_install_dir}/bin/apr-1-config" ]; then
        tar xzf apr-${apr_ver}.tar.gz
        pushd apr-${apr_ver} > /dev/null
        ./configure --prefix=${apr_install_dir}
        make -j ${THREAD} && make install
        popd > /dev/null
        rm -rf apr-${apr_ver}
      fi
      # install apr-util
      if [ ! -e "${apr_install_dir}/bin/apu-1-config" ]; then
        tar xzf apr-util-${apr_util_ver}.tar.gz
        pushd apr-util-${apr_util_ver} > /dev/null
        ./configure --prefix=${apr_install_dir} --with-apr=${apr_install_dir}
        make -j ${THREAD} && make install
        popd > /dev/null
        rm -rf apr-util-${apr_util_ver}
      fi
    fi
    tar xzf httpd-${NEW_apache_ver}.tar.gz
    pushd httpd-${NEW_apache_ver}
    make clean
    if [ "${Apache_main_ver}" == '24' ]; then
      LDFLAGS=-ldl ./configure --prefix=${apache_install_dir} --enable-mpms-shared=all --with-pcre --with-apr=${apr_install_dir} --with-apr-util=${apr_install_dir} --enable-headers --enable-mime-magic --enable-deflate --enable-proxy --enable-so --enable-dav --enable-rewrite --enable-remoteip --enable-expires --enable-static-support --enable-suexec --enable-mods-shared=most --enable-nonportable-atomics=yes --enable-ssl --with-ssl=${openssl_install_dir} --enable-http2 --with-nghttp2=/usr/local
    elif [ "${Apache_main_ver}" == '22' ]; then
      LDFLAGS=-ldl ./configure --prefix=${apache_install_dir} --with-mpm=prefork --enable-mpms-shared=all --with-included-apr --enable-headers --enable-mime-magic --enable-deflate --enable-proxy --enable-so --enable-dav --enable-rewrite --enable-expires --enable-static-support --enable-suexec --with-expat=builtin --enable-mods-shared=most --enable-ssl --with-ssl=${openssl_install_dir}
    fi
    make -j ${THREAD}
    if [ -e 'httpd' ]; then
      [[ -d ${apache_install_dir}_bak && -d ${apache_install_dir} ]] && rm -rf ${apache_install_dir}_bak
      service httpd stop
      /bin/cp -R ${apache_install_dir}{,_bak}
      make install && unset LDFLAGS
      service httpd start
      popd > /dev/null
      echo "You have ${CMSG}successfully${CEND} upgrade from ${CWARNING}${OLD_apache_ver}${CEND} to ${CWARNING}${NEW_apache_ver}${CEND}"
      rm -rf httpd-${NEW_apache_ver}
    else
      echo "${CFAILURE}Upgrade Apache failed! ${CEND}"
    fi
  fi
  popd > /dev/null
}

Upgrade_Tomcat() {
  pushd ${oneinstack_dir}/src > /dev/null
  [ ! -e "${tomcat_install_dir}/conf/server.xml" ] && echo "${CWARNING}Tomcat is not installed on your system! ${CEND}" && exit 1
  OLD_tomcat_ver="`${tomcat_install_dir}/bin/version.sh | awk '/Server number/{print $3}' | awk -F. '{print $1"."$2"."$3}'`"
  Tomcat_flag="`echo ${OLD_tomcat_ver} | awk -F. '{print $1}'`"
  Latest_tomcat_ver=`curl --connect-timeout 2 -m 3 -s https://tomcat.apache.org/download-${Tomcat_flag}0.cgi | grep "README" | head -1 | grep -oE "[6-9]\.[0-9]\.[0-9]+"`
  Latest_tomcat_ver=${Latest_tomcat_ver:-${tomcat10_ver}}
  echo
  echo "Current Tomcat Version: ${CMSG}${OLD_tomcat_ver}${CEND}"
  while :; do echo
    [ "${tomcat_flag}" != 'y' ] && read -e -p "Please input upgrade Tomcat Version(Default: ${Latest_tomcat_ver}): " NEW_tomcat_ver
    NEW_tomcat_ver=${NEW_tomcat_ver:-${Latest_tomcat_ver}}
    if [ "`echo ${NEW_tomcat_ver} | awk -F. '{print $1}'`" == "${Tomcat_flag}" ]; then
      rm -f catalina-jmx-remote.jar
      echo "Download tomcat-${NEW_tomcat_ver}..."
      src_url=http://mirrors.linuxeye.com/apache/tomcat/v${NEW_tomcat_ver}/apache-tomcat-${NEW_tomcat_ver}.tar.gz && Download_src
      [ ! -e "apache-tomcat-${NEW_tomcat_ver}.tar.gz" ] && wget --no-check-certificate -c https://archive.apache.org/dist/tomcat-${OLD_tomcat_ver}/v${NEW_tomcat_ver}/bin/apache-tomcat-${NEW_tomcat_ver}.tar.gz > /dev/null 2>&1
      if [ -e "${tomcat_install_dir}/lib/catalina-jmx-remote.jar" ]; then
        src_url=http://mirrors.linuxeye.com/apache/tomcat/v${NEW_tomcat_ver}/catalina-jmx-remote.jar && Download_src
        [ ! -e "catalina-jmx-remote.jar" ] && wget --no-check-certificate -c https://archive.apache.org/dist/tomcat-${OLD_tomcat_ver}/v${NEW_tomcat_ver}/bin/extras/catalina-jmx-remote.jar > /dev/null 2>&1
      fi
      if [ -e "apache-tomcat-${NEW_tomcat_ver}.tar.gz" ]; then
        echo "Download [${CMSG}apache-tomcat-${NEW_tomcat_ver}.tar.gz${CEND}] successfully! "
        break
      else
        echo "${CWARNING}Tomcat version does not exist! ${CEND}"
      fi
    else
      echo "${CWARNING}input error! ${CEND}Please only input '${CMSG}${Tomcat_flag}.xx${CEND}'"
    fi
  done

  if [ -e "apache-tomcat-${NEW_tomcat_ver}.tar.gz" ]; then
    echo "[${CMSG}apache-tomcat-${NEW_tomcat_ver}.tar.gz${CEND}] found"
    if [ "${tomcat_flag}" != 'y' ]; then
      echo "Press Ctrl+c to cancel or Press any key to continue..."
      char=`get_char`
    fi
    tar xzf apache-tomcat-${NEW_tomcat_ver}.tar.gz
    /bin/mv apache-tomcat-${NEW_tomcat_ver}/conf/server.xml{,_bk}
    /bin/cp ${tomcat_install_dir}/conf/{server.xml,jmxremote.access,jmxremote.password,tomcat-users.xml} apache-tomcat-${NEW_tomcat_ver}/conf/
    [ -e "${tomcat_install_dir}/lib/catalina-jmx-remote.jar" ] && /bin/cp catalina-jmx-remote.jar apache-tomcat-${NEW_tomcat_ver}/lib
    /bin/cp ${tomcat_install_dir}/bin/setenv.sh apache-tomcat-${NEW_tomcat_ver}/bin/
    /bin/cp -R ${tomcat_install_dir}/conf/vhost apache-tomcat-${NEW_tomcat_ver}/conf/
    chmod +x apache-tomcat-${NEW_tomcat_ver}/bin/*.sh
    [[ -d ${tomcat_install_dir}_bak && -d ${tomcat_install_dir} ]] && rm -rf ${tomcat_install_dir}._bak
    service tomcat stop
    /bin/mv ${tomcat_install_dir}{,_bak}
    /bin/mv apache-tomcat-${NEW_tomcat_ver} ${tomcat_install_dir} && chown -R ${run_user}:${run_group} ${tomcat_install_dir}
    if [ -e "${tomcat_install_dir}/conf/server.xml" ]; then
      service tomcat start
      echo "You have ${CMSG}successfully${CEND} upgrade from ${CWARNING}${OLD_tomcat_ver}${CEND} to ${CWARNING}${NEW_tomcat_ver}${CEND}"
    else
      echo "${CFAILURE}Upgrade Tomcat failed! ${CEND}"
    fi
  fi
  popd > /dev/null
}
