#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Version: 1.0-Alpha Jun 15,2015 lj2007331 AT gmail.com
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       http://oneinstack.com

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#######################################################################
#       OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+      #
#                         Uninstall OneinStack                        #
#       For more information please visit http://oneinstack.com       #
#######################################################################
"

. ./options.conf
. ./include/color.sh
. ./include/get_char.sh
. ./include/check_db.sh

# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; } 

Uninstall()
{
[ -e "$db_install_dir" ] && service mysqld stop && rm -rf /etc/init.d/mysqld /etc/my.cnf /etc/ld.so.conf.d/{mysql,mariadb,percona}*.conf
[ -e "$apache_install_dir" ] && service httpd stop && rm -rf /etc/init.d/httpd /etc/logrotate.d/apache
[ -e "$tomcat_install_dir" ] && service tomcat stop && rm -rf /etc/init.d/tomcat
[ -e "/usr/java" ] && rm -rf /usr/java
[ -e "$php_install_dir/bin/phpize" ] && service php-fpm stop && rm -rf /etc/init.d/php-fpm
[ -e "$nginx_install_dir" ] && service nginx stop && rm -rf /etc/init.d/nginx /etc/logrotate.d/nginx
[ -e "$tengine_install_dir" ] && service nginx stop && rm -rf /etc/init.d/nginx /etc/logrotate.d/nginx
[ -e "$pureftpd_install_dir" ] && service pureftpd stop && rm -rf /etc/init.d/pureftpd
[ -e "$redis_install_dir" ] && service redis-server stop && rm -rf /etc/init.d/redis-server /usr/local/bin/redis-*
[ -e "$memcached_install_dir" ] && service memcached stop && rm -rf /etc/init.d/memcached /usr/bin/memcached
[ -e "/usr/local/imagemagick" ] && rm -rf /usr/local/imagemagick 
[ -e "/usr/local/graphicsmagick" ] && rm -rf /usr/local/graphicsmagick 
[ -e "/etc/init.d/supervisord" ] && service supervisord stop && { rm -rf /etc/supervisord.conf /etc/init.d/supervisord; } 
[ -e "/usr/bin/hhvm" ] && { rpm -e hhvm ; rm -rf /etc/hhvm /var/log/hhvm /usr/bin/hhvm; }
id -u $run_user >/dev/null 2>&1 ; [ $? -eq 0 ] && userdel $run_user
id -u mysql >/dev/null 2>&1 ; [ $? -eq 0 ] && userdel mysql 

/bin/mv ${wwwroot_dir}{,_$(date +%F)}
/bin/mv ${db_data_dir}{,_$(date +%F)}
for D in `cat ./options.conf | grep dir= | grep -v oneinstack | grep -v backup_dir | awk -F'=' '{print $2}' | sort | uniq`
do
    [ -e "$D" ] && rm -rf $D
done

sed -i 's@^oneinstack_dir=.*@oneinstack_dir=@' ./options.conf
sed -i 's@^dbrootpwd=.*@dbrootpwd=@' ./options.conf
sed -i 's@^website_name=.*@website_name=@' ./options.conf
sed -i 's@^local_bankup_yn=.*@local_bankup_yn=y@' ./options.conf
sed -i 's@^remote_bankup_yn=.*@remote_bankup_yn=n@' ./options.conf
sed -i "s@^export.*$db_install_dir.*@@g" /etc/profile && . /etc/profile
echo "${CMSG}Uninstall completed${CEND}"
}

echo 
echo "${CWARNING}You will uninstall OneinStack, Please backup your configure files and DB data! ${CEND}"
echo 
echo "${CWARNING}The following directory or files will be remove: ${CEND}"
for D in `cat ./options.conf | grep dir= | grep -v oneinstack | grep -v backup_dir | awk -F'=' '{print $2}' | sort | uniq` 
do
    [ -e "$D" ] && echo $D
done
[ -e "/etc/init.d/nginx" ] && echo '/etc/init.d/nginx'
[ -e "/etc/logrotate.d/nginx" ] && echo '/etc/logrotate.d/nginx'
[ -e "$apache_install_dir" ] && echo -e "/etc/init.d/httpd\n/etc/logrotate.d/apache"
[ -e "$tomcat_install_dir" ] && echo '/etc/init.d/tomcat'
[ -e "/usr/java" ] && echo '/usr/java' 
[ -e "$db_install_dir" ] && echo -e "/etc/init.d/mysqld\n/etc/my.cnf"
[ -e "$php_install_dir/bin/phpize" ] && echo '/etc/init.d/php-fpm'
[ -e "$pureftpd_install_dir" ] && echo '/etc/init.d/pureftpd'
[ -e "$memcached_install_dir" ] && echo -e "/etc/init.d/memcached\n/usr/bin/memcached"
[ -e "$redis_install_dir" ] && echo '/etc/init.d/redis-server' 
[ -e "/usr/local/imagemagick" ] && echo '/usr/local/imagemagick' 
[ -e "/usr/local/graphicsmagick" ] && echo '/usr/local/graphicsmagick' 
echo 
echo "Press Ctrl+c to cancel or Press any key to continue..."
char=`get_char`

while :
do
    echo
    read -p "Do you want to uninstall OneinStack? [y/n]: " uninstall_yn
    if [ "$uninstall_yn" != 'y' -a "$uninstall_yn" != 'n' ];then
        echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
        break
    fi
done

[ "$uninstall_yn" == 'y' ] && Uninstall
