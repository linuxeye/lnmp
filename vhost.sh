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
. ./include/get_char.sh

# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; } 

Usage() {
printf "
Usage: $0 [ ${CMSG}add${CEND} | ${CMSG}del${CEND} ]
${CMSG}add${CEND}    --->Add Virtualhost
${CMSG}del${CEND}    --->Delete Virtualhost

"
}

Choose_env() {
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
    NGX_CONF=$(echo -e "location ~ .*\.(php|php5)?$ {\n    #fastcgi_pass remote_php_ip:9000;\n    fastcgi_pass unix:/dev/shm/php-cgi.sock;\n    fastcgi_index index.php;\n    include fastcgi.conf;\n    }")
elif [ "$NGX_FLAG" == 'java' ];then
    NGX_CONF=$(echo -e "location ~ {\n    proxy_pass http://127.0.0.1:8080;\n    include proxy.conf;\n    }")
elif [ "$NGX_FLAG" == 'hhvm' ];then
    NGX_CONF=$(echo -e "location ~ .*\.(php|php5)?$ {\n    fastcgi_pass unix:/var/log/hhvm/sock;\n    fastcgi_index index.php;\n    fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;\n    include fastcgi_params;\n    }")
fi
}

Input_Add_domain() {
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

if [ -e "$web_install_dir/conf/vhost/$domain.conf" -o -e "$apache_install_dir/conf/vhost/$domain.conf" -o -e "$tomcat_install_dir/conf/vhost/$domain.xml" ]; then
    [ -e "$web_install_dir/conf/vhost/$domain.conf" ] && echo -e "$domain in the Nginx/Tengine already exist! \nYou can delete ${CMSG}$web_install_dir/conf/vhost/$domain.conf${CEND} and re-create"
    [ -e "$apache_install_dir/conf/vhost/$domain.conf" ] && echo -e "$domain in the Apache already exist! \nYou can delete ${CMSG}$apache_install_dir/conf/vhost/$domain.conf${CEND} and re-create"
    [ -e "$tomcat_install_dir/conf/vhost/$domain.xml" ] && echo -e "$domain in the Tomcat already exist! \nYou can delete ${CMSG}$tomcat_install_dir/conf/vhost/$domain.xml${CEND} and re-create"
    exit
else
    echo "domain=$domain"
fi

while :
do
    echo
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
    Apache_Domain_alias=ServerAlias$moredomainame
    Tomcat_Domain_alias=$(for D in `echo $moredomainame`; do echo "<Alias>$D</Alias>"; done)
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

Nginx_anti_hotlinking() {
while :
do
    echo
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
    anti_hotlinking=$(echo -e "location ~ .*\.(wma|wmv|asf|mp3|mmf|zip|rar|jpg|gif|png|swf|flv)$ {\n    valid_referers none blocked $domain_allow_all;\n    if (\$invalid_referer) {\n        #rewrite ^/ http://www.linuxeye.com/403.html;\n        return 403;\n        }\n    }")
else
    anti_hotlinking=
fi
}

Nginx_rewrite() {
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
    echo "${CMSG}wordpress${CEND},${CMSG}discuz${CEND},${CMSG}opencart${CEND},${CMSG}thinkphp${CEND},${CMSG}laravel${CEND},${CMSG}typecho${CEND},${CMSG}ecshop${CEND},${CMSG}drupal${CEND},${CMSG}joomla${CEND} rewrite was exist."
    read -p "(Default rewrite: other):" rewrite
    if [ "$rewrite" == "" ]; then
    	rewrite="other"
    fi
    echo "You choose rewrite=${CMSG}$rewrite${CEND}"
    [ "$NGX_FLAG" == 'php' -a "$rewrite" == "thinkphp" ] && NGX_CONF=$(echo -e "location ~ \.php {\n    #fastcgi_pass remote_php_ip:9000;\n    fastcgi_pass unix:/dev/shm/php-cgi.sock;\n    fastcgi_index index.php;\n    include fastcgi_params;\n    set \$real_script_name \$fastcgi_script_name;\n        if (\$fastcgi_script_name ~ \"^(.+?\.php)(/.+)\$\") {\n        set \$real_script_name \$1;\n        set \$path_info \$2;\n        }\n    fastcgi_param SCRIPT_FILENAME \$document_root\$real_script_name;\n    fastcgi_param SCRIPT_NAME \$real_script_name;\n    fastcgi_param PATH_INFO \$path_info;\n    }")
    if [ -e "config/$rewrite.conf" ];then
    	/bin/cp config/$rewrite.conf $web_install_dir/conf/$rewrite.conf
    else
    	touch "$web_install_dir/conf/$rewrite.conf"
    fi
fi
}

Nginx_log() {
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

Create_nginx_tomcat_conf() {
[ ! -d $web_install_dir/conf/vhost ] && mkdir $web_install_dir/conf/vhost
cat > $web_install_dir/conf/vhost/$domain.conf << EOF
server {
listen 80;
server_name $domain$moredomainame;
$N_log
index index.html index.htm index.jsp;
root $vhostdir;
$anti_hotlinking
location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|flv|ico)$ {
    expires 30d;
    access_log off;
    }
location ~ .*\.(js|css)?$ {
    expires 7d;
    access_log off;
    }
$NGX_CONF
}
EOF

cat > $tomcat_install_dir/conf/vhost/$domain.xml << EOF
<Host name="$domain" appBase="webapps" unpackWARs="true" autoDeploy="true"> $Tomcat_Domain_alias
  <Context path="" docBase="$vhostdir" debug="0" reloadable="false" crossContext="true"/>
  <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
         prefix="${domain}_access_log." suffix=".txt" pattern="%h %l %u %t &quot;%r&quot; %s %b" />
</Host>
EOF
[ -z "`grep -o "${domain}-vhost SYSTEM" $tomcat_install_dir/conf/server.xml`" ] && sed -i "/localhost-vhost SYSTEM/a<\!ENTITY ${domain}-vhost SYSTEM \"file://$tomcat_install_dir/conf/vhost/$domain.xml\">" $tomcat_install_dir/conf/server.xml
[ -z "`grep -o "${domain}-vhost;" $tomcat_install_dir/conf/server.xml`" ] && sed -i "s@localhost-vhost;@&\n      \&${domain}-vhost;@" $tomcat_install_dir/conf/server.xml

echo
$web_install_dir/sbin/nginx -t
if [ $? == 0 ];then
    echo "Reload Nginx......"
    $web_install_dir/sbin/nginx -s reload
    /etc/init.d/tomcat restart
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
echo "`printf "%-28s" "Your domain:"`${CMSG}$domain${CEND}"
echo "`printf "%-28s" "Nginx Virtualhost conf:"`${CMSG}$web_install_dir/conf/vhost/$domain.conf${CEND}"
echo "`printf "%-28s" "Tomcat Virtualhost conf:"`${CMSG}$tomcat_install_dir/conf/vhost/$domain.xml${CEND}"
echo "`printf "%-28s" "Directory of:"`${CMSG}$vhostdir${CEND}"

}

Create_nginx_php-fpm_hhvm_conf() {
[ ! -d $web_install_dir/conf/vhost ] && mkdir $web_install_dir/conf/vhost
cat > $web_install_dir/conf/vhost/$domain.conf << EOF
server {
listen 80;
server_name $domain$moredomainame;
$N_log
index index.html index.htm index.php;
include $rewrite.conf;
root $vhostdir;
$anti_hotlinking
$NGX_CONF
location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|flv|ico)$ {
    expires 30d;
    access_log off;
    }
location ~ .*\.(js|css)?$ {
    expires 7d;
    access_log off;
    }
}
EOF

echo
$web_install_dir/sbin/nginx -t
if [ $? == 0 ];then
    echo "Reload Nginx......"
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
echo "`printf "%-20s" "Your domain:"`${CMSG}$domain${CEND}"
echo "`printf "%-20s" "Virtualhost conf:"`${CMSG}$web_install_dir/conf/vhost/$domain.conf${CEND}"
echo "`printf "%-20s" "Directory of:"`${CMSG}$vhostdir${CEND}"
[ "$rewrite_yn" == 'y' ] && echo "`printf "%-20s" "Rewrite rule:"`${CMSG}$rewrite${CEND}" 
}

