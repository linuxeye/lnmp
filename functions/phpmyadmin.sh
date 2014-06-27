#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_phpMyAdmin()
{
cd $lnmp_dir/src
. ../functions/download.sh 
. ../options.conf 

src_url=http://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin/4.2.5/phpMyAdmin-4.2.5-all-languages.tar.gz && Download_src

tar xzf phpMyAdmin-4.2.5-all-languages.tar.gz
/bin/mv phpMyAdmin-4.2.5-all-languages $home_dir/default/phpMyAdmin
/bin/cp $home_dir/default/phpMyAdmin/{config.sample.inc.php,config.inc.php}
mkdir $home_dir/default/phpMyAdmin/{upload,save}
sed -i "s@UploadDir.*@UploadDir'\] = 'upload';@" $home_dir/default/phpMyAdmin/config.inc.php
sed -i "s@SaveDir.*@SaveDir'\] = 'save';@" $home_dir/default/phpMyAdmin/config.inc.php
chown -R www.www $home_dir/default/phpMyAdmin
cd ..
}
