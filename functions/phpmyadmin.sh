#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_phpMyAdmin()
{
cd $lnmp_dir/src
. ../functions/download.sh 
. ../options.conf 

src_url=http://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin/4.0.7/phpMyAdmin-4.0.7-all-languages.tar.gz && Download_src

tar xzf phpMyAdmin-4.0.7-all-languages.tar.gz
/bin/mv phpMyAdmin-4.0.7-all-languages $home_dir/default/phpMyAdmin
chown -R www.www $home_dir/default/phpMyAdmin
cd ..
}
