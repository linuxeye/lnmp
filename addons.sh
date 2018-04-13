#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 7+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
clear
printf "
#######################################################################
#       OneinStack for CentOS/RadHat 6+ Debian 7+ and Ubuntu 12+      #
#                    Install/Uninstall Extensions                     #
#       For more information please visit https://oneinstack.com      #
#######################################################################
"
# Check if user is root
[ $(id -u) != '0' ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

oneinstack_dir=$(dirname "`readlink -f $0`")
pushd ${oneinstack_dir} > /dev/null

# get the IP information
PUBLIC_IPADDR=`./include/get_public_ipaddr.py`
IPADDR_COUNTRY=`./include/get_ipaddr_state.py $PUBLIC_IPADDR | awk '{print $1}'`

. ./versions.txt
. ./options.conf
. ./include/color.sh
. ./include/memory.sh
. ./include/check_os.sh
. ./include/check_download.sh
. ./include/download.sh
. ./include/get_char.sh

. ./include/zendopcache.sh
. ./include/xcache.sh
. ./include/apcu.sh
. ./include/eaccelerator.sh

. ./include/ZendGuardLoader.sh
. ./include/ioncube.sh

. ./include/ImageMagick.sh
. ./include/GraphicsMagick.sh

. ./include/memcached.sh

. ./include/redis.sh

. ./include/python.sh

# Check PHP
if [ -e "${php_install_dir}/bin/phpize" ]; then
  phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
  PHP_detail_ver=$(${php_install_dir}/bin/php -r 'echo PHP_VERSION;')
  PHP_main_ver=${PHP_detail_ver%.*}
fi

# Check PHP Extensions
Check_PHP_Extension() {
  [ ! -e "${php_install_dir}/bin/phpize" ] && { echo "${CWARNING}PHP was not exist! ${CEND}"; exit 1; }
  [ -e "`ls ${php_install_dir}/etc/php.d/0?-${PHP_extension}.ini 2> /dev/null`" ] && { echo "${CWARNING}PHP ${PHP_extension} module already installed! ${CEND}"; exit 1; }
}

# restart PHP
Restart_PHP() {
  [ -e "${apache_install_dir}/conf/httpd.conf" ] && /etc/init.d/httpd restart || /etc/init.d/php-fpm restart
}

# Check succ
Check_succ() {
  [ -f "${phpExtensionDir}/${PHP_extension}.so" ] && { Restart_PHP; echo;echo "${CSUCCESS}PHP ${PHP_extension} module installed successfully! ${CEND}"; }
}

# Uninstall succ
Uninstall_succ() {
  [ -e "`ls ${php_install_dir}/etc/php.d/0?-${PHP_extension}.ini 2> /dev/null`" ] && { rm -rf ${php_install_dir}/etc/php.d/0?-${PHP_extension}.ini; Restart_PHP; echo; echo "${CMSG}PHP ${PHP_extension} module uninstall completed${CEND}"; } || { echo; echo "${CWARNING}${PHP_extension} module does not exist! ${CEND}"; }
}

Install_fail2ban() {
  [ ! -e "${python_install_dir}/bin/python" ] && Install_Python
  pushd ${oneinstack_dir}/src > /dev/null
  src_url=http://mirrors.linuxeye.com/oneinstack/src/fail2ban-${fail2ban_ver}.tar.gz && Download_src
  tar xzf fail2ban-${fail2ban_ver}.tar.gz
  pushd fail2ban-${fail2ban_ver}
  ${python_install_dir}/bin/python setup.py install
  if [ "${OS}" == "CentOS" ]; then
    LOGPATH=/var/log/secure
    /bin/cp files/redhat-initd /etc/init.d/fail2ban
    sed -i "s@^FAIL2BAN=.*@FAIL2BAN=${python_install_dir}/bin/fail2ban-client@" /etc/init.d/fail2ban
    sed -i 's@Starting fail2ban.*@&\n    [ ! -e "/var/run/fail2ban" ] \&\& mkdir /var/run/fail2ban@' /etc/init.d/fail2ban
    chmod +x /etc/init.d/fail2ban
    chkconfig --add fail2ban
    chkconfig fail2ban on
  fi
  if [[ "${OS}" =~ ^Ubuntu$|^Debian$ ]]; then
    LOGPATH=/var/log/auth.log
    /bin/cp files/debian-initd /etc/init.d/fail2ban
    sed -i 's@2 3 4 5@3 4 5@' /etc/init.d/fail2ban
    sed -i "s@^DAEMON=.*@DAEMON=${python_install_dir}/bin/\$NAME-client@" /etc/init.d/fail2ban
    chmod +x /etc/init.d/fail2ban
    update-rc.d fail2ban defaults
  fi
  [ -z "`grep ^Port /etc/ssh/sshd_config`" ] && now_ssh_port=22 || now_ssh_port=`grep ^Port /etc/ssh/sshd_config | awk '{print $2}' | head -1`
  cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
ignoreip = 127.0.0.1/8
bantime  = 86400
findtime = 600
maxretry = 5
[ssh-iptables]
enabled = true
filter  = sshd
action  = iptables[name=SSH, port=$now_ssh_port, protocol=tcp]
logpath = $LOGPATH
EOF
  cat > /etc/logrotate.d/fail2ban << EOF
/var/log/fail2ban.log {
    missingok
    notifempty
    postrotate
      ${python_install_dir}/bin/fail2ban-client flushlogs >/dev/null || true
    endscript
}
EOF
  sed -i 's@^iptables = iptables.*@iptables = iptables@' /etc/fail2ban/action.d/iptables-common.conf
  kill -9 `ps -ef | grep fail2ban | grep -v grep | awk '{print $2}'` > /dev/null 2>&1
  /etc/init.d/fail2ban start
  popd
  if [ -e "${python_install_dir}/bin/fail2ban-python" ]; then
    echo; echo "${CSUCCESS}fail2ban installed successfully! ${CEND}"
  else
    echo; echo "${CFAILURE}fail2ban install failed, Please try again! ${CEND}"
  fi
  popd
}

Uninstall_fail2ban() {
  /etc/init.d/fail2ban stop
  ${python_install_dir}/bin/pip uninstall -y fail2ban > /dev/null 2>&1
  rm -rf /etc/init.d/fail2ban /etc/fail2ban /etc/logrotate.d/fail2ban /var/log/fail2ban.* /var/run/fail2ban
  echo; echo "${CMSG}fail2ban uninstall completed${CEND}";
}

ACTION_FUN() {
  while :; do
    echo
    echo "Please select an action:"
    echo -e "\t${CMSG}1${CEND}. install"
    echo -e "\t${CMSG}2${CEND}. uninstall"
    read -p "Please input a number:(Default 1 press Enter) " ACTION
    [ -z "${ACTION}" ] && ACTION=1
    if [[ ! "${ACTION}" =~ ^[1,2]$ ]]; then
      echo "${CWARNING}input error! Please only input number 1~2${CEND}"
    else
      break
    fi
  done
}

while :;do
  printf "
What Are You Doing?
\t${CMSG} 1${CEND}. Install/Uninstall PHP opcode cache
\t${CMSG} 2${CEND}. Install/Uninstall ZendGuardLoader/ionCube PHP Extension
\t${CMSG} 3${CEND}. Install/Uninstall ImageMagick/GraphicsMagick PHP Extension
\t${CMSG} 4${CEND}. Install/Uninstall fileinfo PHP Extension
\t${CMSG} 5${CEND}. Install/Uninstall memcached/memcache
\t${CMSG} 6${CEND}. Install/Uninstall Redis
\t${CMSG} 7${CEND}. Install/Uninstall swoole PHP Extension
\t${CMSG} 8${CEND}. Install/Uninstall xdebug PHP Extension
\t${CMSG} 9${CEND}. Install/Uninstall PHP Composer
\t${CMSG}10${CEND}. Install/Uninstall fail2ban
\t${CMSG} q${CEND}. Exit
"
  read -p "Please input the correct option: " Number
  if [[ ! "${Number}" =~ ^[1-9,q]$|^10$ ]]; then
    echo "${CFAILURE}input error! Please only input 1~10 and q${CEND}"
  else
    case "${Number}" in
      1)
        ACTION_FUN
        while :; do echo
          echo "Please select a opcode cache of the PHP:"
          echo -e "\t${CMSG}1${CEND}. Zend OPcache"
          echo -e "\t${CMSG}2${CEND}. XCache"
          echo -e "\t${CMSG}3${CEND}. APCU"
          echo -e "\t${CMSG}4${CEND}. eAccelerator"
          read -p "Please input a number:(Default 1 press Enter) " phpcache_option
          [ -z "${phpcache_option}" ] && phpcache_option=1
          if [[ ! "${phpcache_option}" =~ ^[1-4]$ ]]; then
            echo "${CWARNING}input error! Please only input number 1~4${CEND}"
          else
            case "${phpcache_option}" in
              1)
                PHP_extension=opcache
                ;;
              2)
                PHP_extension=xcache
                ;;
              3)
                PHP_extension=apcu
                ;;
              4)
                PHP_extension=eaccelerator
                ;;
            esac
            break
          fi
        done
        if [ "${ACTION}" = '1' ]; then
          Check_PHP_Extension
          case "${phpcache_option}" in
            1)
              pushd ${oneinstack_dir}/src > /dev/null
              if [[ "${PHP_main_ver}" =~ ^5.[3-4]$ ]]; then
                src_url=https://pecl.php.net/get/zendopcache-${zendopcache_ver}.tgz && Download_src
                Install_ZendOPcache
              else
                src_url=http://www.php.net/distributions/php-${PHP_detail_ver}.tar.gz && Download_src
                Install_ZendOPcache
              fi
              popd
              Check_succ
              ;;
            2)
              if [[ "${PHP_main_ver}" =~ ^5.[3-6]$ ]]; then
                while :; do
                  read -p "Please input xcache admin password: " xcachepwd
                  (( ${#xcachepwd} >= 5 )) && { xcachepwd_md5=$(echo -n "${xcachepwd}" | md5sum | awk '{print $1}') ; break ; } || echo "${CFAILURE}xcache admin password least 5 characters! ${CEND}"
                done
                checkDownload
                Install_XCache
                Check_succ
              else
                echo "${CWARNING}Your php does not support XCache! ${CEND}"; exit 1
              fi
              ;;
            3)
              if [[ "${PHP_main_ver}" =~ ^5.[3-6]$|^7.[0-2]$ ]]; then
                checkDownload
                Install_APCU
                Check_succ
              else
                echo "${CWARNING}Your php does not support APCU! ${CEND}"; exit 1
              fi
              ;;
            4)
              if [[ "${PHP_main_ver}" =~ ^5.[3-4]$ ]]; then
                checkDownload
                Install_eAccelerator
                Check_succ
              else
                echo "${CWARNING}Your php does not support eAccelerator! ${CEND}"; exit 1
              fi
              ;;
          esac
        else
          Uninstall_succ
        fi
        ;;
      2)
        ACTION_FUN
        while :; do echo
          echo "Please select ZendGuardLoader/ionCube:"
          echo -e "\t${CMSG}1${CEND}. ZendGuardLoader"
          echo -e "\t${CMSG}2${CEND}. ionCube Loader"
          read -p "Please input a number:(Default 1 press Enter) " Loader
          [ -z "${Loader}" ] && Loader=1
          if [[ ! "${Loader}" =~ ^[1,2]$ ]]; then
            echo "${CWARNING}input error! Please only input number 1~2${CEND}"
          else
            [ "${Loader}" = '1' ] && PHP_extension=ZendGuardLoader
            [ "${Loader}" = '2' ] && PHP_extension=ioncube
            break
          fi
        done
        if [ "${ACTION}" = '1' ]; then
          Check_PHP_Extension
          if [ "${Loader}" = '1' ]; then
            if [[ "${PHP_main_ver}" =~ ^5.[3-6]$ ]] && [ "${armplatform}" != 'y' ]; then
              zendguardloader_yn='y' && checkDownload
              Install_ZendGuardLoader
              Check_succ
            else
              echo; echo "${CWARNING}Your php ${PHP_detail_ver} or platform ${TARGET_ARCH} does not support ${PHP_extension}! ${CEND}";
            fi
          elif [ "${Loader}" = '2' ]; then
            if [[ "${PHP_main_ver}" =~ ^5.[3-6]$|^7.[0-2]$ ]] || [ "${TARGET_ARCH}" != "arm64" ]; then
              ioncube_yn='y' && checkDownload
              Install_ionCube
              Restart_PHP; echo "${CSUCCESS}PHP ioncube module installed successfully! ${CEND}";
            else
              echo; echo "${CWARNING}Your php ${PHP_detail_ver} or platform ${TARGET_ARCH} does not support ${PHP_extension}! ${CEND}";
            fi
          fi
        else
          Uninstall_succ
        fi
        ;;
      3)
        ACTION_FUN
        while :; do echo
          echo "Please select ImageMagick/GraphicsMagick:"
          echo -e "\t${CMSG}1${CEND}. ImageMagick"
          echo -e "\t${CMSG}2${CEND}. GraphicsMagick"
          read -p "Please input a number:(Default 1 press Enter) " magick_option
          [ -z "${magick_option}" ] && magick_option=1
          if [[ ! "${magick_option}" =~ ^[1,2]$ ]]; then
            echo "${CWARNING}input error! Please only input number 1~2${CEND}"
          else
            [ "${magick_option}" = '1' ] && PHP_extension=imagick
            [ "${magick_option}" = '2' ] && PHP_extension=gmagick
            break
          fi
        done
        if [ "${ACTION}" = '1' ]; then
          Check_PHP_Extension
          magick_yn=y && checkDownload
          if [ "${magick_option}" = '1' ]; then
            [ ! -d "${imagick_install_dir}" ] && Install_ImageMagick
            Install_php-imagick
            Check_succ
          elif [ "${magick_option}" = '2' ]; then
            [ ! -d "${gmagick_install_dir}" ] && Install_GraphicsMagick
            Install_php-gmagick
            Check_succ
          fi
        else
          Uninstall_succ
          [ -d "${imagick_install_dir}" ] && rm -rf ${imagick_install_dir}
          [ -d "${gmagick_install_dir}" ] && rm -rf ${gmagick_install_dir}
        fi
        ;;
      4)
        ACTION_FUN
        PHP_extension=fileinfo
        if [ "${ACTION}" = '1' ]; then
          Check_PHP_Extension
          pushd ${oneinstack_dir}/src > /dev/null
          src_url=http://www.php.net/distributions/php-${PHP_detail_ver}.tar.gz && Download_src
          tar xzf php-${PHP_detail_ver}.tar.gz
          pushd php-${PHP_detail_ver}/ext/fileinfo
          ${php_install_dir}/bin/phpize
          ./configure --with-php-config=${php_install_dir}/bin/php-config
          make -j ${THREAD} && make install
          popd;popd
          rm -rf php-${PHP_detail_ver}
          echo "extension=fileinfo.so" > ${php_install_dir}/etc/php.d/04-fileinfo.ini
          Check_succ
        else
          Uninstall_succ
        fi
        ;;
      5)
        ACTION_FUN
        while :; do echo
          echo "Please select memcache/memcached PHP Extension:"
          echo -e "\t${CMSG}1${CEND}. memcache PHP Extension"
          echo -e "\t${CMSG}2${CEND}. memcached PHP Extension"
          echo -e "\t${CMSG}3${CEND}. memcache/memcached PHP Extension"
          read -p "Please input a number:(Default 1 press Enter) " Memcache
          [ -z "${Memcache}" ] && Memcache=1
          if [[ ! "${Memcache}" =~ ^[1-3]$ ]]; then
            echo "${CWARNING}input error! Please only input number 1~3${CEND}"
          else
            [ "${Memcache}" = '1' ] && PHP_extension=memcache
            [ "${Memcache}" = '2' ] && PHP_extension=memcached
            break
          fi
        done
        if [ "${ACTION}" = '1' ]; then
          memcached_yn=y && checkDownload
          case "${Memcache}" in
            1)
              [ ! -d "${memcached_install_dir}/include/memcached" ] && Install_memcached
              Check_PHP_Extension
              Install_php-memcache
              Check_succ
              ;;
            2)
              [ ! -d "${memcached_install_dir}/include/memcached" ] && Install_memcached
              Check_PHP_Extension
              Install_php-memcached
              Check_succ
              ;;
            3)
              [ ! -d "${memcached_install_dir}/include/memcached" ] && Install_memcached
              PHP_extension=memcache && Check_PHP_Extension
              Install_php-memcache
              PHP_extension=memcached && Check_PHP_Extension
              Install_php-memcached
              [ -f "${phpExtensionDir}/memcache.so" -a "${phpExtensionDir}/memcached.so" ] && { Restart_PHP; echo;echo "${CSUCCESS}PHP memcache/memcached module installed successfully! ${CEND}"; }
              ;;
          esac
        else
          PHP_extension=memcache && Uninstall_succ
          PHP_extension=memcached && Uninstall_succ
          [ -e "${memcached_install_dir}" ] && { service memcached stop > /dev/null 2>&1; rm -rf ${memcached_install_dir} /etc/init.d/memcached /usr/bin/memcached; }
        fi
        ;;
      6)
        ACTION_FUN
        PHP_extension=redis
        redis_yn=y && checkDownload
        if [ "${ACTION}" = '1' ]; then
          [ ! -d "${redis_install_dir}" ] && Install_redis-server
          Check_PHP_Extension
          Install_php-redis
        else
          Uninstall_succ
          [ -e "${redis_install_dir}" ] && { service redis-server stop > /dev/null 2>&1; rm -rf ${redis_install_dir} /etc/init.d/redis-server /usr/local/bin/redis-*; }
        fi
        ;;
      7)
        ACTION_FUN
        PHP_extension=swoole
        if [ "${ACTION}" = '1' ]; then
          Check_PHP_Extension
          pushd ${oneinstack_dir}/src > /dev/null
          if [[ "${PHP_main_ver}" =~ ^7\.[0-2]$ ]]; then
            src_url=https://pecl.php.net/get/swoole-${swoole_ver}.tgz && Download_src
            tar xzf swoole-${swoole_ver}.tgz
            pushd swoole-${swoole_ver}
          else
            src_url=https://pecl.php.net/get/swoole-1.10.4.tgz && Download_src
            tar xzf swoole-1.10.4.tgz
            pushd swoole-1.10.4
          fi
          ${php_install_dir}/bin/phpize
          ./configure --with-php-config=${php_install_dir}/bin/php-config
          make -j ${THREAD} && make install
          popd
          rm -rf swoole-${swoole_ver}
          popd
          echo 'extension=swoole.so' > ${php_install_dir}/etc/php.d/06-swoole.ini
          Check_succ
        else
          Uninstall_succ
        fi
        ;;
      8)
        ACTION_FUN
        PHP_extension=xdebug
        if [ "${ACTION}" = '1' ]; then
          Check_PHP_Extension
          pushd ${oneinstack_dir}/src > /dev/null
          if [[ "${PHP_main_ver}" =~ ^7\.[0-2]$ ]]; then
            src_url=https://pecl.php.net/get/xdebug-${xdebug_ver}.tgz && Download_src
            src_url=http://mirrors.linuxeye.com/oneinstack/src/webgrind-master.zip && Download_src
            tar xzf xdebug-${xdebug_ver}.tgz
            unzip -q webgrind-master.zip
            /bin/mv webgrind-master ${wwwroot_dir}/default/webgrind
            pushd xdebug-${xdebug_ver}
          elif [[ "${PHP_main_ver}" =~ ^5\.[5-6]$ ]]; then
            src_url=https://pecl.php.net/get/xdebug-2.5.5.tgz && Download_src
            src_url=http://mirrors.linuxeye.com/oneinstack/src/webgrind-master.zip && Download_src
            tar xzf xdebug-2.5.5.tgz
            unzip -q webgrind-master.zip
            /bin/mv webgrind-master ${wwwroot_dir}/default/webgrind
            pushd xdebug-2.5.5
          else
            echo "${CWARNING}Need a PHP version >= 5.5.0 and <= 7.2.0${CEND}"
            exit 1
          fi
          ${php_install_dir}/bin/phpize
          ./configure --with-php-config=${php_install_dir}/bin/php-config
          make -j ${THREAD} && make install
          popd
          rm -rf xdebug-${xdebug_ver}
          popd
          [ ! -e /tmp/xdebug ] && { mkdir /tmp/xdebug; chown ${run_user}.${run_user} /tmp/xdebug; }
          [ ! -e /tmp/webgrind ] && { mkdir /tmp/webgrind; chown ${run_user}.${run_user} /tmp/webgrind; }
          chown -R ${run_user}.${run_user} ${wwwroot_dir}/default/webgrind
          sed -i 's@static $storageDir.*@static $storageDir = "/tmp/webgrind";@' ${wwwroot_dir}/default/webgrind/config.php
          sed -i 's@static $profilerDir.*@static $profilerDir = "/tmp/xdebug";@' ${wwwroot_dir}/default/webgrind/config.php
          cat > ${php_install_dir}/etc/php.d/08-xdebug.ini << EOF
