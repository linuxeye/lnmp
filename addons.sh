#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#######################################################################
#       OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+      #
#                  Install/Uninstall PHP Extensions                   #
#       For more information please visit https://oneinstack.com      #
#######################################################################
"

# get pwd
sed -i "s@^oneinstack_dir.*@oneinstack_dir=`pwd`@" ./options.conf

. ./versions.txt
. ./options.conf
. ./include/color.sh
. ./include/memory.sh
. ./include/check_os.sh
. ./include/download.sh
. ./include/get_char.sh

. ./include/zendopcache.sh
. ./include/xcache.sh
. ./include/apcu.sh
. ./include/eaccelerator-0.9.sh
. ./include/eaccelerator-1.0-dev.sh

. ./include/ZendGuardLoader.sh
. ./include/ioncube.sh

. ./include/ImageMagick.sh
. ./include/GraphicsMagick.sh

. ./include/memcached.sh

. ./include/redis.sh

# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

# Check PHP
if [ -e "$php_install_dir/bin/phpize" ];then
    PHP_version=`$php_install_dir/bin/php -r 'echo PHP_VERSION;'`
    PHP_main_version=${PHP_version%.*}
fi

# Check PHP Extensions
Check_PHP_Extension() {
[ -e "$php_install_dir/etc/php.d/ext-${PHP_extension}.ini" ] && { echo "${CWARNING}PHP $PHP_extension module already installed! ${CEND}"; exit 1; }
}

# restart PHP
Restart_PHP() {
[ -e "$apache_install_dir/conf/httpd.conf" ] && /etc/init.d/httpd restart || /etc/init.d/php-fpm restart
}

# Check succ
Check_succ() {
[ -f "`$php_install_dir/bin/php-config --extension-dir`/${PHP_extension}.so" ] && { Restart_PHP; echo;echo "${CSUCCESS}PHP $PHP_extension module installed successfully! ${CEND}"; }
}

# Uninstall succ
Uninstall_succ() {
[ -e "$php_install_dir/etc/php.d/ext-${PHP_extension}.ini" ] && { rm -rf $php_install_dir/etc/php.d/ext-${PHP_extension}.ini; Restart_PHP; echo; echo "${CMSG}PHP $PHP_extension module uninstall completed${CEND}"; } || { echo; echo "${CWARNING}$PHP_extension module does not exist! ${CEND}"; }
}

# PHP 5.5,5,6,7.0 install opcache
Install_opcache() {
$php_install_dir/bin/phpize
./configure --with-php-config=$php_install_dir/bin/php-config
make -j ${THREAD} && make install
cat > $php_install_dir/etc/php.d/ext-opcache.ini << EOF
[opcache]
zend_extension=opcache.so
opcache.enable=1
opcache.memory_consumption=$Memory_limit
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.save_comments=0
opcache.fast_shutdown=1
opcache.enable_cli=1
;opcache.optimization_level=0
EOF
}

Install_letsencrypt() {
if [ "$CentOS_RHEL_version" == '7' ];then
    [ ! -e /etc/yum.repos.d/epel.repo ] && cat > /etc/yum.repos.d/epel.repo << EOF
[epel]
name=Extra Packages for Enterprise Linux 7 - \$basearch
#baseurl=http://download.fedoraproject.org/pub/epel/7/\$basearch
mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=\$basearch
failovermethod=priority
enabled=1
gpgcheck=0
EOF
elif [ "$CentOS_RHEL_version" == '6' ];then
    [ ! -e /etc/yum.repos.d/epel.repo ] && cat > /etc/yum.repos.d/epel.repo << EOF
[epel]
name=Extra Packages for Enterprise Linux 6 - \$basearch
#baseurl=http://download.fedoraproject.org/pub/epel/6/\$basearch
mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=\$basearch
failovermethod=priority
enabled=1
gpgcheck=0
EOF
fi

cd $oneinstack_dir/src
src_url=https://dl.eff.org/certbot-auto && Download_src
/bin/mv certbot-auto /usr/local/bin/
chmod +x /usr/local/bin/certbot-auto
certbot-auto -n
certbot-auto -h | grep '\-\-standalone' > /dev/null && echo; echo "${CSUCCESS}Let's Encrypt client installed successfully! ${CEND}"
}

