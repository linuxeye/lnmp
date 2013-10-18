#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

TEST()
{
cd $lnmp_dir/src
. ../functions/download.sh 
. ../options.conf

src_url=http://www.yahei.net/tz/tz.zip && Download_src

echo '<?php phpinfo() ?>' > $home_dir/default/phpinfo.php
/bin/cp $lnmp_dir/conf/index.html $home_dir/default
unzip -q tz.zip -d $home_dir/default
chown -R www.www $home_dir/default
[ "$DB_yn" == 'y' ] && service mysqld restart
cd ..
}
