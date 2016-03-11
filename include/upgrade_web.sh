#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       http://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Upgrade_Nginx() {
cd $oneinstack_dir/src
[ ! -e "$nginx_install_dir/sbin/nginx" ] && echo "${CWARNING}The Nginx is not installed on your system! ${CEND}" && exit 1
OLD_Nginx_version_tmp=`$nginx_install_dir/sbin/nginx -v 2>&1`
OLD_Nginx_version=${OLD_Nginx_version_tmp##*/}
echo
echo "Current Nginx Version: ${CMSG}$OLD_Nginx_version${CEND}"
while :
do
    echo
    read -p "Please input upgrade Nginx Version(example: 1.9.15): " NEW_Nginx_version
    if [ "$NEW_Nginx_version" != "$OLD_Nginx_version" ];then
        [ ! -e "nginx-$NEW_Nginx_version.tar.gz" ] && wget --no-check-certificate -c http://nginx.org/download/nginx-$NEW_Nginx_version.tar.gz > /dev/null 2>&1
        if [ -e "nginx-$NEW_Nginx_version.tar.gz" ];then
            echo "Download [${CMSG}nginx-$NEW_Nginx_version.tar.gz${CEND}] successfully! "
            break
        else
            echo "${CWARNING}Nginx version does not exist! ${CEND}"
        fi
    else
        echo "${CWARNING}input error! The upgrade Nginx version is the same as the old version${CEND}"
    fi
done

if [ -e "nginx-$NEW_Nginx_version.tar.gz" ];then
    echo "[${CMSG}nginx-$NEW_Nginx_version.tar.gz${CEND}] found"
    echo "Press Ctrl+c to cancel or Press any key to continue..."
    char=`get_char`
    tar xzf nginx-$NEW_Nginx_version.tar.gz
    cd nginx-$NEW_Nginx_version
    make clean
    sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' auto/cc/gcc # close debug
    $nginx_install_dir/sbin/nginx -V &> $$
    nginx_configure_arguments=`cat $$ | grep 'configure arguments:' | awk -F: '{print $2}'`
    rm -rf $$
    ./configure $nginx_configure_arguments
    make
    if [ -f "objs/nginx" ];then
        /bin/mv $nginx_install_dir/sbin/nginx $nginx_install_dir/sbin/nginx$(date +%m%d)
        /bin/cp objs/nginx $nginx_install_dir/sbin/nginx
        kill -USR2 `cat /var/run/nginx.pid`
        kill -QUIT `cat /var/run/nginx.pid.oldbin`
        echo "You have ${CMSG}successfully${CEND} upgrade from ${CWARNING}$OLD_Nginx_version${CEND} to ${CWARNING}$NEW_Nginx_version${CEND}"
    else
        echo "${CFAILURE}Upgrade Nginx failed! ${CEND}" 
    fi
    cd ..
fi
cd ..
}

Upgrade_Tengine() {
cd $oneinstack_dir/src
[ ! -e "$tengine_install_dir/sbin/nginx" ] && echo "${CWARNING}The Tengine is not installed on your system! ${CEND}" && exit 1
OLD_Tengine_version_tmp=`$tengine_install_dir/sbin/nginx -v 2>&1`
OLD_Tengine_version="`echo ${OLD_Tengine_version_tmp#*/} | awk '{print $1}'`"
echo
echo "Current Tengine Version: ${CMSG}$OLD_Tengine_version${CEND}"
while :
do
    echo
    read -p "Please input upgrade Tengine Version(example: 2.1.15): " NEW_Tengine_version
    if [ "$NEW_Tengine_version" != "$OLD_Tengine_version" ];then
        [ ! -e "tengine-$NEW_Tengine_version.tar.gz" ] && wget --no-check-certificate -c http://tengine.taobao.org/download/tengine-$NEW_Tengine_version.tar.gz > /dev/null 2>&1
        if [ -e "tengine-$NEW_Tengine_version.tar.gz" ];then
            echo "Download [${CMSG}tengine-$NEW_Tengine_version.tar.gz${CEND}] successfully! "
            break
        else
            echo "${CWARNING}Tengine version does not exist! ${CEND}"
        fi
    else
        echo "${CWARNING}input error! The upgrade Tengine version is the same as the old version${CEND}"
    fi
done

if [ -e "tengine-$NEW_Tengine_version.tar.gz" ];then
    echo "[${CMSG}tengine-$NEW_Tengine_version.tar.gz${CEND}] found"
    echo "Press Ctrl+c to cancel or Press any key to continue..."
    char=`get_char`
    tar xzf tengine-$NEW_Tengine_version.tar.gz
    cd tengine-$NEW_Tengine_version
    make clean
    sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' auto/cc/gcc # close debug
    $tengine_install_dir/sbin/nginx -V &> $$
    tengine_configure_arguments=`cat $$ | grep 'configure arguments:' | awk -F: '{print $2}'`
    rm -rf $$
    ./configure $tengine_configure_arguments
    make
    if [ -f "objs/nginx" ];then
        /bin/mv $tengine_install_dir/sbin/nginx $tengine_install_dir/sbin/nginx$(date +%m%d)
        /bin/mv $tengine_install_dir/sbin/dso_tool $tengine_install_dir/sbin/dso_tool$(date +%m%d)
        /bin/mv $tengine_install_dir/modules $tengine_install_dir/modules$(date +%m%d)
        /bin/cp objs/nginx $tengine_install_dir/sbin/nginx
        /bin/cp objs/dso_tool $tengine_install_dir/sbin/dso_tool
        chmod +x $tengine_install_dir/sbin/*
        make install
        kill -USR2 `cat /var/run/nginx.pid`
        kill -QUIT `cat /var/run/nginx.pid.oldbin`
        echo "You have ${CMSG}successfully${CEND} upgrade from ${CWARNING}$OLD_Tengine_version${CEND} to ${CWARNING}$NEW_Tengine_version${CEND}"
    else
        echo "${CFAILURE}Upgrade Tengine failed! ${CEND}" 
    fi
    cd ..
fi
cd ..
}