Apache_log() {
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

Create_apache_conf() {
[ "`$apache_install_dir/bin/apachectl -v | awk -F'.' /version/'{print $2}'`" == '4' ] && R_TMP='Require all granted' || R_TMP=
[ ! -d $apache_install_dir/conf/vhost ] && mkdir $apache_install_dir/conf/vhost
cat > $apache_install_dir/conf/vhost/$domain.conf << EOF
<VirtualHost *:80>
    ServerAdmin admin@linuxeye.com 
    DocumentRoot "$vhostdir"
    ServerName $domain
    $Apache_Domain_alias
    ErrorLog "$wwwlogs_dir/${domain}_error_apache.log"
    $A_log
<Directory "$vhostdir">
    SetOutputFilter DEFLATE
    Options FollowSymLinks ExecCGI
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
echo "`printf "%-20s" "Your domain:"`${CMSG}$domain${CEND}"
echo "`printf "%-20s" "Virtualhost conf:"`${CMSG}$apache_install_dir/conf/vhost/$domain.conf${CEND}"
echo "`printf "%-20s" "Directory of:"`${CMSG}$vhostdir${CEND}"
}

Create_nginx_apache_mod-php_conf() {
# Nginx/Tengine
[ ! -d $web_install_dir/conf/vhost ] && mkdir $web_install_dir/conf/vhost
cat > $web_install_dir/conf/vhost/$domain.conf << EOF
server {
listen 80;
server_name $domain$moredomainame;
$N_log
index index.html index.htm index.php;
root $vhostdir;
$anti_hotlinking
location / {
    try_files \$uri @apache;
    }
location @apache {
    proxy_pass http://127.0.0.1:88;
    include proxy.conf;
    }
location ~ .*\.(php|php5|cgi|pl)?$ {
    proxy_pass http://127.0.0.1:88;
    include proxy.conf;
    }
location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|flv|ico)$ {
    expires 30d;
    access_log off;
    }
location ~ .*\.(js|css)?$ {
    expires 7d;
    access_log off;
    }
}
EOF

echo
$web_install_dir/sbin/nginx -t
if [ $? == 0 ];then
    echo "Reload Nginx......"
    $web_install_dir/sbin/nginx -s reload
else
    rm -rf $web_install_dir/conf/vhost/$domain.conf
    echo "Create virtualhost ... [${CFAILURE}FAILED${CEND}]"
fi

# Apache
[ "`$apache_install_dir/bin/apachectl -v | awk -F'.' /version/'{print $2}'`" == '4' ] && R_TMP='Require all granted' || R_TMP=
[ ! -d $apache_install_dir/conf/vhost ] && mkdir $apache_install_dir/conf/vhost
cat > $apache_install_dir/conf/vhost/$domain.conf << EOF
<VirtualHost *:88>
    ServerAdmin admin@linuxeye.com
    DocumentRoot "$vhostdir"
    ServerName $domain
    $Apache_Domain_alias
    ErrorLog "$wwwlogs_dir/${domain}_error_apache.log"
    $A_log
<Directory "$vhostdir">
    SetOutputFilter DEFLATE
    Options FollowSymLinks ExecCGI
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
echo "`printf "%-28s" "Your domain:"`${CMSG}$domain${CEND}"
echo "`printf "%-28s" "Nginx Virtualhost conf:"`${CMSG}$web_install_dir/conf/vhost/$domain.conf${CEND}"
echo "`printf "%-28s" "Apache Virtualhost conf:"`${CMSG}$apache_install_dir/conf/vhost/$domain.conf${CEND}"
echo "`printf "%-28s" "Directory of:"`${CMSG}$vhostdir${CEND}"
[ "$rewrite_yn" == 'y' ] && echo "`printf "%-28s" "Rewrite rule:"`${CMSG}$rewrite${CEND}" 
}

