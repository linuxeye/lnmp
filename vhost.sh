#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       http://oneinstack.com
#       https://github.com/lj2007331/oneinstack

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#######################################################################
#       OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+      #
#       For more information please visit http://oneinstack.com       #
#######################################################################
"

. ./options.conf
. ./include/color.sh
. ./include/check_web.sh

# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; } 

Choose_env()
{
if [ -e "$php_install_dir/bin/phpize" -a -e "$tomcat_install_dir/conf/server.xml" -a -e "/usr/bin/hhvm" ];then
    Number=111
    while :
    do
        echo
        echo 'Please choose to use environment:'
        echo -e "\t${CMSG}1${CEND}. Use php"
        echo -e "\t${CMSG}2${CEND}. Use java"
        echo -e "\t${CMSG}3${CEND}. Use hhvm"
        read -p "Please input a number:(Default 1 press Enter) " Choose_number
        [ -z "$Choose_number" ] && Choose_number=1
        if [ $Choose_number != 1 -a $Choose_number != 2 -a $Choose_number != 3 ];then
            echo "${CWARNING}input error! Please only input number 1,2,3${CEND}"
        else
            break
        fi
    done
    [ "$Choose_number" == '1' ] && NGX_FLAG=php
    [ "$Choose_number" == '2' ] && NGX_FLAG=java
    [ "$Choose_number" == '3' ] && NGX_FLAG=hhvm
elif [ -e "$php_install_dir/bin/phpize" -a -e "$tomcat_install_dir/conf/server.xml" -a ! -e "/usr/bin/hhvm" ];then
    Number=110
    while :
    do
        echo
        echo 'Please choose to use environment:'
        echo -e "\t${CMSG}1${CEND}. Use php"
        echo -e "\t${CMSG}2${CEND}. Use java"
        read -p "Please input a number:(Default 1 press Enter) " Choose_number
        [ -z "$Choose_number" ] && Choose_number=1
        if [ $Choose_number != 1 -a $Choose_number != 2 ];then
            echo "${CWARNING}input error! Please only input number 1,2${CEND}"
        else
            break
        fi
    done
    [ "$Choose_number" == '1' ] && NGX_FLAG=php
    [ "$Choose_number" == '2' ] && NGX_FLAG=java
elif [ -e "$php_install_dir/bin/phpize" -a ! -e "$tomcat_install_dir/conf/server.xml" -a ! -e "/usr/bin/hhvm" ];then
    Number=100
    NGX_FLAG=php
elif [ -e "$php_install_dir/bin/phpize" -a ! -e "$tomcat_install_dir/conf/server.xml" -a -e "/usr/bin/hhvm" ];then
    Number=101
    while :
    do
        echo
        echo 'Please choose to use environment:'
        echo -e "\t${CMSG}1${CEND}. Use php"
        echo -e "\t${CMSG}2${CEND}. Use hhvm"
        read -p "Please input a number:(Default 1 press Enter) " Choose_number
        [ -z "$Choose_number" ] && Choose_number=1
        if [ $Choose_number != 1 -a $Choose_number != 2 ];then
            echo "${CWARNING}input error! Please only input number 1,2${CEND}"
        else
            break
        fi
    done
    [ "$Choose_number" == '1' ] && NGX_FLAG=php
    [ "$Choose_number" == '2' ] && NGX_FLAG=hhvm
elif [ ! -e "$php_install_dir/bin/phpize" -a -e "$tomcat_install_dir/conf/server.xml" -a -e "/usr/bin/hhvm" ];then
    Number=011
    while :
    do
        echo
        echo 'Please choose to use environment:'
        echo -e "\t${CMSG}1${CEND}. Use java"
        echo -e "\t${CMSG}2${CEND}. Use hhvm"
        read -p "Please input a number:(Default 1 press Enter) " Choose_number
        [ -z "$Choose_number" ] && Choose_number=1
        if [ $Choose_number != 1 -a $Choose_number != 2 ];then
            echo "${CWARNING}input error! Please only input number 1,2${CEND}"
        else
            break
        fi
    done
    [ "$Choose_number" == '1' ] && NGX_FLAG=java
    [ "$Choose_number" == '2' ] && NGX_FLAG=hhvm
elif [ ! -e "$php_install_dir/bin/phpize" -a -e "$tomcat_install_dir/conf/server.xml" -a ! -e "/usr/bin/hhvm" ];then
    Number=010
    NGX_FLAG=java
elif [ ! -e "$php_install_dir/bin/phpize" -a ! -e "$tomcat_install_dir/conf/server.xml" -a -e "/usr/bin/hhvm" ];then
    Number=001
    NGX_FLAG=hhvm
else
    Number=000
    exit
fi

if [ "$NGX_FLAG" == 'php' ];then
    NGX_CONF="location ~ .*\.(php|php5)?$ {\n\t#fastcgi_pass remote_php_ip:9000;\n\tfastcgi_pass unix:/dev/shm/php-cgi.sock;\n\tfastcgi_index index.php;\n\tinclude fastcgi.conf;\n\t}"
elif [ "$NGX_FLAG" == 'java' ];then
    NGX_CONF="location ~ {\n\tproxy_set_header Host \$host;\n\tproxy_set_header X-Real-IP \$remote_addr;\n\tproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;\n\tproxy_pass http://127.0.0.1:8080;\n\t}"
elif [ "$NGX_FLAG" == 'hhvm' ];then
    NGX_CONF="location ~ .*\.(php|php5)?$ {\n\tfastcgi_pass unix:/var/log/hhvm/sock;\n\tfastcgi_index index.php;\n\tfastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;\n\tinclude fastcgi_params;\n\t}"
fi
}

