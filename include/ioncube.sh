#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_ionCube() {
    pushd ${oneinstack_dir}/src
  
    PHP_detail_version=$(${php_install_dir}/bin/php -r 'echo PHP_VERSION;')
    PHP_main_version=${PHP_detail_version%.*}
    phpExtensionDir=`$php_install_dir/bin/php-config --extension-dir`
  
    if [ "${OS_BIT}" == '64' ];then
        tar xzf ioncube_loaders_lin_x86-64.tar.gz
    else
        if [ "${TARGET_ARCH}" == "armv7" ];then
            tar xzf ioncube_loaders_lin_armv7l.tar.gz
        else
            tar xzf ioncube_loaders_lin_x86.tar.gz
        fi
    fi
  
    [ ! -d "${phpExtensionDir}" ] && mkdir -p ${phpExtensionDir}
    if [ "$PHP_main_version" == '7.0' ]; then
        /bin/cp ioncube/ioncube_loader_lin_7.0.so ${phpExtensionDir}
        zend_extension="${phpExtensionDir}/ioncube_loader_lin_7.0.so"
    elif [ "$PHP_main_version" == '5.6' ]; then
        /bin/cp ioncube/ioncube_loader_lin_5.6.so ${phpExtensionDir}
        zend_extension="${phpExtensionDir}/ioncube_loader_lin_5.6.so"
    elif [ "$PHP_main_version" == '5.5' ]; then
        /bin/cp ioncube/ioncube_loader_lin_5.5.so ${phpExtensionDir}
        zend_extension="${phpExtensionDir}/ioncube_loader_lin_5.5.so"
    elif [ "$PHP_main_version" == '5.4' ]; then
        /bin/cp ioncube/ioncube_loader_lin_5.4.so ${phpExtensionDir}
        zend_extension="${phpExtensionDir}/ioncube_loader_lin_5.4.so"
    elif [ "$PHP_main_version" == '5.3' ]; then
        /bin/cp ioncube/ioncube_loader_lin_5.3.so ${phpExtensionDir}
        zend_extension="${phpExtensionDir}/ioncube_loader_lin_5.3.so"
    else
        echo "Error! Your PHP ${PHP_detail_version} does not support ionCube!"
        rm -rf ioncube
        exit 1
    fi
  
    rm -rf ioncube
    cat > ${php_install_dir}/etc/php.d/ext-0ioncube.ini << EOF
[ionCube Loader]
zend_extension=${zend_extension}
EOF
    [ "${Apache_version}" != '1' -a "${Apache_version}" != '2' ] && service php-fpm restart || service httpd restart
    popd
}