Add_Vhost() {
    if [ -e "$web_install_dir/sbin/nginx" -a ! -e "$apache_install_dir/modules/libphp5.so" ];then
        Choose_env
        Input_Add_domain
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
        Input_Add_domain
        Apache_log
        Create_apache_conf
    elif [ -e "$web_install_dir/sbin/nginx" -a -e "$apache_install_dir/modules/libphp5.so" ];then
        Choose_env
        Input_Add_domain
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
}

Del_NGX_Vhost() {
    if [ -e "$web_install_dir/sbin/nginx" ];then
        [ -d "$web_install_dir/conf/vhost" ] && Domain_List=`ls $web_install_dir/conf/vhost | sed "s@.conf@@g"`
        if [ -n "$Domain_List" ];then
            echo
            echo "Virtualhost list:"
	    echo ${CMSG}$Domain_List${CEND}
            while :
            do
                echo
                read -p "Please input a domain you want to delete: " domain
                if [ -z "`echo $domain | grep '.*\..*'`" ]; then
                    echo "${CWARNING}input error! ${CEND}"
                else
                    if [ -e "$web_install_dir/conf/vhost/${domain}.conf" ];then
                        Directory=`grep ^root $web_install_dir/conf/vhost/${domain}.conf | awk -F'[ ;]' '{print $2}'`
                        rm -rf $web_install_dir/conf/vhost/${domain}.conf
                        $web_install_dir/sbin/nginx -s reload
                        while :
                        do
                            echo
                            read -p "Do you want to delete Virtul Host directory? [y/n]: " Del_NGX_wwwroot_yn 
                            if [ "$Del_NGX_wwwroot_yn" != 'y' ] && [ "$Del_NGX_wwwroot_yn" != 'n' ];then
                                echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
                            else
                                break
                            fi
                        done
                        if [ "$Del_NGX_wwwroot_yn" == 'y' ];then
                            echo "Press Ctrl+c to cancel or Press any key to continue..."
                            char=`get_char`
                            rm -rf $Directory
                        fi
                        echo "${CSUCCESS}Domain: ${domain} has been deleted.${CEND}"
                    else
                        echo "${CWARNING}Virtualhost: $domain was not exist! ${CEND}"
                    fi
                    break
                fi
            done

        else
            echo "${CWARNING}Virtualhost was not exist! ${CEND}"
        fi
    fi
}

