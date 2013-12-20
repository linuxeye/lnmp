#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script" && exit 1 

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
echo "#######################################################################"
echo "#         LNMP for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+          #"
echo "#                    Upgrade PHP for LNMP                             #"
echo "# For more information Please visit http://blog.linuxeye.com/31.html  #"
echo "#######################################################################"

cd src
. ../options.conf
[ ! -e "$php_install_dir" ] && echo -e "\033[31mThe PHP is not installed on your system!\033[0m " && exit 1

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
Old_php_version=`$php_install_dir/bin/php -r 'echo PHP_VERSION;'`
echo -e "Current PHP Version: \033[32m$Old_php_version\033[0m"
while :
do
        echo
        read -p "Please input upgrade PHP Version: " php_version
        if [ "${php_version%.*}" == "${Old_php_version%.*}" ]; then
                if [ "${php_version##*.}" -ge "${Old_php_version##*.}" ]; then
                        [ ! -e "php-$php_version.tar.gz" ] && wget -c http://www.php.net/distributions/php-$php_version.tar.gz > /dev/null 2>&1
                        if [ -e "php-$php_version.tar.gz" ];then
                                echo -e "Download \033[32mphp-$php_version.tar.gz\033[0m successfully! "
                        else
				echo -e "\033[31mIt does not exist!\033[0m"
                        fi
			break
                else
                        echo -e "Error: You must input PHP version not less than \033[32m$Old_php_version\033[0m!! "
                fi
        else
                echo -e "\033[31minput error!\033[0m Please only input '\033[32m${Old_php_version%.*}.xx' \033[0m"
        fi
done

if [ -e "php-$php_version.tar.gz" ];then
        echo -e "\033[32mphp-$php_version.tar.gz\033[0m [found]"
        echo "Press Ctrl+c to cancel or Press any key to continue..."
        char=`get_char`
        tar xzf php-$php_version.tar.gz
	wget -O fpm-race-condition.patch 'https://bugs.php.net/patch-display.php?bug_id=65398&patch=fpm-race-condition.patch&revision=1375772074&download=1'
	patch -d php-$php_version -p0 < fpm-race-condition.patch
        cd php-$php_version
	make clean
        $php_install_dir/bin/php -i |grep 'Configure Command' | awk -F'=>' '{print $2}' | bash
        make ZEND_EXTRA_LIBS='-liconv'
        make install
	cd ..
        echo "Restarting php-fpm..."
        /etc/init.d/php-fpm restart
        echo -e "You have \033[32msuccessfully\033[0m upgrade from \033[32m$Old_php_version\033[0m to \033[32m$php_version\033[0m"
fi
