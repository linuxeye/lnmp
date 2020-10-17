#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 8+ and Ubuntu 14+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_PHP56() {
  pushd ${oneinstack_dir}/src > /dev/null
  if [ -e "${apache_install_dir}/bin/httpd" ];then
    [ "$(${apache_install_dir}/bin/httpd -v | awk -F'.' /version/'{print $2}')" == '4' ] && Apache_main_ver=24
    [ "$(${apache_install_dir}/bin/httpd -v | awk -F'.' /version/'{print $2}')" == '2' ] && Apache_main_ver=22
  fi
  if [ ! -e "${libiconv_install_dir}/lib/libiconv.la" ]; then
    tar xzf libiconv-${libiconv_ver}.tar.gz
    pushd libiconv-${libiconv_ver} > /dev/null
    ./configure --prefix=${libiconv_install_dir}
    make -j ${THREAD} && make install
    popd > /dev/null
    rm -rf libiconv-${libiconv_ver}
  fi

  if [ ! -e "${curl_install_dir}/lib/libcurl.la" ]; then
    tar xzf curl-${curl_ver}.tar.gz
    pushd curl-${curl_ver} > /dev/null
    [ "${Debian_ver}" == '8' ] && apt-get -y remove zlib1g-dev
    ./configure --prefix=${curl_install_dir} --with-ssl=${openssl_install_dir}
    make -j ${THREAD} && make install
    [ "${Debian_ver}" == '8' ] && apt-get -y install libc-client2007e-dev libglib2.0-dev libpng12-dev libssl-dev libzip-dev zlib1g-dev
    popd > /dev/null
    rm -rf curl-${curl_ver}
  fi

  if [ ! -e "${freetype_install_dir}/lib/libfreetype.la" ]; then
    tar xzf freetype-${freetype_ver}.tar.gz
    pushd freetype-${freetype_ver} > /dev/null
    ./configure --prefix=${freetype_install_dir} --enable-freetype-config
    make -j ${THREAD} && make install
    ln -sf ${freetype_install_dir}/include/freetype2/* /usr/include/
    [ -d /usr/lib/pkgconfig ] && /bin/cp ${freetype_install_dir}/lib/pkgconfig/freetype2.pc /usr/lib/pkgconfig/
    popd > /dev/null
    rm -rf freetype-${freetype_ver}
  fi

  if [ ! -e "/usr/local/bin/libmcrypt-config" -a ! -e "/usr/bin/libmcrypt-config" ]; then
    tar xzf libmcrypt-${libmcrypt_ver}.tar.gz
    pushd libmcrypt-${libmcrypt_ver} > /dev/null
    ./configure
    make -j ${THREAD} && make install
    ldconfig
    pushd libltdl > /dev/null
    ./configure --enable-ltdl-install
    make -j ${THREAD} && make install
    popd > /dev/null
    popd > /dev/null
    rm -rf libmcrypt-${libmcrypt_ver}
  fi

  if [ ! -e "/usr/local/include/mhash.h" -a ! -e "/usr/include/mhash.h" ]; then
    tar xzf mhash-${mhash_ver}.tar.gz
    pushd mhash-${mhash_ver} > /dev/null
    ./configure
    make -j ${THREAD} && make install
    popd > /dev/null
    rm -rf mhash-${mhash_ver}
  fi

  [ -z "`grep /usr/local/lib /etc/ld.so.conf.d/*.conf`" ] && echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
  ldconfig

  if [ "${PM}" == 'yum' ]; then
    [ ! -e "/usr/bin/libmcrypt-config" ] && ln -s /usr/local/bin/libmcrypt-config /usr/bin/libmcrypt-config
    if [ "${OS_BIT}" == '64' ]; then
      [ ! -e "/lib64/libpcre.so.1" ] && ln -s /lib64/libpcre.so.0.0.1 /lib64/libpcre.so.1
      [ ! -e "/usr/lib/libc-client.so" ] && ln -s /usr/lib64/libc-client.so /usr/lib/libc-client.so
    else
      [ ! -e "/lib/libpcre.so.1" ] && ln -s /lib/libpcre.so.0.0.1 /lib/libpcre.so.1
    fi
  fi

  if [ ! -e "/usr/local/bin/mcrypt" -a ! -e "/usr/bin/mcrypt" ]; then
    tar xzf mcrypt-${mcrypt_ver}.tar.gz
    pushd mcrypt-${mcrypt_ver} > /dev/null
    ldconfig
    ./configure
    make -j ${THREAD} && make install
    popd > /dev/null
    rm -rf mcrypt-${mcrypt_ver}
  fi

  id -g ${run_group} >/dev/null 2>&1
  [ $? -ne 0 ] && groupadd ${run_group}
  id -u ${run_user} >/dev/null 2>&1
  [ $? -ne 0 ] && useradd -g ${run_group} -M -s /sbin/nologin ${run_user}

  tar xzf php-${php56_ver}.tar.gz
  pushd php-${php56_ver} > /dev/null
  make clean
  [ ! -d "${php_install_dir}" ] && mkdir -p ${php_install_dir}
  { [ ${Debian_ver} -ge 10 >/dev/null 2>&1 ] || [ ${Ubuntu_ver} -ge 19 >/dev/null 2>&1 ]; } || intl_modules_options='--enable-intl'
  [ "${phpcache_option}" == '1' ] && phpcache_arg='--enable-opcache' || phpcache_arg='--disable-opcache'
  if [ "${apache_option}" == '2' ] || [ "${Apache_main_ver}" == '22' ] || [ "${apache_mode_option}" == '2' ]; then
    ./configure --prefix=${php_install_dir} --with-config-file-path=${php_install_dir}/etc \
    --with-config-file-scan-dir=${php_install_dir}/etc/php.d \
    --with-apxs2=${apache_install_dir}/bin/apxs ${phpcache_arg} --disable-fileinfo \
    --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
    --with-iconv-dir=${libiconv_install_dir} --with-freetype-dir=${freetype_install_dir} --with-jpeg-dir --with-png-dir --with-zlib \
    --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-exif \
    --enable-sysvsem --enable-inline-optimization --with-curl=${curl_install_dir} --enable-mbregex \
    --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl=${openssl_install_dir} \
    --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-ftp --with-xsl ${intl_modules_options} \
    --with-gettext --enable-zip --enable-soap --disable-debug ${php_modules_options}
  else
    ./configure --prefix=${php_install_dir} --with-config-file-path=${php_install_dir}/etc \
    --with-config-file-scan-dir=${php_install_dir}/etc/php.d \
    --with-fpm-user=${run_user} --with-fpm-group=${run_group} --enable-fpm ${phpcache_arg} --disable-fileinfo \
    --with-mysql=mysqlnd --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd \
    --with-iconv-dir=${libiconv_install_dir} --with-freetype-dir=${freetype_install_dir} --with-jpeg-dir --with-png-dir --with-zlib \
    --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-exif \
    --enable-sysvsem --enable-inline-optimization --with-curl=${curl_install_dir} --enable-mbregex \
    --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl=${openssl_install_dir} \
    --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-ftp --with-xsl ${intl_modules_options} \
    --with-gettext --enable-zip --enable-soap --disable-debug ${php_modules_options}
  fi
  make ZEND_EXTRA_LIBS='-liconv' -j ${THREAD}
  make install

  if [ -e "${php_install_dir}/bin/phpize" ]; then
    echo "${CSUCCESS}PHP installed successfully! ${CEND}"
  else
    rm -rf ${php_install_dir}
    echo "${CFAILURE}PHP install failed, Please Contact the author! ${CEND}"
    kill -9 $$
  fi

  [ -z "`grep ^'export PATH=' /etc/profile`" ] && echo "export PATH=${php_install_dir}/bin:\$PATH" >> /etc/profile
  [ -n "`grep ^'export PATH=' /etc/profile`" -a -z "`grep ${php_install_dir} /etc/profile`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=${php_install_dir}/bin:\1@" /etc/profile
  . /etc/profile

  # wget -c http://pear.php.net/go-pear.phar
  # ${php_install_dir}/bin/php go-pear.phar

  [ ! -e "${php_install_dir}/etc/php.d" ] && mkdir -p ${php_install_dir}/etc/php.d
  /bin/cp php.ini-production ${php_install_dir}/etc/php.ini

  sed -i "s@^memory_limit.*@memory_limit = ${Memory_limit}M@" ${php_install_dir}/etc/php.ini
  sed -i 's@^output_buffering =@output_buffering = On\noutput_buffering =@' ${php_install_dir}/etc/php.ini
  #sed -i 's@^;cgi.fix_pathinfo.*@cgi.fix_pathinfo=0@' ${php_install_dir}/etc/php.ini
  sed -i 's@^short_open_tag = Off@short_open_tag = On@' ${php_install_dir}/etc/php.ini
  sed -i 's@^expose_php = On@expose_php = Off@' ${php_install_dir}/etc/php.ini
  sed -i 's@^request_order.*@request_order = "CGP"@' ${php_install_dir}/etc/php.ini
  sed -i "s@^;date.timezone.*@date.timezone = ${timezone}@" ${php_install_dir}/etc/php.ini
  sed -i 's@^post_max_size.*@post_max_size = 100M@' ${php_install_dir}/etc/php.ini
  sed -i 's@^upload_max_filesize.*@upload_max_filesize = 50M@' ${php_install_dir}/etc/php.ini
  sed -i 's@^max_execution_time.*@max_execution_time = 5@' ${php_install_dir}/etc/php.ini
  sed -i 's@^disable_functions.*@disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,readlink,symlink,popepassthru,stream_socket_server,fsocket,popen@' ${php_install_dir}/etc/php.ini
  [ -e /usr/sbin/sendmail ] && sed -i 's@^;sendmail_path.*@sendmail_path = /usr/sbin/sendmail -t -i@' ${php_install_dir}/etc/php.ini
  sed -i "s@^;curl.cainfo.*@curl.cainfo = \"${openssl_install_dir}/cert.pem\"@" ${php_install_dir}/etc/php.ini
  sed -i "s@^;openssl.cafile.*@openssl.cafile = \"${openssl_install_dir}/cert.pem\"@" ${php_install_dir}/etc/php.ini
  sed -i "s@^;openssl.capath.*@openssl.capath = \"${openssl_install_dir}/cert.pem\"@" ${php_install_dir}/etc/php.ini

  [ "${phpcache_option}" == '1' ] && cat > ${php_install_dir}/etc/php.d/02-opcache.ini << EOF
[opcache]
zend_extension=opcache.so
opcache.enable=1
opcache.memory_consumption=${Memory_limit}
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
;opcache.save_comments=0
opcache.fast_shutdown=1
opcache.enable_cli=1
;opcache.optimization_level=0
EOF

  if [ ! -e "${apache_install_dir}/bin/apxs" -o "${Apache_main_ver}" == '24' ] && [ "${apache_mode_option}" != '2' ]; then
    # php-fpm Init Script
    if [ -e /bin/systemctl ]; then
      /bin/cp ${oneinstack_dir}/init.d/php-fpm.service /lib/systemd/system/
      sed -i "s@/usr/local/php@${php_install_dir}@g" /lib/systemd/system/php-fpm.service
      systemctl enable php-fpm
    else
      /bin/cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
      chmod +x /etc/init.d/php-fpm
      [ "${PM}" == 'yum' ] && { chkconfig --add php-fpm; chkconfig php-fpm on; }
      [ "${PM}" == 'apt-get' ] && update-rc.d php-fpm defaults
    fi

    cat > ${php_install_dir}/etc/php-fpm.conf <<EOF
;;;;;;;;;;;;;;;;;;;;;
; FPM Configuration ;
;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;
; Global Options ;
;;;;;;;;;;;;;;;;;;

[global]
pid = run/php-fpm.pid
error_log = log/php-fpm.log
log_level = warning

emergency_restart_threshold = 30
emergency_restart_interval = 60s
process_control_timeout = 5s
daemonize = yes

;;;;;;;;;;;;;;;;;;;;
; Pool Definitions ;
;;;;;;;;;;;;;;;;;;;;

[${run_user}]
listen = /dev/shm/php-cgi.sock
listen.backlog = -1
listen.allowed_clients = 127.0.0.1
listen.owner = ${run_user}
listen.group = ${run_group}
listen.mode = 0666
user = ${run_user}
group = ${run_group}

pm = dynamic
pm.max_children = 12
pm.start_servers = 8
pm.min_spare_servers = 6
pm.max_spare_servers = 12
pm.max_requests = 2048
pm.process_idle_timeout = 10s
request_terminate_timeout = 120
request_slowlog_timeout = 0

pm.status_path = /php-fpm_status
slowlog = var/log/slow.log
rlimit_files = 51200
rlimit_core = 0

catch_workers_output = yes
;env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp
EOF

    if [ $Mem -le 3000 ]; then
      sed -i "s@^pm.max_children.*@pm.max_children = $(($Mem/3/20))@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.start_servers.*@pm.start_servers = $(($Mem/3/30))@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = $(($Mem/3/40))@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = $(($Mem/3/20))@" ${php_install_dir}/etc/php-fpm.conf
    elif [ $Mem -gt 3000 -a $Mem -le 4500 ]; then
      sed -i "s@^pm.max_children.*@pm.max_children = 50@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.start_servers.*@pm.start_servers = 30@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 20@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 50@" ${php_install_dir}/etc/php-fpm.conf
    elif [ $Mem -gt 4500 -a $Mem -le 6500 ]; then
      sed -i "s@^pm.max_children.*@pm.max_children = 60@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.start_servers.*@pm.start_servers = 40@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 30@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 60@" ${php_install_dir}/etc/php-fpm.conf
    elif [ $Mem -gt 6500 -a $Mem -le 8500 ]; then
      sed -i "s@^pm.max_children.*@pm.max_children = 70@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.start_servers.*@pm.start_servers = 50@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 40@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 70@" ${php_install_dir}/etc/php-fpm.conf
    elif [ $Mem -gt 8500 ]; then
      sed -i "s@^pm.max_children.*@pm.max_children = 80@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.start_servers.*@pm.start_servers = 60@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.min_spare_servers.*@pm.min_spare_servers = 50@" ${php_install_dir}/etc/php-fpm.conf
      sed -i "s@^pm.max_spare_servers.*@pm.max_spare_servers = 80@" ${php_install_dir}/etc/php-fpm.conf
    fi

    service php-fpm start

  elif [ "${apache_option}" == '2' ] || [ "${Apache_main_ver}" == '22' ] || [ "${apache_mode_option}" == '2' ]; then
    service httpd restart
  fi
  popd > /dev/null
  [ -e "${php_install_dir}/bin/phpize" ] && rm -rf php-${php56_ver}
  popd > /dev/null
}
