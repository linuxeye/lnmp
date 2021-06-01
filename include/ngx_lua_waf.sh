#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Nginx_lua_waf() {
  pushd ${oneinstack_dir}/src > /dev/null
  [ ! -e "${nginx_install_dir}/sbin/nginx" ] && echo "${CWARNING}Nginx is not installed on your system! ${CEND}" && exit 1
  if [ ! -e "/usr/local/lib/libluajit-5.1.so.2.1.0" ]; then
    [ -e "/usr/local/lib/libluajit-5.1.so.2.0.5" ] && find /usr/local -name *luajit* | xargs rm -rf
    src_url=http://mirrors.linuxeye.com/oneinstack/src/luajit2-${luajit2_ver}.tar.gz && Download_src
    tar xzf luajit2-${luajit2_ver}.tar.gz
    pushd luajit2-${luajit2_ver}
    make && make install
    [ ! -e "/usr/local/lib/libluajit-5.1.so.2.1.0" ] && { echo "${CFAILURE}LuaJIT install failed! ${CEND}"; kill -9 $$; }
    popd > /dev/null
    rm -rf luajit2-${luajit2_ver}
  fi
  if [ ! -e "/usr/local/lib/lua/resty/core.lua" ]; then
    src_url=http://mirrors.linuxeye.com/oneinstack/src/lua-resty-core-${lua_resty_core_ver}.tar.gz && Download_src
    tar xzf lua-resty-core-${lua_resty_core_ver}.tar.gz
    pushd lua-resty-core-${lua_resty_core_ver}
    make install
    popd > /dev/null
    rm -rf lua-resty-core-${lua_resty_core_ver}
  fi
  if [ ! -e "/usr/local/lib/lua/resty/lrucache.lua" ]; then
    src_url=http://mirrors.linuxeye.com/oneinstack/src/lua-resty-lrucache-${lua_resty_lrucache_ver}.tar.gz && Download_src
    tar xzf lua-resty-lrucache-${lua_resty_lrucache_ver}.tar.gz
    pushd lua-resty-lrucache-${lua_resty_lrucache_ver}
    make install
    popd > /dev/null
    rm -rf lua-resty-lrucache-${lua_resty_lrucache_ver}
  fi
  [ ! -h "/usr/local/share/lua/5.1" ] && { rm -rf /usr/local/share/lua/5.1 ; ln -s /usr/local/lib/lua /usr/local/share/lua/5.1; }
  if [ ! -e "/usr/local/lib/lua/5.1/cjson.so" ]; then
    src_url=http://mirrors.linuxeye.com/oneinstack/src/lua-cjson-${lua_cjson_ver}.tar.gz && Download_src
    tar xzf lua-cjson-${lua_cjson_ver}.tar.gz
    pushd lua-cjson-${lua_cjson_ver}
    sed -i 's@^LUA_INCLUDE_DIR.*@&/luajit-2.1@' Makefile
    make && make install
    [ ! -e "/usr/local/lib/lua/5.1/cjson.so" ] && { echo "${CFAILURE}lua-cjson install failed! ${CEND}"; kill -9 $$; }
    popd > /dev/null
  fi
  ${nginx_install_dir}/sbin/nginx -V &> $$
  nginx_configure_args_tmp=`cat $$ | grep 'configure arguments:' | awk -F: '{print $2}'`
  rm -rf $$
  nginx_configure_args=`echo ${nginx_configure_args_tmp} | sed "s@--with-openssl=../openssl-\w.\w.\w\+ @--with-openssl=../openssl-${openssl11_ver} @" | sed "s@--with-pcre=../pcre-\w.\w\+ @--with-pcre=../pcre-${pcre_ver} @"`
  if [ -z "`echo ${nginx_configure_args} | grep lua-nginx-module`" ]; then
    src_url=http://nginx.org/download/nginx-${nginx_ver}.tar.gz && Download_src
    src_url=https://www.openssl.org/source/openssl-${openssl11_ver}.tar.gz && Download_src
    src_url=http://mirrors.linuxeye.com/oneinstack/src/pcre-${pcre_ver}.tar.gz && Download_src
    src_url=http://mirrors.linuxeye.com/oneinstack/src/ngx_devel_kit.tar.gz && Download_src
    src_url=http://mirrors.linuxeye.com/oneinstack/src/lua-nginx-module-${lua_nginx_module_ver}.tar.gz && Download_src
    tar xzf nginx-${nginx_ver}.tar.gz
    tar xzf openssl-${openssl11_ver}.tar.gz
    tar xzf pcre-${pcre_ver}.tar.gz
    tar xzf ngx_devel_kit.tar.gz
    tar xzf lua-nginx-module-${lua_nginx_module_ver}.tar.gz
    pushd nginx-${nginx_ver}
    make clean
    sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' auto/cc/gcc # close debug
    export LUAJIT_LIB=/usr/local/lib
    export LUAJIT_INC=/usr/local/include/luajit-2.1
    ./configure ${nginx_configure_args} --with-ld-opt="-Wl,-rpath,/usr/local/lib" --add-module=../lua-nginx-module-${lua_nginx_module_ver} --add-module=../ngx_devel_kit
    make -j ${THREAD}
    if [ -f "objs/nginx" ]; then
      /bin/mv ${nginx_install_dir}/sbin/nginx{,`date +%m%d`}
      /bin/cp objs/nginx ${nginx_install_dir}/sbin/nginx
      kill -USR2 `cat /var/run/nginx.pid`
      sleep 1
      kill -QUIT `cat /var/run/nginx.pid.oldbin`
      popd > /dev/null
      echo "${CSUCCESS}lua-nginx-module installed successfully! ${CEND}"
      sed -i "s@^nginx_modules_options='\(.*\)'@nginx_modules_options=\'\1 --with-ld-opt=\"-Wl,-rpath,/usr/local/lib\" --add-module=../lua-nginx-module-${lua_nginx_module_ver} --add-module=../ngx_devel_kit\'@" ../options.conf
      rm -rf nginx-${nginx_ver}
    else
      echo "${CFAILURE}lua-nginx-module install failed! ${CEND}"
      kill -9 $$
    fi
  fi
  popd > /dev/null
}

