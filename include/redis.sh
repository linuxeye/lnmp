#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_redis_server() {
  pushd ${oneinstack_dir}/src > /dev/null
  tar xzf redis-${redis_ver}.tar.gz
  pushd redis-${redis_ver} > /dev/null
  if [ "${OS_BIT}" == '32' -a "${armplatform}" != 'y' ]; then
    sed -i '1i\CFLAGS= -march=i686' src/Makefile
    sed -i 's@^OPT=.*@OPT=-O2 -march=i686@' src/.make-settings
  fi
  make -j ${THREAD}
  if [ -f "src/redis-server" ]; then
    mkdir -p ${redis_install_dir}/{bin,etc,var}
    /bin/cp src/{redis-benchmark,redis-check-aof,redis-check-rdb,redis-cli,redis-sentinel,redis-server} ${redis_install_dir}/bin/
    /bin/cp redis.conf ${redis_install_dir}/etc/
    ln -s ${redis_install_dir}/bin/* /usr/local/bin/
    sed -i 's@pidfile.*@pidfile /var/run/redis/redis.pid@' ${redis_install_dir}/etc/redis.conf
    sed -i "s@logfile.*@logfile ${redis_install_dir}/var/redis.log@" ${redis_install_dir}/etc/redis.conf
    sed -i "s@^dir.*@dir ${redis_install_dir}/var@" ${redis_install_dir}/etc/redis.conf
    sed -i 's@daemonize no@daemonize yes@' ${redis_install_dir}/etc/redis.conf
    sed -i "s@^# bind 127.0.0.1@bind 127.0.0.1@" ${redis_install_dir}/etc/redis.conf
    redis_maxmemory=`expr $Mem / 8`000000
    [ -z "`grep ^maxmemory ${redis_install_dir}/etc/redis.conf`" ] && sed -i "s@maxmemory <bytes>@maxmemory <bytes>\nmaxmemory `expr $Mem / 8`000000@" ${redis_install_dir}/etc/redis.conf
    echo "${CSUCCESS}Redis-server installed successfully! ${CEND}"
    popd > /dev/null
    rm -rf redis-${redis_ver}
    id -u redis >/dev/null 2>&1
    [ $? -ne 0 ] && useradd -M -s /sbin/nologin redis
    chown -R redis:redis ${redis_install_dir}/{var,etc}

    if [ -e /bin/systemctl ]; then
      /bin/cp ../init.d/redis-server.service /lib/systemd/system/
      sed -i "s@/usr/local/redis@${redis_install_dir}@g" /lib/systemd/system/redis-server.service
      systemctl enable redis-server
    else
      /bin/cp ../init.d/Redis-server-init /etc/init.d/redis-server
      sed -i "s@/usr/local/redis@${redis_install_dir}@g" /etc/init.d/redis-server
      [ "${PM}" == 'yum' ] && { cc start-stop-daemon.c -o /sbin/start-stop-daemon; chkconfig --add redis-server; chkconfig redis-server on; }
      [ "${PM}" == 'apt-get' ] && update-rc.d redis-server defaults
    fi
    #[ -z "`grep 'vm.overcommit_memory' /etc/sysctl.conf`" ] && echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
    #sysctl -p
    service redis-server start
  else
    rm -rf ${redis_install_dir}
    echo "${CFAILURE}Redis-server install failed, Please contact the author! ${CEND}" && lsb_release -a
    kill -9 $$
  fi
  popd > /dev/null
}

Install_pecl_redis() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    phpExtensionDir=`${php_install_dir}/bin/php-config --extension-dir`
    if [ "$(${php_install_dir}/bin/php-config --version | awk -F. '{print $1}')" == '5' ]; then
      tar xzf redis-${pecl_redis_oldver}.tgz
      pushd redis-${pecl_redis_oldver} > /dev/null
    else
      tar xzf redis-${pecl_redis_ver}.tgz
      pushd redis-${pecl_redis_ver} > /dev/null
    fi
    ${php_install_dir}/bin/phpize
    ./configure --with-php-config=${php_install_dir}/bin/php-config
    make -j ${THREAD} && make install
    popd > /dev/null
    if [ -f "${phpExtensionDir}/redis.so" ]; then
      echo 'extension=redis.so' > ${php_install_dir}/etc/php.d/05-redis.ini
      echo "${CSUCCESS}PHP Redis module installed successfully! ${CEND}"
      rm -rf redis-${pecl_redis_ver} redis-${pecl_redis_oldver}
    else
      echo "${CFAILURE}PHP Redis module install failed, Please contact the author! ${CEND}" && lsb_release -a
    fi
    popd > /dev/null
  fi
}

Uninstall_pecl_redis() {
  if [ -e "${php_install_dir}/etc/php.d/05-redis.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/05-redis.ini
    echo; echo "${CMSG}PHP redis module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP redis module does not exist! ${CEND}"
  fi
}