Input_domain()
{
while :
do
    echo
    read -p "Please input domain(example: www.linuxeye.com): " domain
    if [ -z "`echo $domain | grep '.*\..*'`" ]; then
        echo "${CWARNING}input error! ${CEND}"
    else
        break
    fi
done

if [ -e "$web_install_dir/conf/vhost/$domain.conf" -o -e "$apache_install_dir/conf/vhost/$domain.conf" ]; then
    [ -e "$web_install_dir/conf/vhost/$domain.conf" ] && echo -e "$domain in the Nginx/Tengine already exist! \nYou can delete \033[32m$web_install_dir/conf/vhost/$domain.conf\033[0m and re-create"
    [ -e "$apache_install_dir/conf/vhost/$domain.conf" ] && echo -e "$domain in the Apache already exist! \nYou can delete \033[32m$apache_install_dir/conf/vhost/$domain.conf\033[0m and re-create"
    exit
else
    echo "domain=$domain"
fi

while :
do
    echo ''
    read -p "Do you want to add more domain name? [y/n]: " moredomainame_yn 
    if [ "$moredomainame_yn" != 'y' ] && [ "$moredomainame_yn" != 'n' ];then
        echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
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
            echo "${CWARNING}input error! ${CEND}"
        else
            [ "$moredomain" == "$domain" ] && echo "${CWARNING}Domain name already exists! ${CND}" && continue
            echo domain list="$moredomain"
            moredomainame=" $moredomain"
            break
        fi
    done
    Domain_alias=ServerAlias$moredomainame
fi

echo
echo "Please input the directory for the domain:$domain :"
read -p "(Default directory: $wwwroot_dir/$domain): " vhostdir
if [ -z "$vhostdir" ]; then
    vhostdir="$wwwroot_dir/$domain"
    echo "Virtual Host Directory=${CMSG}$vhostdir${CEND}"
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
        echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
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
    echo
    read -p "Allow Rewrite rule? [y/n]: " rewrite_yn
    if [ "$rewrite_yn" != 'y' ] && [ "$rewrite_yn" != 'n' ];then
        echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
        break 
    fi
done
if [ "$rewrite_yn" == 'n' ];then
    rewrite="none"
    touch "$web_install_dir/conf/$rewrite.conf"
else
    echo
    echo "Please input the rewrite of programme :"
    echo "${CMSG}wordpress${CEND},${CMSG}discuz${CEND},${CMSG}opencart${CEND},${CMSG}laravel${CEND},${CMSG}typecho${CEND},${CMSG}ecshop${CEND},${CMSG}drupal${CEND},${CMSG}joomla${CEND} rewrite was exist."
    read -p "(Default rewrite: other):" rewrite
    if [ "$rewrite" == "" ]; then
    	rewrite="other"
    fi
    echo "You choose rewrite=${CMSG}$rewrite${CEND}" 
    if [ -e "config/$rewrite.conf" ];then
    	/bin/cp config/$rewrite.conf $web_install_dir/conf/$rewrite.conf
    else
    	touch "$web_install_dir/conf/$rewrite.conf"
    fi
fi
}