Uninstall_letsencrypt() {
rm -rf /usr/local/bin/cerbot-auto /etc/letsencrypt /var/log/letsencrypt
[ "$OS" == 'CentOS' ] && Cron_file=/var/spool/cron/root || Cron_file=/var/spool/cron/crontabs/root
sed -i '/certbot-auto/d' $Cron_file
echo; echo "${CMSG}Let's Encrypt client uninstall completed${CEND}";
}

ACTION_FUN() {
while :; do
    echo
    echo 'Please select an action:'
    echo -e "\t${CMSG}1${CEND}. install"
    echo -e "\t${CMSG}2${CEND}. uninstall"
    read -p "Please input a number:(Default 1 press Enter) " ACTION
    [ -z "$ACTION" ] && ACTION=1
    if [[ ! $ACTION =~ ^[1,2]$ ]];then
        echo "${CWARNING}input error! Please only input number 1,2${CEND}"
    else
        break
    fi
done
}

while :;do
    printf "
What Are You Doing?
\t${CMSG}1${CEND}. Install/Uninstall PHP opcode cache
\t${CMSG}2${CEND}. Install/Uninstall ZendGuardLoader/ionCube PHP Extension
\t${CMSG}3${CEND}. Install/Uninstall ImageMagick/GraphicsMagick PHP Extension
\t${CMSG}4${CEND}. Install/Uninstall fileinfo PHP Extension
\t${CMSG}5${CEND}. Install/Uninstall memcached/memcache
\t${CMSG}6${CEND}. Install/Uninstall Redis
\t${CMSG}7${CEND}. Install/Uninstall Let's Encrypt client
\t${CMSG}q${CEND}. Exit
"
    read -p "Please input the correct option: " Number
    if [[ ! $Number =~ ^[1-7,q]$ ]];then
        echo "${CFAILURE}input error! Please only input 1 ~ 7 and q${CEND}"
    else
        case "$Number" in
        1)
            ACTION_FUN
            while :; do echo
                echo 'Please select a opcode cache of the PHP:'
                echo -e "\t${CMSG}1${CEND}. Zend OPcache"
                echo -e "\t${CMSG}2${CEND}. XCache"
                echo -e "\t${CMSG}3${CEND}. APCU"
                echo -e "\t${CMSG}4${CEND}. eAccelerator"
                read -p "Please input a number:(Default 1 press Enter) " PHP_cache
                [ -z "$PHP_cache" ] && PHP_cache=1
                if [[ ! $PHP_cache =~ ^[1-4]$ ]];then
                    echo "${CWARNING}input error! Please only input number 1,2,3,4${CEND}"
                else
                    [ $PHP_cache = 1 ] && PHP_extension=opcache
                    [ $PHP_cache = 2 ] && PHP_extension=xcache
                    [ $PHP_cache = 3 ] && PHP_extension=apcu
                    [ $PHP_cache = 4 ] && PHP_extension=eaccelerator
                    break
                fi
            done
            if [ $ACTION = 1 ];then
                Check_PHP_Extension
                if [ -e $php_install_dir/etc/php.d/ext-ZendGuardLoader.ini ];then
                    echo; echo "${CWARNING}You have to install ZendGuardLoader, You need to uninstall it before install $PHP_extension! ${CEND}"; echo; exit 1
                else
                    if [ $PHP_cache = 1 ];then
                        cd $oneinstack_dir/src
                        if [[ $PHP_main_version =~ ^5.[3-4]$ ]];then
                            Install_ZendOPcache
                        elif [ "$PHP_main_version" == '5.5' ];then
                            src_url=http://www.php.net/distributions/php-$php_5_version.tar.gz && Download_src
                            tar xzf php-$php_5_version.tar.gz
                            cd php-$php_5_version/ext/opcache
                            Install_opcache
                        elif [ "$PHP_main_version" == '5.6' ];then
                            src_url=http://www.php.net/distributions/php-$php_6_version.tar.gz && Download_src
                            tar xzf php-$php_6_version.tar.gz
                            cd php-$php_6_version/ext/opcache
                            Install_opcache
                        elif [ "$PHP_main_version" == '7.0' ];then
                            src_url=http://www.php.net/distributions/php-$php_7_version.tar.gz && Download_src
                            tar xzf php-$php_7_version.tar.gz
                            cd php-$php_7_version/ext/opcache
                            Install_opcache
                        fi
                        Check_succ
                    elif [ $PHP_cache = 2 ];then
                        if [[ $PHP_main_version =~ ^5.[3-6]$ ]];then
                            while :; do
                                read -p "Please input xcache admin password: " xcache_admin_pass
                                (( ${#xcache_admin_pass} >= 5 )) && { xcache_admin_md5_pass=`echo -n "$xcache_admin_pass" | md5sum | awk '{print $1}'` ; break ; } || echo "${CFAILURE}xcache admin password least 5 characters! ${CEND}"
                            done
                            Install_XCache
                            Check_succ
                        else
                            echo "${CWARNING}Your php does not support XCache! ${CEND}"; exit 1
                        fi
                    elif [ $PHP_cache = 3 ];then
                        if [[ $PHP_main_version =~ ^5.[3-5]$ ]];then
                            Install_APCU
                            Check_succ
                        else
                            echo "${CWARNING}Your php does not support APCU! ${CEND}"; exit 1
                        fi
                    elif [ $PHP_cache = 4 ];then
                        if [ "$PHP_main_version" == '5.3' ];then
                            Install_eAccelerator-0-9
                            Check_succ
                        elif [ "$PHP_main_version" == '5.4' ];then
                            Install_eAccelerator-1-0-dev
                            Check_succ
                        else
                            echo "${CWARNING}Your php does not support eAccelerator! ${CEND}"; exit 1
                        fi
                    fi
                fi
            else
                Uninstall_succ
            fi
            ;;
        2)
            ACTION_FUN
            while :; do echo
                echo 'Please select ZendGuardLoader/ionCube:'
                echo -e "\t${CMSG}1${CEND}. ZendGuardLoader"
                echo -e "\t${CMSG}2${CEND}. ionCube Loader"
                read -p "Please input a number:(Default 1 press Enter) " Loader
                [ -z "$Loader" ] && Loader=1
                if [[ ! $Loader =~ ^[1,2]$ ]];then
                    echo "${CWARNING}input error! Please only input number 1,2${CEND}"
                else
                    [ $Loader = 1 ] && PHP_extension=ZendGuardLoader
                    [ $Loader = 2 ] && PHP_extension=0ioncube
                    break
                fi
            done
            if [ $ACTION = 1 ];then
                Check_PHP_Extension
                if [[ $PHP_main_version =~ ^5.[3-6]$ ]];then
                    if [ $Loader = 1 ];then
                        if [ -e $php_install_dir/etc/php.d/ext-opcache.ini ];then
                            echo; echo "${CWARNING}You have to install OpCache, You need to uninstall it before install ZendGuardLoader! ${CEND}"; echo; exit 1
                        else
                            Install_ZendGuardLoader
                            Check_succ
                        fi
                    elif [ $Loader = 2 ];then
                        Install_ionCube
                        Restart_PHP; echo "${CSUCCESS}PHP ioncube module installed successfully! ${CEND}";
                    fi
                else
                    echo; echo "${CWARNING}Your php does not support $PHP_extension! ${CEND}";
                fi
            else
                Uninstall_succ
            fi
            ;;
        3)
            ACTION_FUN
            while :; do echo
                echo 'Please select ImageMagick/GraphicsMagick:'
                echo -e "\t${CMSG}1${CEND}. ImageMagick"
                echo -e "\t${CMSG}2${CEND}. GraphicsMagick"
                read -p "Please input a number:(Default 1 press Enter) " Magick
                [ -z "$Magick" ] && Magick=1
                if [[ ! $Magick =~ ^[1,2]$ ]];then
                    echo "${CWARNING}input error! Please only input number 1,2${CEND}"
                else
                    [ $Magick = 1 ] && PHP_extension=imagick
                    [ $Magick = 2 ] && PHP_extension=gmagick
                    break
                fi
            done
            if [ $ACTION = 1 ];then
                Check_PHP_Extension
                if [ $Magick = 1 ];then
                    [ ! -d "/usr/local/imagemagick" ] && Install_ImageMagick
                    Install_php-imagick
                    Check_succ
                elif [ $Magick = 2 ];then
                    [ ! -d "/usr/local/graphicsmagick" ] && Install_GraphicsMagick
                    Install_php-gmagick
                    Check_succ
                fi
            else
                Uninstall_succ
                [ -d "/usr/local/imagemagick" ] && rm -rf /usr/local/imagemagick
                [ -d "/usr/local/graphicsmagick" ] && rm -rf /usr/local/graphicsmagick
            fi
            ;;
        4)
            ACTION_FUN
            PHP_extension=fileinfo
            if [ $ACTION = 1 ];then
                Check_PHP_Extension
                cd $oneinstack_dir/src
                src_url=http://www.php.net/distributions/php-$PHP_version.tar.gz && Download_src
                tar xzf php-$PHP_version.tar.gz
                cd php-$PHP_version/ext/fileinfo
                $php_install_dir/bin/phpize
                ./configure --with-php-config=$php_install_dir/bin/php-config
                make -j ${THREAD} && make install
                echo 'extension=fileinfo.so' > $php_install_dir/etc/php.d/ext-fileinfo.ini
                Check_succ
            else
                Uninstall_succ
            fi
            ;;
        5)
            ACTION_FUN
            while :; do echo
                echo 'Please select memcache/memcached PHP Extension:'
                echo -e "\t${CMSG}1${CEND}. memcache PHP Extension"
                echo -e "\t${CMSG}2${CEND}. memcached PHP Extension"
                echo -e "\t${CMSG}3${CEND}. memcache/memcached PHP Extension"
                read -p "Please input a number:(Default 1 press Enter) " Memcache
                [ -z "$Memcache" ] && Memcache=1
                if [[ ! $Memcache =~ ^[1-3]$ ]];then
                    echo "${CWARNING}input error! Please only input number 1,2,3${CEND}"
                else
                    [ $Memcache = 1 ] && PHP_extension=memcache
                    [ $Memcache = 2 ] && PHP_extension=memcached
                    break
                fi
            done
            if [ $ACTION = 1 ];then
                if [ $Memcache = 1 ];then
                    [ ! -d "$memcached_install_dir/include/memcached" ] && Install_memcached
                    Check_PHP_Extension
                    Install_php-memcache
                    Check_succ
                elif [ $Memcache = 2 ];then
                    [ ! -d "$memcached_install_dir/include/memcached" ] && Install_memcached
                    Check_PHP_Extension
                    Install_php-memcached
                    Check_succ
                elif [ $Memcache = 3 ];then
                    [ ! -d "$memcached_install_dir/include/memcached" ] && Install_memcached
                    PHP_extension=memcache && Check_PHP_Extension
                    Install_php-memcache
                    PHP_extension=memcached && Check_PHP_Extension
                    Install_php-memcached
                    [ -f "`$php_install_dir/bin/php-config --extension-dir`/memcache.so" -a "`$php_install_dir/bin/php-config --extension-dir`/memcached.so" ] && { Restart_PHP; echo;echo "${CSUCCESS}PHP memcache/memcached module installed successfully! ${CEND}"; }
                fi
            else
                PHP_extension=memcache && Uninstall_succ
                PHP_extension=memcached && Uninstall_succ
                [ -e "$memcached_install_dir" ] && { service memcached stop > /dev/null 2>&1; rm -rf $memcached_install_dir /etc/init.d/memcached /usr/bin/memcached; }
            fi
            ;;
        6)
            ACTION_FUN
            PHP_extension=redis
            if [ $ACTION = 1 ];then
                [ ! -d "$redis_install_dir" ] && Install_redis-server
                Check_PHP_Extension
                Install_php-redis
            else
                Uninstall_succ
                [ -e "$redis_install_dir" ] && { service redis-server stop > /dev/null 2>&1; rm -rf $redis_install_dir /etc/init.d/redis-server /usr/local/bin/redis-*; }
            fi
            ;;
        7)
            ACTION_FUN
            if [ $ACTION = 1 ];then
                Install_letsencrypt
            else
                Uninstall_letsencrypt
            fi
            ;;
        q)
            exit
            ;;
        esac
    fi
done