Tengine_lua_waf() {
  pushd ${oneinstack_dir}/src > /dev/null
  [ ! -e "${tengine_install_dir}/sbin/nginx" ] && echo "${CWARNING}Tengine is not installed on your system! ${CEND}" && exit 1
  if [ ! -e "/usr/local/lib/libluajit-5.1.so.2.1.0" ]; then
    [ -e "/usr/local/lib/libluajit-5.1.so.2.0.5" ] && find /usr/local -name *luajit* | xargs rm -rf
    src_url=http://mirrors.linuxeye.com/oneinstack/src/luajit2-${luajit2_ver}.tar.gz && Download_src
    tar xzf luajit2-${luajit2_ver}.tar.gz
    pushd luajit2-${luajit2_ver}
    make && make install
    [ ! -e "/usr/local/lib/libluajit-5.1.so.2.1.0" ] && { echo "${CFAILURE}LuaJIT install failed! ${CEND}"; kill -9 $$; }
    popd > /dev/null
  fi
  if [ ! -e "/usr/local/lib/lua/5.1/cjson.so" ]; then
    src_url=http://mirrors.linuxeye.com/oneinstack/src/lua-cjson-${lua_cjson_ver}.tar.gz && Download_src
    tar xzf lua-cjson-${lua_cjson_ver}.tar.gz
    pushd lua-cjson-${lua_cjson_ver}
    sed -i 's@^LUA_INCLUDE_DIR.*@&/luajit-2.1@' Makefile
    make && make install
    [ ! -e "/usr/local/lib/lua/5.1/cjson.so" ] && { echo "${CFAILURE}lua-cjson install failed! ${CEND}"; kill -9 $$; }
    popd > /dev/null
  fi
  ${tengine_install_dir}/sbin/nginx -V &> $$
  tengine_configure_args_tmp=`cat $$ | grep 'configure arguments:' | awk -F: '{print $2}'`
  rm -rf $$
  tengine_configure_args=`echo ${tengine_configure_args_tmp} | sed "s@--with-openssl=../openssl-\w.\w.\w\+ @--with-openssl=../openssl-${openssl11_ver} @" | sed "s@--with-pcre=../pcre-\w.\w\+ @--with-pcre=../pcre-${pcre_ver} @"`
  if [ -z "`echo ${tengine_configure_args} | grep lua`" ]; then
    src_url=http://tengine.taobao.org/download/tengine-${tengine_ver}.tar.gz && Download_src
    src_url=https://www.openssl.org/source/openssl-${openssl11_ver}.tar.gz && Download_src
    src_url=http://mirrors.linuxeye.com/oneinstack/src/pcre-${pcre_ver}.tar.gz && Download_src
    src_url=http://mirrors.linuxeye.com/oneinstack/src/ngx_devel_kit.tar.gz && Download_src
    src_url=http://mirrors.linuxeye.com/oneinstack/src/lua-nginx-module.tar.gz && Download_src
    tar xzf tengine-${tengine_ver}.tar.gz
    tar xzf openssl-${openssl11_ver}.tar.gz
    tar xzf pcre-${pcre_ver}.tar.gz
    tar xzf ngx_devel_kit.tar.gz
    tar xzf lua-nginx-module.tar.gz
    pushd tengine-${tengine_ver}
    make clean
    export LUAJIT_LIB=/usr/local/lib
    export LUAJIT_INC=/usr/local/include/luajit-2.1
    ./configure ${tengine_configure_args} --with-ld-opt="-Wl,-rpath,/usr/local/lib" --add-module=../lua-nginx-module --add-module=../ngx_devel_kit
    make -j ${THREAD}
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
      sed -i "s@^nginx_modules_options='\(.*\)'@nginx_modules_options=\'\1 --with-ld-opt=\"-Wl,-rpath,/usr/local/lib\" --add-module=../lua-nginx-module --add-module=../ngx_devel_kit\'@" ../options.conf
      echo "${CSUCCESS}lua_module installed successfully! ${CEND}"
      rm -rf tengine-${tengine_ver}
    else
      echo "${CFAILURE}lua_module install failed! ${CEND}"
      kill -9 $$
    fi
  fi
  popd > /dev/null
}