Nginx_log()
{
while :
do
    echo
    read -p "Allow Nginx/Tengine access_log? [y/n]: " access_yn 
    if [ "$access_yn" != 'y' ] && [ "$access_yn" != 'n' ];then
        echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
        break 
    fi
done
if [ "$access_yn" == 'n' ]; then
    N_log="access_log off;"
else
    N_log="access_log $wwwlogs_dir/${domain}_nginx.log combined;"
    echo "You access log file=${CMSG}$wwwlogs_dir/${domain}_nginx.log${CEND}"
fi
}

Create_nginx_tomcat_conf()
{
[ -n "`grep $vhostdir $tomcat_install_dir/conf/server.xml`" ] && { echo -e "\n$vhostdir in the tomcat already exist! \nYou must manually modify the file=${MSG}$tomcat_install_dir/conf/server.xml${CEND}"; exit; }

[ ! -d $web_install_dir/conf/vhost ] && mkdir $web_install_dir/conf/vhost
cat > $web_install_dir/conf/vhost/$domain.conf << EOF
server {
listen 80;
server_name $domain$moredomainame;
$N_log
index index.html index.htm index.jsp index.php;
root $vhostdir;
$anti_hotlinking
location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|flv|ico)$ {
        expires 30d;
        }
location ~ .*\.(js|css)?$ {
        expires 7d;
        }
`echo -e $NGX_CONF`
}
EOF

sed -i "s@autoDeploy=\"true\">@autoDeploy=\"true\">\n\t<Context path=\"\" docBase=\"$vhostdir\" debug=\"0\" reloadable=\"true\" crossContext=\"true\"/>@" $tomcat_install_dir/conf/server.xml

echo
$web_install_dir/sbin/nginx -t
if [ $? == 0 ];then
    echo "Restart Nginx......"
    $web_install_dir/sbin/nginx -s reload
else
    rm -rf $web_install_dir/conf/vhost/$domain.conf
    echo "Create virtualhost ... [${CFAILURE}FAILED${CEND}]"
    exit 1
fi

printf "
#######################################################################
#       OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+      #
#       For more information please visit http://oneinstack.com       #
#######################################################################
"
echo "`printf "%-32s" "Your domain:"`${CMSG}$domain${CEND}"
echo "`printf "%-32s" "Virtualhost conf:"`${CMSG}$web_install_dir/conf/vhost/$domain.conf${CEND}"
echo "`printf "%-32s" "Directory of:"`${CMSG}$vhostdir${CEND}"

}

Create_nginx_php-fpm_hhvm_conf()
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
$anti_hotlinking
`echo -e $NGX_CONF`
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
    echo "Create virtualhost ... [${CFAILURE}FAILED${CEND}]"
    exit 1
fi

printf "
#######################################################################
#       OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+      #
#       For more information please visit http://oneinstack.com       #
#######################################################################
"
echo "`printf "%-32s" "Your domain:"`${CMSG}$domain${CEND}"
echo "`printf "%-32s" "Virtualhost conf:"`${CMSG}$web_install_dir/conf/vhost/$domain.conf${CEND}"
echo "`printf "%-32s" "Directory of:"`${CMSG}$vhostdir${CEND}"
[ "$rewrite_yn" == 'y' ] && echo "`printf "%-32s" "Rewrite rule:"`${CMSG}$rewrite${CEND}" 
}

