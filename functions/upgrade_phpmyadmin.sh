#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Upgrade_phpMyAdmin()
{
cd $lnmp_dir/src
[ ! -e "$home_dir/default/phpMyAdmin" ] && echo -e "\033[31mThe phpMyAdmin is not installed on your system!\033[0m " && exit 1
Old_phpMyAdmin_version=`grep Version $home_dir/default/phpMyAdmin/README | awk '{print $2}'`
echo -e "Current phpMyAdmin Version: \033[32m$Old_phpMyAdmin_version\033[0m"

while :
do
        echo
        read -p "Please input upgrade phpMyAdmin Version(example: 4.1.5): " phpMyAdmin_version
	if [ "$phpMyAdmin_version" != "$Old_phpMyAdmin_version" ];then
	        [ ! -e "phpMyAdmin-${phpMyAdmin_version}-all-languages.tar.gz" ] && wget -c http://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin/$phpMyAdmin_version/phpMyAdmin-${phpMyAdmin_version}-all-languages.tar.gz > /dev/null 2>&1
	        if [ -e "phpMyAdmin-${phpMyAdmin_version}-all-languages.tar.gz" ];then
	                echo -e "Download \033[32mphpMyAdmin-${phpMyAdmin_version}-all-languages.tar.gz\033[0m successfully! "
	                break
	        else
	                echo -e "\033[31mphpMyAdmin version does not exist!\033[0m"
	        fi
	else
		echo -e "\033[31minput error! The upgrade phpMyAdmin version is the same as the old version\033[0m"
	fi
done

if [ -e "phpMyAdmin-${phpMyAdmin_version}-all-languages.tar.gz" ];then
        echo -e "\033[32mphpMyAdmin-${phpMyAdmin_version}-all-languages.tar.gz\033[0m [found]"
        echo "Press Ctrl+c to cancel or Press any key to continue..."
        char=`get_char`
	tar xzf phpMyAdmin-${phpMyAdmin_version}-all-languages.tar.gz 
	rm -rf $home_dir/default/phpMyAdmin
	/bin/mv phpMyAdmin-${phpMyAdmin_version}-all-languages $home_dir/default/phpMyAdmin
	/bin/cp $home_dir/default/phpMyAdmin/{config.sample.inc.php,config.inc.php}
	mkdir $home_dir/default/phpMyAdmin/{upload,save}
	sed -i "s@UploadDir.*@UploadDir'\] = 'upload';@" $home_dir/default/phpMyAdmin/config.inc.php
	sed -i "s@SaveDir.*@SaveDir'\] = 'save';@" $home_dir/default/phpMyAdmin/config.inc.php
	chown -R ${run_user}.$run_user $home_dir/default/phpMyAdmin
	cd ..
	echo -e "You have \033[32msuccessfully\033[0m upgrade from \033[32m$Old_phpMyAdmin_version\033[0m to \033[32m$phpMyAdmin_version\033[0m"
fi
}
