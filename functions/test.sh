#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

TEST()
{
cd $lnmp_dir/src
. ../functions/download.sh 
. ../options.conf

public_IP=`../functions/get_public_ip.py`
if [ "`../functions/get_ip_area.py $public_IP`" == '\u4e2d\u56fd' ];then
	FLAG_IP=CN
fi

echo $public_IP $FLAG_IP

if [ "$FLAG_IP"x == "CN"x ];then
	src_url=http://www.yahei.net/tz/tz.zip && Download_src
	unzip -q tz.zip -d $wwwroot_dir/default
	/bin/cp $lnmp_dir/conf/index_cn.html $wwwroot_dir/default/index.html
else
	src_url=http://www.yahei.net/tz/tz_e.zip && Download_src
	unzip -q tz_e.zip -d $wwwroot_dir/default;/bin/mv $wwwroot_dir/default/{tz_e.php,proberv.php}
	sed -i 's@https://ajax.googleapis.com/ajax/libs/jquery/1.7.0/jquery.min.js@http://lib.sinaapp.com/js/jquery/1.7/jquery.min.js@' $wwwroot_dir/default/proberv.php 
	/bin/cp $lnmp_dir/conf/index.html $wwwroot_dir/default
fi
src_url=https://gist.githubusercontent.com/ck-on/4959032/raw/0b871b345fd6cfcd6d2be030c1f33d1ad6a475cb/ocp.php && Download_src

echo '<?php phpinfo() ?>' > $wwwroot_dir/default/phpinfo.php
[ "$PHP_cache" == '1' ] && /bin/cp ocp.php $wwwroot_dir/default && sed -i 's@<a href="/xcache" target="_blank" class="links">xcache</a>@<a href="/ocp.php" target="_blank" class="links">Opcache</a>@' $wwwroot_dir/default/index.html
[ "$PHP_cache" == '3' ] && sed -i 's@<a href="/xcache" target="_blank" class="links">xcache</a>@<a href="/apc.php" target="_blank" class="links">APC</a>@' $wwwroot_dir/default/index.html
[ "$PHP_cache" == '4' ] && /bin/cp eaccelerator-*/control.php $wwwroot_dir/default && sed -i 's@<a href="/xcache" target="_blank" class="links">xcache</a>@<a href="/control.php" target="_blank" class="links">eAccelerator</a>@' $wwwroot_dir/default/index.html
[ "$Web_yn" == 'y' -a "$Nginx_version" != '3' -a "$Apache_version" != '3' ] && sed -i 's@LNMP@LANMP@g' $wwwroot_dir/default/index.html
[ "$Web_yn" == 'y' -a "$Nginx_version" == '3' -a "$Apache_version" != '3' ] && sed -i 's@LNMP@LAMP@g' $wwwroot_dir/default/index.html
chown -R ${run_user}.$run_user $wwwroot_dir/default
[ -e "$db_install_dir" -a -z "`ps -ef | grep -v grep | grep mysql`" ] && /etc/init.d/mysqld restart 
[ -e "$apache_install_dir" -a -z "`ps -ef | grep -v grep | grep apache`" ] && /etc/init.d/httpd restart 
cd ..
}
