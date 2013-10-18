#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script" && exit 1 

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
echo "#######################################################################"
echo "#         LNMP for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+          #"
echo "#                    Upgrade Tengine for LNMP                           #"
echo "# For more information Please visit http://blog.linuxeye.com/31.html  #"
echo "#######################################################################"

cd src
. ../options.conf
[ ! -e "$tengine_install_dir" -o ! -e "$tengine_install_dir/sbin/dso_tool" ] && echo -e "\033[31mThe Tengine is not installed on your system!\033[0m " && exit 1
get_char()
{
SAVEDSTTY=`stty -g`
stty -echo
stty cbreak
dd if=/dev/tty bs=1 count=1 2> /dev/null
stty -raw
stty echo
stty $SAVEDSTTY
}

echo
Old_tengine_version_tmp=`$tengine_install_dir/sbin/nginx -v 2>&1`
Old_tengine_version="`echo ${Old_tengine_version_tmp#*/} | awk '{print $1}'`"
echo -e "Current Tengine Version: \033[32m$Old_tengine_version\033[0m"
while :
do
        echo
        read -p "Please input upgrade Tengine Version(example: 1.5.1): " tengine_version
	if [ "$tengine_version" != "$Old_tengine_version" ];then
		[ ! -e "tengine-$tengine_version.tar.gz" ] && wget -c http://tengine.taobao.org/download/tengine-$tengine_version.tar.gz > /dev/null 2>&1
		if [ -e "tengine-$tengine_version.tar.gz" ];then
			echo -e "Download \033[32mtengine-$tengine_version.tar.gz\033[0m successfully! "
			break
		else
			echo -e "\033[31mIt does not exist!\033[0m"
		fi
	else
		echo -e "\033[31minput error! The upgrade Tengine version is the same as the old version\033[0m"
	fi
done

if [ -e "tengine-$tengine_version.tar.gz" ];then
        echo -e "\033[32mtengine-$tengine_version.tar.gz\033[0m [found]"
        echo "Press Ctrl+c to cancel or Press any key to continue..."
        char=`get_char`
        tar xzf tengine-$tengine_version.tar.gz
        cd tengine-$tengine_version
	make clean
        $tengine_install_dir/sbin/nginx -V &> $$
        tengine_configure_arguments=`cat $$ | grep 'configure arguments:' | awk -F: '{print $2}'`
        rm -rf $$
	./configure $tengine_configure_arguments
	make
        if [ -f "objs/nginx" ];then
                /bin/mv $tengine_install_dir/sbin/nginx $tengine_install_dir/sbin/nginx$(date +%m%d)
                /bin/cp objs/nginx $tengine_install_dir/sbin/nginx
                kill -USR2 `cat /var/run/nginx.pid`
                kill -QUIT `cat /var/run/nginx.pid.oldbin`
	        echo -e "You have \033[32msuccessfully\033[0m upgrade from \033[32m$Old_tengine_version\033[0m to \033[32m$tengine_version\033[0m"
        	echo "Restarting Tengine..."
	        /etc/init.d/nginx restart
        else
                echo -e "\033[31mupgrade Tengine failed! \033[0m"
        fi
        cd ..
fi