[xdebug]
zend_extension=xdebug.so
xdebug.trace_output_dir=/tmp/xdebug
xdebug.profiler_output_dir = /tmp/xdebug
xdebug.profiler_enable = On
xdebug.profiler_enable_trigger = 1
EOF
          Check_succ
          echo; echo "Webgrind URL: ${CMSG}http://{Public IP}/webgrind ${CEND}"
        else
          rm -rf /tmp/{xdebug,webgrind} ${wwwroot_dir}/default/webgrind
          Uninstall_succ
        fi
        ;;
      9)
        ACTION_FUN
        if [ "${ACTION}" = '1' ]; then
          [ -e "/usr/local/bin/composer" ] && { echo "${CWARNING}PHP Composer already installed! ${CEND}"; exit 1; }
          if [ "$IPADDR_COUNTRY"x == "CN"x ]; then
            wget -c https://dl.laravel-china.org/composer.phar -O /usr/local/bin/composer > /dev/null 2>&1
            ${php_install_dir}/bin/php /usr/local/bin/composer config -g repo.packagist composer https://packagist.phpcomposer.com
          else
            wget -c https://getcomposer.org/composer.phar -O /usr/local/bin/composer > /dev/null 2>&1
          fi
          chmod +x /usr/local/bin/composer
          if [ -e "/usr/local/bin/composer" ]; then
            echo; echo "${CSUCCESS}Composer installed successfully! ${CEND}"
          else
            echo; echo "${CFAILURE}Composer install failed, Please try again! ${CEND}"
          fi
        else
          rm -rf /usr/local/bin/composer
          echo; echo "${CMSG}composer uninstall completed${CEND}";
        fi
        ;;
      10)
        ACTION_FUN
        if [ "${ACTION}" = '1' ]; then
          Install_fail2ban
        else
          Uninstall_fail2ban
        fi
        ;;
      q)
        exit
        ;;
    esac
  fi
done
