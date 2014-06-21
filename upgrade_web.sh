#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script" && exit 1 

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
echo "#######################################################################"
echo "#         LNMP for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+          #"
echo "#                Upgrade Nginx/Tengine for LNMP                       #"
echo "# For more information Please visit http://blog.linuxeye.com/31.html  #"
echo "#######################################################################"

cd src
. ../options.conf
. ../functions/download.sh

[ ! -e "$web_install_dir/sbin/nginx" ] && echo -e "\033[31mThe Nginx/Tengine is not installed on your system!\033[0m " && exit 1

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

Upgrade_Nginx()
{
Old_nginx_version_tmp=`$web_install_dir/sbin/nginx -v 2>&1`
Old_nginx_version=${Old_nginx_version_tmp##*/}
echo -e "Current Nginx Version: \033[32m$Old_nginx_version\033[0m"
while :
do
        echo
        read -p "Please input upgrade Nginx Version(example: 1.4.3): " nginx_version
	if [ "$nginx_version" != "$Old_nginx_version" ];then
		[ ! -e "nginx-$nginx_version.tar.gz" ] && wget -c http://nginx.org/download/nginx-$nginx_version.tar.gz > /dev/null 2>&1
		if [ -e "nginx-$nginx_version.tar.gz" ];then
			echo -e "Download \033[32mnginx-$nginx_version.tar.gz\033[0m successfully! "
			break
		else
			echo -e "\033[31mNginx version does not exist!\033[0m"
		fi
	else
		echo -e "\033[31minput error! The upgrade Nginx version is the same as the old version\033[0m"
	fi
done

if [ -e "nginx-$nginx_version.tar.gz" ];then
        echo -e "\033[32mnginx-$nginx_version.tar.gz\033[0m [found]"
        echo "Press Ctrl+c to cancel or Press any key to continue..."
        char=`get_char`
        tar xzf nginx-$nginx_version.tar.gz
        cd nginx-$nginx_version
	make clean
        $web_install_dir/sbin/nginx -V &> $$
        nginx_configure_arguments=`cat $$ | grep 'configure arguments:' | awk -F: '{print $2}'`
        rm -rf $$
	./configure $nginx_configure_arguments
	make
        if [ -f "objs/nginx" ];then
                /bin/mv $web_install_dir/sbin/nginx $web_install_dir/sbin/nginx$(date +%m%d)
                /bin/cp objs/nginx $web_install_dir/sbin/nginx
                kill -USR2 `cat /var/run/nginx.pid`
                kill -QUIT `cat /var/run/nginx.pid.oldbin`
	        echo -e "You have \033[32msuccessfully\033[0m upgrade from \033[32m$Old_nginx_version\033[0m to \033[32m$nginx_version\033[0m"
        	echo "Restarting Nginx..."
	        /etc/init.d/nginx restart
        else
                echo -e "\033[31mUpgrade Nginx failed! \033[0m"
        fi
        cd ..
fi
}

Upgrade_Tengine()
{
Old_tengine_version_tmp=`$web_install_dir/sbin/nginx -v 2>&1`
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
                        echo -e "\033[31mTengine version does not exist!\033[0m"
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
	# make[1]: *** [objs/src/event/ngx_event_openssl.o] Error 1
	sed -i 's@\(.*\)this option allow a potential SSL 2.0 rollback (CAN-2005-2969)\(.*\)@#ifdef SSL_OP_MSIE_SSLV2_RSA_PADDING\n\1this option allow a potential SSL 2.0 rollback (CAN-2005-2969)\2@' src/event/ngx_event_openssl.c
	sed -i 's@\(.*\)SSL_CTX_set_options(ssl->ctx, SSL_OP_MSIE_SSLV2_RSA_PADDING)\(.*\)@\1SSL_CTX_set_options(ssl->ctx, SSL_OP_MSIE_SSLV2_RSA_PADDING)\2\n#endif@' src/event/ngx_event_openssl.c
        $web_install_dir/sbin/nginx -V &> $$
        tengine_configure_arguments=`cat $$ | grep 'configure arguments:' | awk -F: '{print $2}'`
        rm -rf $$
        ./configure $tengine_configure_arguments
        make
        if [ -f "objs/nginx" ];then
                /bin/mv $web_install_dir/sbin/nginx $web_install_dir/sbin/nginx$(date +%m%d)
                /bin/mv $web_install_dir/sbin/dso_tool $web_install_dir/sbin/dso_tool$(date +%m%d)
                /bin/mv $web_install_dir/modules $web_install_dir/modules$(date +%m%d)
                /bin/cp objs/nginx $web_install_dir/sbin/nginx
                /bin/cp objs/dso_tool $web_install_dir/sbin/dso_tool
		chmod +x $web_install_dir/sbin/*
		make install
		if [ -e "$web_install_dir/modules$(date +%m%d)/ngx_pagespeed.so" ];then
			cd $lnmp_dir/src
			rm -rf ngx_pagespeed*
			src_url=https://dl.google.com/dl/page-speed/psol/1.8.31.4.tar.gz && Download_src
			[ -s "ngx_pagespeed-1.8.31.4-beta.zip" ] && echo "ngx_pagespeed-1.8.31.4-beta.zip found" || wget -c --no-check-certificate -O ngx_pagespeed-1.8.31.4-beta.zip https://github.com/pagespeed/ngx_pagespeed/archive/master.zip

			unzip -q ngx_pagespeed-1.8.31.4-beta.zip
			/bin/mv ngx_pagespeed-master ngx_pagespeed-1.8.31.4-beta
			tar xzf 1.8.31.4.tar.gz -C ngx_pagespeed-1.8.31.4-beta
			cd tengine-$tengine_version
			$web_install_dir/sbin/dso_tool --add-module=$lnmp_dir/src/ngx_pagespeed-1.8.31.4-beta
		fi

                kill -USR2 `cat /var/run/nginx.pid`
                kill -QUIT `cat /var/run/nginx.pid.oldbin`
                echo -e "You have \033[32msuccessfully\033[0m upgrade from \033[32m$Old_tengine_version\033[0m to \033[32m$tengine_version\033[0m"
                echo "Restarting Tengine..."
                /etc/init.d/nginx restart
        else
                echo -e "\033[31mUpgrade Tengine failed! \033[0m"
        fi
        cd ..
fi
}

if [ ! -e "$web_install_dir/sbin/dso_tool" ];then
	Upgrade_Nginx
elif [ -e "$web_install_dir/sbin/dso_tool" ];then 
	Upgrade_Tengine
fi
