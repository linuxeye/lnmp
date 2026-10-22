#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com

Install_redis_server() {
  pushd ${current_dir}/src > /dev/null
  tar xzf redis-${redis_ver}.tar.gz
  pushd redis-${redis_ver} > /dev/null
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

    /bin/cp ../init.d/redis-server.service /lib/systemd/system/
    sed -i "s@/usr/local/redis@${redis_install_dir}@g" /lib/systemd/system/redis-server.service
    systemctl enable redis-server
    #[ -z "`grep 'vm.overcommit_memory' /etc/sysctl.conf`" ] && echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
    #sysctl -p
    systemctl start redis-server
  else
    rm -rf ${redis_install_dir}
    echo "${CFAILURE}Redis-server install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
    kill -9 $$; exit 1;
  fi
  popd > /dev/null
}

Install_pecl_redis() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${current_dir}/src > /dev/null
    phpExtensionDir=`${php_install_dir}/bin/php-config --extension-dir`
    if [ "$(${php_install_dir}/bin/php-config --version | awk -F. '{print $1}')" == '5' ]; then
      tar xzf redis-4.3.0.tgz
      pushd redis-4.3.0 > /dev/null
    elif [[ "$(${php_install_dir}/bin/php-config --version | awk -F. '{print $1$2}')" =~ ^7[0-1]$ ]]; then
      tar xzf redis-5.3.7.tgz
      pushd redis-5.3.7 > /dev/null
    elif [[ "$(${php_install_dir}/bin/php-config --version | awk -F. '{print $1$2}')" =~ ^7[2-3]$ ]]; then
      tar xzf redis-6.0.2.tgz
      pushd redis-6.0.2 > /dev/null
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
      rm -rf redis-${pecl_redis_ver} redis-4.3.0 redis-5.3.7 redis-6.0.2
    else
      echo "${CFAILURE}PHP Redis module install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
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
