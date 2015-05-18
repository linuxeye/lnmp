#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

# Check if user is root
[ $(id -u) != "0" ] && { echo -e "\033[31mError: You must be root to run this script\033[0m"; exit 1; } 
export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#######################################################################
#    LNMP/LAMP/LANMP for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+    #
# For more information please visit http://blog.linuxeye.com/31.html  #
#######################################################################
"
. ./options.conf

HHVM_YN()
{
if [ -e "/usr/bin/hhvm" ];then
        while :
        do
                echo
                echo 'Please choose to use PHP or HHVM:'
                echo -e "\t\033[32m1\033[0m. Use php"
                echo -e "\t\033[32m2\033[0m. Use hhvm"
                read -p "Please input a number:(Default 1 press Enter) " PHP_HHVM
                [ -z "$PHP_HHVM" ] && PHP_HHVM=1
                if [ $PHP_HHVM != 1 -a $PHP_HHVM != 2 ];then
                        echo -e "\033[31minput error! Please only input number 1,2\033[0m"
                else
                        break
                fi
        done
fi
if [ "$PHP_HHVM" == '2' ];then
        NGX_CONF="fastcgi_pass unix:/var/log/hhvm/sock;\n\tfastcgi_index index.php;\n\tfastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;\n\tinclude fastcgi_params;"
else
        NGX_CONF="#fastcgi_pass remote_php_ip:9000;\n\tfastcgi_pass unix:/dev/shm/php-cgi.sock;\n\tfastcgi_index index.php;\n\tinclude fastcgi.conf;"
fi
}

