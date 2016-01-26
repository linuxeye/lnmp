#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       http://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Upgrade_PHP() {
cd $oneinstack_dir/src
[ ! -e "$php_install_dir" ] && echo "${CWARNING}The PHP is not installed on your system! ${CEND}" && exit 1
echo
OLD_PHP_version=`$php_install_dir/bin/php -r 'echo PHP_VERSION;'`
echo "Current PHP Version: ${CMSG}$OLD_PHP_version${CEND}"
while :
do
    echo
    read -p "Please input upgrade PHP Version: " NEW_PHP_version
    if [ "${NEW_PHP_version%.*}" == "${OLD_PHP_version%.*}" ]; then
        [ ! -e "php-$NEW_PHP_version.tar.gz" ] && wget --no-check-certificate -c http://www.php.net/distributions/php-$NEW_PHP_version.tar.gz > /dev/null 2>&1
        if [ -e "php-$NEW_PHP_version.tar.gz" ];then
            echo "Download [${CMSG}php-$NEW_PHP_version.tar.gz${CEND}] successfully! "
        else
            echo "${CWARNING}PHP version does not exist! ${CEND}"
        fi
        break
    else
        echo "${CWARNING}input error! ${CEND}Please only input '${CMSG}${OLD_PHP_version%.*}.xx${CEND}'"
    fi
done

if [ -e "php-$NEW_PHP_version.tar.gz" ];then
    echo "[${CMSG}php-$NEW_PHP_version.tar.gz${CEND}] found"
    echo "Press Ctrl+c to cancel or Press any key to continue..."
    char=`get_char`
    tar xzf php-$NEW_PHP_version.tar.gz
    src_url=http://mirrors.linuxeye.com/oneinstack/src/fpm-race-condition.patch && Download_src
    patch -d php-$NEW_PHP_version -p0 < fpm-race-condition.patch
    cd php-$NEW_PHP_version
    make clean
    $php_install_dir/bin/php -i |grep 'Configure Command' | awk -F'=>' '{print $2}' | bash
    make ZEND_EXTRA_LIBS='-liconv'
    echo "Stoping php-fpm..."
    service php-fpm stop
    make install
    cd ..
    echo "Starting php-fpm..."
    service php-fpm start
    echo "You have ${CMSG}successfully${CEND} upgrade from ${CWARNING}$OLD_PHP_version${CEND} to ${CWARNING}$NEW_PHP_version${CEND}"
fi
cd ..
}
