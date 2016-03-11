#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       http://oneinstack.com
#       https://github.com/lj2007331/oneinstack

DEMO() {
cd $oneinstack_dir/src

[ "$IPADDR_STATE"x == "CN"x ] && /bin/cp ../config/index_cn.html $wwwroot_dir/default/index.html || /bin/cp ../config/index.html $wwwroot_dir/default

if [ -e "$php_install_dir/bin/php" ];then
    if [ "$IPADDR_STATE"x == "CN"x ];then
        src_url=http://mirrors.linuxeye.com/oneinstack/src/tz.zip && Download_src
        unzip -q tz.zip -d $wwwroot_dir/default
    else
        src_url=http://mirrors.linuxeye.com/oneinstack/src/tz_e.zip && Download_src
        unzip -q tz_e.zip -d $wwwroot_dir/default;/bin/mv $wwwroot_dir/default/{tz_e.php,proberv.php}
        sed -i 's@https://ajax.googleapis.com/ajax/libs/jquery/1.7.0/jquery.min.js@http://lib.sinaapp.com/js/jquery/1.7/jquery.min.js@' $wwwroot_dir/default/proberv.php
    fi

    echo '<?php phpinfo() ?>' > $wwwroot_dir/default/phpinfo.php
    if [ "$PHP_cache" == '1' ];then
        src_url=http://mirrors.linuxeye.com/oneinstack/src/ocp.php && Download_src
        /bin/cp ocp.php $wwwroot_dir/default
    elif [ "$PHP_cache" == '2' ];then
        sed -i 's@<a href="/ocp.php" target="_blank" class="links">Opcache</a>@<a href="/xcache" target="_blank" class="links">xcache</a>@' $wwwroot_dir/default/index.html
    elif [ "$PHP_cache" == '3' ];then
        sed -i 's@<a href="/ocp.php" target="_blank" class="links">Opcache</a>@<a href="/apc.php" target="_blank" class="links">APC</a>@' $wwwroot_dir/default/index.html
    elif [ "$PHP_cache" == '4' ];then
        /bin/cp eaccelerator-*/control.php $wwwroot_dir/default
        sed -i 's@<a href="/ocp.php" target="_blank" class="links">Opcache</a>@<a href="/control.php" target="_blank" class="links">eAccelerator</a>@' $wwwroot_dir/default/index.html
    else
        sed -i 's@<a href="/ocp.php" target="_blank" class="links">Opcache</a>@@' $wwwroot_dir/default/index.html
    fi
fi
chown -R ${run_user}.$run_user $wwwroot_dir/default
cd ..
}