Input_domain()
{
while :
do
	echo
	read -p "Please input domain(example: www.linuxeye.com): " domain
	if [ -z "`echo $domain | grep '.*\..*'`" ]; then
		echo -e "\033[31minput error! \033[0m"
	else
		break
	fi
done

if [ -e "$web_install_dir/conf/vhost/$domain.conf" -o -e "$apache_install_dir/conf/vhost/$domain.conf" ]; then
	[ -e "$web_install_dir/conf/vhost/$domain.conf" ] && echo -e "$domain in the Nginx/Tengine already exist! \nYou can delete \033[32m$web_install_dir/conf/vhost/$domain.conf\033[0m and re-create"
	[ -e "$apache_install_dir/conf/vhost/$domain.conf" ] && echo -e "$domain in the Apache already exist! \nYou can delete \033[32m$apache_install_dir/conf/vhost/$domain.conf\033[0m and re-create"
	exit 1
else
	echo "domain=$domain"
fi

while :
do
	echo ''
        read -p "Do you want to add more domain name? [y/n]: " moredomainame_yn 
        if [ "$moredomainame_yn" != 'y' ] && [ "$moredomainame_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
                break 
        fi
done

if [ "$moredomainame_yn" == 'y' ]; then
        while :
        do
                echo
                read -p "Type domainname,example(linuxeye.com www.example.com): " moredomain
                if [ -z "`echo $moredomain | grep '.*\..*'`" ]; then
                        echo -e "\033[31minput error\033[0m"
                else
			[ "$moredomain" == "$domain" ] && echo -e "\033[31mDomain name already exists! \033[0m" && continue
                        echo domain list="$moredomain"
                        moredomainame=" $moredomain"
                        break
                fi
        done
        Domain_alias=ServerAlias$moredomainame
fi

echo
echo "Please input the directory for the domain:$domain :"
read -p "(Default directory: /home/wwwroot/$domain): " vhostdir
if [ -z "$vhostdir" ]; then
        vhostdir="/home/wwwroot/$domain"
        echo -e "Virtual Host Directory=\033[32m$vhostdir\033[0m"
fi
echo
echo "Create Virtul Host directory......"
mkdir -p $vhostdir
echo "set permissions of Virtual Host directory......"
chown -R ${run_user}.$run_user $vhostdir
}

Nginx_anti_hotlinking()
{
while :
do
	echo ''
        read -p "Do you want to add hotlink protection? [y/n]: " anti_hotlinking_yn 
        if [ "$anti_hotlinking_yn" != 'y' ] && [ "$anti_hotlinking_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
                break
        fi
done

if [ -n "`echo $domain | grep '.*\..*\..*'`" ];then
        domain_allow="*.${domain#*.} $domain"
else
        domain_allow="*.$domain $domain"
fi

if [ "$anti_hotlinking_yn" == 'y' ];then 
	if [ "$moredomainame_yn" == 'y' ]; then
		domain_allow_all=$domain_allow$moredomainame
	else
		domain_allow_all=$domain_allow
	fi
	anti_hotlinking=$(echo -e "location ~ .*\.(wma|wmv|asf|mp3|mmf|zip|rar|jpg|gif|png|swf|flv)$ {\n\tvalid_referers none blocked $domain_allow_all;\n\tif (\$invalid_referer) {\n\t\t#rewrite ^/ http://www.linuxeye.com/403.html;\n\t\treturn 403;\n\t\t}\n\t}")
else
	anti_hotlinking=
fi
}

Nginx_rewrite()
{
while :
do
	echo ''
        read -p "Allow Rewrite rule? [y/n]: " rewrite_yn
        if [ "$rewrite_yn" != 'y' ] && [ "$rewrite_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
                break 
        fi
done
if [ "$rewrite_yn" == 'n' ];then
	rewrite="none"
	touch "$web_install_dir/conf/$rewrite.conf"
else
	echo ''
	echo "Please input the rewrite of programme :"
	echo -e "\033[32mwordpress\033[0m,\033[32mdiscuz\033[0m,\033[32mphpwind\033[0m,\033[32mtypecho\033[0m,\033[32mecshop\033[0m,\033[32mdrupal\033[0m,\033[32mjoomla\033[0m rewrite was exist."
	read -p "(Default rewrite: other):" rewrite
	if [ "$rewrite" == "" ]; then
		rewrite="other"
	fi
	echo -e "You choose rewrite=\033[32m$rewrite\033[0m" 
	if [ -s "conf/$rewrite.conf" ];then
		/bin/cp conf/$rewrite.conf $web_install_dir/conf/$rewrite.conf
	else
		touch "$web_install_dir/conf/$rewrite.conf"
	fi
fi
}

Nginx_log()
{
while :
do
	echo ''
        read -p "Allow Nginx/Tengine access_log? [y/n]: " access_yn 
        if [ "$access_yn" != 'y' ] && [ "$access_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
                break 
        fi
done
if [ "$access_yn" == 'n' ]; then
	N_log="access_log off;"
else
	N_log="access_log /home/wwwlogs/${domain}_nginx.log combined;"
	echo -e "You access log file=\033[32m/home/wwwlogs/${domain}_nginx.log\033[0m"
fi
}

Create_nginx_conf()
{
[ ! -d $web_install_dir/conf/vhost ] && mkdir $web_install_dir/conf/vhost
cat > $web_install_dir/conf/vhost/$domain.conf << EOF
server {
listen 80;
server_name $domain$moredomainame;
$N_log
index index.html index.htm index.jsp index.php;
include $rewrite.conf;
root $vhostdir;
#error_page 404 /404.html;
if ( \$query_string ~* ".*[\;'\<\>].*" ){
	return 404;
	}
$anti_hotlinking
`echo -e $ngx_pagespeed`
location ~ .*\.(php|php5)?$  {
	`echo -e $NGX_CONF`
	}

location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|flv|ico)$ {
	expires 30d;
	}

location ~ .*\.(js|css)?$ {
	expires 7d;
	}
}
EOF

echo
$web_install_dir/sbin/nginx -t
if [ $? == 0 ];then
	echo "Restart Nginx......"
	$web_install_dir/sbin/nginx -s reload
else
	rm -rf $web_install_dir/conf/vhost/$domain.conf
	echo -e "Create virtualhost ... \033[31m[FAILED]\033[0m"
	exit 1
fi

printf "
#######################################################################
#         LNMP for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+          #
# For more information please visit http://blog.linuxeye.com/31.html  #
#######################################################################
"
echo -e "`printf "%-32s" "Your domain:"`\033[32m$domain\033[0m"
echo -e "`printf "%-32s" "Virtualhost conf:"`\033[32m$web_install_dir/conf/vhost/$domain.conf\033[0m"
echo -e "`printf "%-32s" "Directory of:"`\033[32m$vhostdir\033[0m"
[ "$rewrite_yn" == 'y' ] && echo -e "`printf "%-32s" "Rewrite rule:"`\033[32m$rewrite\033[0m" 
}

Apache_log()
{
while :
do
        echo ''
        read -p "Allow Apache access_log? [y/n]: " access_yn
        if [ "$access_yn" != 'y' ] && [ "$access_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
                break
        fi
done

if [ "$access_yn" == 'n' ]; then
        A_log='CustomLog "/dev/null" common'
else
        A_log="CustomLog \"/home/wwwlogs/${domain}_apache.log\" common"
        echo "You access log file=/home/wwwlogs/${domain}_apache.log"
fi
}

Create_apache_conf()
{
[ "`$apache_install_dir/bin/apachectl -v | awk -F'.' /version/'{print $2}'`" == '4' ] && R_TMP='Require all granted' || R_TMP=
[ ! -d $apache_install_dir/conf/vhost ] && mkdir $apache_install_dir/conf/vhost
cat > $apache_install_dir/conf/vhost/$domain.conf << EOF
<VirtualHost *:80>
    ServerAdmin admin@linuxeye.com 
    DocumentRoot "$vhostdir"
    ServerName $domain
    $Domain_alias
    ErrorLog "/home/wwwlogs/${domain}_error_apache.log"
    $A_log
<Directory "$vhostdir">
    SetOutputFilter DEFLATE
    Options FollowSymLinks
    $R_TMP
    AllowOverride All
    Order allow,deny
    Allow from all
    DirectoryIndex index.html index.php
</Directory>
</VirtualHost>
EOF

echo
$apache_install_dir/bin/apachectl -t
if [ $? == 0 ];then
	echo "Restart Apache......"
	/etc/init.d/httpd restart
else
	rm -rf $apache_install_dir/conf/vhost/$domain.conf
	echo -e "Create virtualhost ... \033[31m[FAILED]\033[0m"
	exit 1
fi

printf "
#######################################################################
#         LAMP for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+          #
# For more information please visit http://blog.linuxeye.com/82.html  #
#######################################################################
"
echo -e "`printf "%-32s" "Your domain:"`\033[32m$domain\033[0m"
echo -e "`printf "%-32s" "Virtualhost conf:"`\033[32m$apache_install_dir/conf/vhost/$domain.conf\033[0m"
echo -e "`printf "%-32s" "Directory of $domain:"`\033[32m$vhostdir\033[0m"
}

Create_nginx_apache_conf()
{
# Nginx/Tengine
[ ! -d $web_install_dir/conf/vhost ] && mkdir $web_install_dir/conf/vhost
cat > $web_install_dir/conf/vhost/$domain.conf << EOF
server {
listen 80;
server_name $domain$moredomainame;
$N_log
index index.html index.htm index.jsp index.php;
root $vhostdir;
#error_page 404 /404.html;
if ( \$query_string ~* ".*[\;'\<\>].*" ){
        return 404;
        }
$anti_hotlinking
`echo -e $ngx_pagespeed`
location / {
        try_files \$uri @apache;
        }

location @apache {
        internal;
        proxy_pass http://127.0.0.1:8080;
	}

location ~ .*\.(php|php5)?$ {
        proxy_pass http://127.0.0.1:8080;
        }
location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|flv|ico)$ {
        expires 30d;
        }

location ~ .*\.(js|css)?$ {
        expires 7d;
        }
}
EOF

echo
$web_install_dir/sbin/nginx -t
if [ $? == 0 ];then
        echo "Restart Nginx......"
        $web_install_dir/sbin/nginx -s reload
else
        rm -rf $web_install_dir/conf/vhost/$domain.conf
	echo -e "Create virtualhost ... \033[31m[FAILED]\033[0m"
fi

# Apache
[ "`$apache_install_dir/bin/apachectl -v | awk -F'.' /version/'{print $2}'`" == '4' ] && R_TMP='Require all granted' || R_TMP=
[ ! -d $apache_install_dir/conf/vhost ] && mkdir $apache_install_dir/conf/vhost
cat > $apache_install_dir/conf/vhost/$domain.conf << EOF
<VirtualHost *:8080>
    ServerAdmin admin@linuxeye.com
    DocumentRoot "$vhostdir"
    ServerName $domain
    $Domain_alias
    ErrorLog "/home/wwwlogs/${domain}_error_apache.log"
    $A_log
<Directory "$vhostdir">
    SetOutputFilter DEFLATE
    Options FollowSymLinks
    $R_TMP
    AllowOverride All
    Order allow,deny
    Allow from all
    DirectoryIndex index.html index.php
</Directory>
</VirtualHost>
EOF

echo
$apache_install_dir/bin/apachectl -t
if [ $? == 0 ];then
        echo "Restart Apache......"
        /etc/init.d/httpd restart
else
        rm -rf $apache_install_dir/conf/vhost/$domain.conf
	exit 1
fi
printf "
#######################################################################
#        LANMP for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+          #
# For more information please visit http://blog.linuxeye.com/31.html  #
#######################################################################
"
echo -e "`printf "%-32s" "Your domain:"`\033[32m$domain\033[0m"
echo -e "`printf "%-32s" "Nginx Virtualhost conf:"`\033[32m$web_install_dir/conf/vhost/$domain.conf\033[0m"
echo -e "`printf "%-32s" "Apache Virtualhost conf:"`\033[32m$apache_install_dir/conf/vhost/$domain.conf\033[0m"
echo -e "`printf "%-32s" "Directory of:"`\033[32m$vhostdir\033[0m"
[ "$rewrite_yn" == 'y' ] && echo -e "`printf "%-32s" "Rewrite rule:"`\033[32m$rewrite\033[0m" 
}

if [ -d "$web_install_dir" -a ! -d "$apache_install_dir" ];then
	HHVM_YN
	Input_domain
	Nginx_anti_hotlinking
	Nginx_rewrite
	Nginx_log
	Create_nginx_conf
elif [ ! -d "$web_install_dir" -a -d "$apache_install_dir" ];then
	HHVM_YN
	Input_domain
	Apache_log
	Create_apache_conf
elif [ -d "$web_install_dir" -a -d "$apache_install_dir" ];then
	HHVM_YN
	Input_domain
	Nginx_anti_hotlinking
	#Nginx_rewrite
	Nginx_log
	Apache_log
	Create_nginx_apache_conf
fi 
