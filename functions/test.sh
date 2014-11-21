#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

TEST()
{
cd $lnmp_dir/src
. ../functions/download.sh 
. ../options.conf

public_IP=`../functions/get_public_ip.py`
if [ "`../functions/get_ip_area.py $public_IP`" == 'CN' ];then
	FLAG_IP=CN
fi

if [ "$FLAG_IP"x == "CN"x ];then
	src_url=http://www.yahei.net/tz/tz.zip && Download_src
	unzip -q tz.zip -d $home_dir/default
	/bin/cp $lnmp_dir/conf/index_cn.html $home_dir/default/index.html
else
	src_url=http://www.yahei.net/tz/tz_e.zip && Download_src
	unzip -q tz_e.zip -d $home_dir/default;/bin/mv $home_dir/default/{tz_e.php,proberv.php}
	sed -i 's@https://ajax.googleapis.com/ajax/libs/jquery/1.7.0/jquery.min.js@http://lib.sinaapp.com/js/jquery/1.7/jquery.min.js@' $home_dir/default/proberv.php 
	/bin/cp $lnmp_dir/conf/index.html $home_dir/default
fi
src_url=https://gist.githubusercontent.com/ck-on/4959032/raw/0b871b345fd6cfcd6d2be030c1f33d1ad6a475cb/ocp.php && Download_src

echo '<?php phpinfo() ?>' > $home_dir/default/phpinfo.php
[ "$PHP_cache" == '1' ] && /bin/cp ocp.php $home_dir/default && sed -i 's@<a href="/xcache" target="_blank" class="links">xcache</a>@<a href="/ocp.php" target="_blank" class="links">Opcache</a>@' $home_dir/default/index.html
[ "$PHP_cache" == '3' ] && sed -i 's@<a href="/xcache" target="_blank" class="links">xcache</a>@<a href="/apc.php" target="_blank" class="links">APC</a>@' $home_dir/default/index.html
[ "$PHP_cache" == '4' ] && /bin/cp eaccelerator-*/control.php $home_dir/default && sed -i 's@<a href="/xcache" target="_blank" class="links">xcache</a>@<a href="/control.php" target="_blank" class="links">eAccelerator</a>@' $home_dir/default/index.html
[ "$Web_yn" == 'y' -a "$Nginx_version" != '3' -a "$Apache_version" != '3' ] && sed -i 's@LNMP@LANMP@g' $home_dir/default/index.html
[ "$Web_yn" == 'y' -a "$Nginx_version" == '3' -a "$Apache_version" != '3' ] && sed -i 's@LNMP@LAMP@g' $home_dir/default/index.html
chown -R www.www $home_dir/default
[ -e "$db_install_dir" -a -z "`ps -ef | grep -v grep | grep mysql`" ] && service mysqld start
[ -e "$apache_install_dir" -a -z "`ps -ef | grep -v grep | grep apache`" ] && service httpd restart 
cd ..
}
