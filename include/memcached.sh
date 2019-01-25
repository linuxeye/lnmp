#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 7+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_memcached_server() {
  pushd ${oneinstack_dir}/src > /dev/null
  # memcached server
  id -u memcached >/dev/null 2>&1
  [ $? -ne 0 ] && useradd -M -s /sbin/nologin memcached

  tar xzf memcached-${memcached_ver}.tar.gz
  pushd memcached-${memcached_ver} > /dev/null
  [ ! -d "${memcached_install_dir}" ] && mkdir -p ${memcached_install_dir}
  [ "${PM}" == 'yum' ] && libevent_arg='--with-libevent=/usr/local'
  ./configure --prefix=${memcached_install_dir} ${libevent_arg}
  make -j ${THREAD} && make install
  popd > /dev/null
  if [ -f "${memcached_install_dir}/bin/memcached" ]; then
    echo "${CSUCCESS}memcached installed successfully! ${CEND}"
    rm -rf memcached-${memcached_ver}
    ln -s ${memcached_install_dir}/bin/memcached /usr/bin/memcached
    [ "${PM}" == 'yum' ] && { /bin/cp ../init.d/Memcached-init-CentOS /etc/init.d/memcached; chkconfig --add memcached; chkconfig memcached on; }
    [ "${PM}" == 'apt-get' ] && { /bin/cp ../init.d/Memcached-init-Ubuntu /etc/init.d/memcached; update-rc.d memcached defaults; }
    sed -i "s@/usr/local/memcached@${memcached_install_dir}@g" /etc/init.d/memcached
    let memcachedCache="${Mem}/8"
    [ -n "$(grep 'CACHESIZE=' /etc/init.d/memcached)" ] && sed -i "s@^CACHESIZE=.*@CACHESIZE=${memcachedCache}@" /etc/init.d/memcached
    [ -n "$(grep 'start_instance default 256;' /etc/init.d/memcached)" ] && sed -i "s@start_instance default 256;@start_instance default ${memcachedCache};@" /etc/init.d/memcached
    [ -e /bin/systemctl ] && systemctl daemon-reload
    service memcached start
    rm -rf memcached-${memcached_ver}
  else
    rm -rf ${memcached_install_dir}
    echo "${CFAILURE}memcached-server install failed, Please contact the author! ${CEND}"
    kill -9 $$
  fi
  popd > /dev/null
}

Install_pecl_memcache() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
    PHP_detail_ver=$(${php_install_dir}/bin/php-config --version)
    PHP_main_ver=${PHP_detail_ver%.*}
    if [[ "${PHP_main_ver}" =~ ^7.[0-3]$ ]]; then
      #git clone https://github.com/websupport-sk/pecl-memcache.git
      #cd pecl-memcache
      tar xzf pecl-memcache-php7.tgz
      pushd pecl-memcache-php7 > /dev/null
    else
      tar xzf memcache-${pecl_memcache_ver}.tgz
      pushd memcache-${pecl_memcache_ver} > /dev/null
    fi
    ${php_install_dir}/bin/phpize
    ./configure --with-php-config=${php_install_dir}/bin/php-config
    make -j ${THREAD} && make install
    popd > /dev/null
    if [ -f "${phpExtensionDir}/memcache.so" ]; then
      echo "extension=memcache.so" > ${php_install_dir}/etc/php.d/05-memcache.ini
      echo "${CSUCCESS}PHP memcache module installed successfully! ${CEND}"
      rm -rf pecl-memcache-php7 memcache-${pecl_memcache_ver}
    else
      echo "${CFAILURE}PHP memcache module install failed, Please contact the author! ${CEND}"
    fi
    popd > /dev/null
  fi
}

Install_pecl_memcached() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
    # php memcached extension
    tar xzf libmemcached-${libmemcached_ver}.tar.gz
    patch -d libmemcached-${libmemcached_ver} -p0 < libmemcached-build.patch
    pushd libmemcached-${libmemcached_ver} > /dev/null
    [ "${PM}" == 'yum' ] && yum -y install cyrus-sasl-devel
    [ "${PM}" == 'apt-get' ] && sed -i "s@lthread -pthread -pthreads@lthread -lpthread -pthreads@" ./configure
    ./configure --with-memcached=${memcached_install_dir}
    make -j ${THREAD} && make install
    popd > /dev/null
    rm -rf libmemcached-${libmemcached_ver}

    if [ "$(${php_install_dir}/bin/php-config --version | awk -F. '{print $1}')" == '7' ]; then
      tar xzf memcached-${pecl_memcached_ver}.tgz
      pushd memcached-${pecl_memcached_ver} > /dev/null
    else
      tar xzf memcached-${pecl_memcached_oldver}.tgz
      pushd memcached-${pecl_memcached_oldver} > /dev/null
    fi
    ${php_install_dir}/bin/phpize
    ./configure --with-php-config=${php_install_dir}/bin/php-config
    make -j ${THREAD} && make install
    popd > /dev/null
    if [ -f "${phpExtensionDir}/memcached.so" ]; then
      cat > ${php_install_dir}/etc/php.d/05-memcached.ini << EOF
extension=memcached.so
memcached.use_sasl=1
EOF
      echo "${CSUCCESS}PHP memcached module installed successfully! ${CEND}"
      rm -rf memcached-${pecl_memcached_oldver} memcached-${pecl_memcached_ver}
    else
      echo "${CFAILURE}PHP memcached module install failed, Please contact the author! ${CEND}"
    fi
    popd > /dev/null
  fi
}

Uninstall_pecl_memcache() {
  if [ -e "${php_install_dir}/etc/php.d/05-memcache.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/05-memcache.ini
    echo; echo "${CMSG}PHP memcache module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP memcache module does not exist! ${CEND}"
  fi
}

Uninstall_pecl_memcached() {
  if [ -e "${php_install_dir}/etc/php.d/05-memcached.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/05-memcached.ini
    echo; echo "${CMSG}PHP memcached module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP memcached module does not exist! ${CEND}"
  fi
}