Apache_log()
{
while :
do
    echo
    read -p "Allow Apache access_log? [y/n]: " access_yn
    if [ "$access_yn" != 'y' ] && [ "$access_yn" != 'n' ];then
        echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
        break
    fi
done

if [ "$access_yn" == 'n' ]; then
    A_log='CustomLog "/dev/null" common'
else
    A_log="CustomLog \"$wwwlogs_dir/${domain}_apache.log\" common"
    echo "You access log file=$wwwlogs_dir/${domain}_apache.log"
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
    ErrorLog "$wwwlogs_dir/${domain}_error_apache.log"
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
    echo "Create virtualhost ... [${CFAILURE}FAILED${CEND}]"
    exit 1
fi

printf "
#######################################################################
#       OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+      #
#       For more information please visit http://oneinstack.com       #
#######################################################################
"
echo "`printf "%-32s" "Your domain:"`${CMSG}$domain${CEND}"
echo "`printf "%-32s" "Virtualhost conf:"`${CMSG}$apache_install_dir/conf/vhost/$domain.conf${CEND}"
echo "`printf "%-32s" "Directory of $domain:"`${CMSG}$vhostdir${CEND}"
}

Create_nginx_apache_mod-php_conf()
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
$anti_hotlinking
location / {
	try_files \$uri @apache;
	}
location @apache {
	internal;
	proxy_pass http://127.0.0.1:9090;
	}
location ~ .*\.(php|php5)?$ {
	proxy_pass http://127.0.0.1:9090;
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
    echo "Create virtualhost ... [${CFAILURE}FAILED${CEND}]"
fi

# Apache
[ "`$apache_install_dir/bin/apachectl -v | awk -F'.' /version/'{print $2}'`" == '4' ] && R_TMP='Require all granted' || R_TMP=
[ ! -d $apache_install_dir/conf/vhost ] && mkdir $apache_install_dir/conf/vhost
cat > $apache_install_dir/conf/vhost/$domain.conf << EOF
<VirtualHost *:9090>
    ServerAdmin admin@linuxeye.com
    DocumentRoot "$vhostdir"
    ServerName $domain
    $Domain_alias
    ErrorLog "$wwwlogs_dir/${domain}_error_apache.log"
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
#       OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+      #
#       For more information please visit http://oneinstack.com       #
#######################################################################
"
echo "`printf "%-32s" "Your domain:"`${CMSG}$domain${CEND}"
echo "`printf "%-32s" "Nginx Virtualhost conf:"`${CMSG}$web_install_dir/conf/vhost/$domain.conf${CEND}"
echo "`printf "%-32s" "Apache Virtualhost conf:"`${CMSG}$apache_install_dir/conf/vhost/$domain.conf${CEND}"
echo "`printf "%-32s" "Directory of:"`${CMSG}$vhostdir${CEND}"
[ "$rewrite_yn" == 'y' ] && echo "`printf "%-32s" "Rewrite rule:"`${CMSG}$rewrite${CEND}" 
}

if [ -e "$web_install_dir/sbin/nginx" -a ! -e "$apache_install_dir/modules/libphp5.so" ];then
    Choose_env
    Input_domain
    Nginx_anti_hotlinking
    if [ "$NGX_FLAG" == 'java' ];then
        Nginx_log
        Create_nginx_tomcat_conf
    else
        Nginx_rewrite
        Nginx_log
        Create_nginx_php-fpm_hhvm_conf
    fi
elif [ ! -e "$web_install_dir/sbin/nginx" -a -e "$apache_install_dir/modules/libphp5.so" ];then
    Choose_env
    Input_domain
    Apache_log
    Create_apache_conf
elif [ -e "$web_install_dir/sbin/nginx" -a -e "$apache_install_dir/modules/libphp5.so" ];then
    Choose_env
    Input_domain
    Nginx_anti_hotlinking
    if [ "$NGX_FLAG" == 'java' ];then
        Nginx_log
        Create_nginx_tomcat_conf
    elif [ "$NGX_FLAG" == 'hhvm' ];then
        Nginx_rewrite
        Nginx_log
        Create_nginx_php-fpm_hhvm_conf
    elif [ "$NGX_FLAG" == 'php' ];then
        #Nginx_rewrite
        Nginx_log
        Apache_log
        Create_nginx_apache_mod-php_conf
    fi
fi