Del_Apache_Vhost() {
    if [ -e "$apache_install_dir/conf/httpd.conf" ];then
        if [ -e "$web_install_dir/sbin/nginx" ];then
            rm -rf $apache_install_dir/conf/vhost/${domain}.conf 
            /etc/init.d/httpd restart
        else
            Domain_List=`ls $apache_install_dir/conf/vhost | grep -v '0.conf' | sed "s@.conf@@g"`
            if [ -n "$Domain_List" ];then
                echo
                echo "Virtualhost list:"
                echo ${CMSG}$Domain_List${CEND}
                while :
                do
                    echo
                    read -p "Please input a domain you want to delete: " domain
                    if [ -z "`echo $domain | grep '.*\..*'`" ]; then
                        echo "${CWARNING}input error! ${CEND}"
                    else
                        if [ -e "$apache_install_dir/conf/vhost/${domain}.conf" ];then
                            Directory=`grep '^<Directory' $apache_install_dir/conf/vhost/${domain}.conf | awk -F'"' '{print $2}'`
                            rm -rf $apache_install_dir/conf/vhost/${domain}.conf
                            /etc/init.d/httpd restart
                            while :
                            do
                                echo
                                read -p "Do you want to delete Virtul Host directory? [y/n]: " Del_Apache_wwwroot_yn
                                if [ "$Del_Apache_wwwroot_yn" != 'y' ] && [ "$Del_Apache_wwwroot_yn" != 'n' ];then
                                    echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
                                else
                                    break
                                fi
                            done

                            if [ "$Del_Apache_wwwroot_yn" == 'y' ];then
                                echo "Press Ctrl+c to cancel or Press any key to continue..."
                                char=`get_char`
                                rm -rf $Directory
                            fi
                            echo "${CSUCCESS}Domain: ${domain} has been deleted.${CEND}"
                        else
                            echo "${CWARNING}Virtualhost: $domain was not exist! ${CEND}"
                        fi
                        break
                    fi
                done

            else
                echo "${CWARNING}Virtualhost was not exist! ${CEND}"
            fi
        fi
    fi
}

Del_Tomcat_Vhost() {
    if [ -e "$tomcat_install_dir/conf/server.xml" ] && [ -n "`grep ${domain}-vhost $tomcat_install_dir/conf/server.xml`" ];then
        sed -i /${domain}-vhost/d $tomcat_install_dir/conf/server.xml 
        rm -rf $tomcat_install_dir/conf/vhost/${domain}.xml
        /etc/init.d/tomcat restart
    fi
}

if [ $# == 0 ];then
    Add_Vhost 
elif [ $# == 1 ];then
    case $1 in
    add)
        Add_Vhost
        ;;

    del)
        Del_NGX_Vhost
        Del_Apache_Vhost
        Del_Tomcat_Vhost
        ;;

    *)
        Usage
        ;;
    esac
else
    Usage
fi