enable_lua_waf() {
  pushd ${oneinstack_dir}/src > /dev/null
  . ../include/check_dir.sh
  rm -f ngx_lua_waf.tar.gz
  src_url=http://mirrors.linuxeye.com/oneinstack/src/ngx_lua_waf.tar.gz && Download_src
  tar xzf ngx_lua_waf.tar.gz -C ${web_install_dir}/conf
  sed -i "s@/usr/local/nginx@${web_install_dir}@g" ${web_install_dir}/conf/waf.conf
  sed -i "s@/usr/local/nginx@${web_install_dir}@" ${web_install_dir}/conf/waf/config.lua
  sed -i "s@/data/wwwlogs@${wwwlogs_dir}@" ${web_install_dir}/conf/waf/config.lua
  [ -z "`grep 'include waf.conf;' ${web_install_dir}/conf/nginx.conf`" ] && sed -i "s@ vhost/\*.conf;@&\n  include waf.conf;@" ${web_install_dir}/conf/nginx.conf
  ${web_install_dir}/sbin/nginx -t
  if [ $? -eq 0 ]; then
    service nginx reload
    echo "${CSUCCESS}ngx_lua_waf enabled successfully! ${CEND}"
    chown ${run_user}:${run_group} ${wwwlogs_dir}
  else
    echo "${CFAILURE}ngx_lua_waf enable failed! ${CEND}"
  fi
  popd > /dev/null
}

disable_lua_waf() {
  pushd ${oneinstack_dir}/src > /dev/null
  . ../include/check_dir.sh
  sed -i '/include waf.conf;/d' ${web_install_dir}/conf/nginx.conf
  ${web_install_dir}/sbin/nginx -t
  if [ $? -eq 0 ]; then
    rm -rf ${web_install_dir}/conf/{waf,waf.conf}
    service nginx reload
    echo "${CSUCCESS}ngx_lua_waf disabled successfully! ${CEND}"
  else
    echo "${CFAILURE}ngx_lua_waf disable failed! ${CEND}"
  fi
  popd > /dev/null
}
