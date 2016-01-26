#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       http://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Upgrade_phpMyAdmin() {
cd $oneinstack_dir/src
[ ! -e "$wwwroot_dir/default/phpMyAdmin" ] && echo "${CWARNING}The phpMyAdmin is not installed on your system! ${CEND}" && exit 1
OLD_phpMyAdmin_version=`grep Version $wwwroot_dir/default/phpMyAdmin/README | awk '{print $2}'`
echo "Current phpMyAdmin Version: ${CMSG}$OLD_phpMyAdmin_version${CEND}"

while :
do
    echo
    read -p "Please input upgrade phpMyAdmin Version(example: 4.4.15): " NEW_phpMyAdmin_version
    if [ "$NEW_phpMyAdmin_version" != "$OLD_phpMyAdmin_version" ];then
        [ ! -e "phpMyAdmin-${NEW_phpMyAdmin_version}-all-languages.tar.gz" ] && wget --no-check-certificate -c https://files.phpmyadmin.net/phpMyAdmin/$NEW_phpMyAdmin_version/phpMyAdmin-${NEW_phpMyAdmin_version}-all-languages.tar.gz > /dev/null 2>&1
        if [ -e "phpMyAdmin-${NEW_phpMyAdmin_version}-all-languages.tar.gz" ];then
            echo "Download [${CMSG}phpMyAdmin-${NEW_phpMyAdmin_version}-all-languages.tar.gz${CEND}] successfully! "
            break
        else
            echo "${CWARNING}phpMyAdmin version does not exist! ${CEND}"
        fi
    else
        echo "${CWARNING}input error! The upgrade phpMyAdmin version is the same as the old version${CEND}"
    fi
done

if [ -e "phpMyAdmin-${NEW_phpMyAdmin_version}-all-languages.tar.gz" ];then
    echo "[${CMSG}phpMyAdmin-${NEW_phpMyAdmin_version}-all-languages.tar.gz${CEND}] found"
    echo "Press Ctrl+c to cancel or Press any key to continue..."
    char=`get_char`
    tar xzf phpMyAdmin-${NEW_phpMyAdmin_version}-all-languages.tar.gz 
    rm -rf $wwwroot_dir/default/phpMyAdmin
    /bin/mv phpMyAdmin-${NEW_phpMyAdmin_version}-all-languages $wwwroot_dir/default/phpMyAdmin
    /bin/cp $wwwroot_dir/default/phpMyAdmin/{config.sample.inc.php,config.inc.php}
    mkdir $wwwroot_dir/default/phpMyAdmin/{upload,save}
    sed -i "s@UploadDir.*@UploadDir'\] = 'upload';@" $wwwroot_dir/default/phpMyAdmin/config.inc.php
    sed -i "s@SaveDir.*@SaveDir'\] = 'save';@" $wwwroot_dir/default/phpMyAdmin/config.inc.php
    sed -i "s@blowfish_secret.*;@blowfish_secret\'\] = \'`cat /dev/urandom | head -1 | md5sum | head -c 10`\';@" $wwwroot_dir/default/phpMyAdmin/config.inc.php
    chown -R ${run_user}.$run_user $wwwroot_dir/default/phpMyAdmin
    echo "You have ${CMSG}successfully${CEND} upgrade from ${CWARNING}$OLD_phpMyAdmin_version${CEND} to ${CWARNING}$NEW_phpMyAdmin_version${CEND}"
fi
cd ..
}
