#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script, please use root to create vhost" && exit 1

echo "#######################################################################"
echo "#            LNMP for CentOS/RadHat 5+ and Ubuntu 12+                 #"
echo "# For more information please visit http://blog.linuxeye.com/31.html  #"
echo "#######################################################################"
echo ''

while :
do
	read -p "Please input domain(example: www.linuxeye.com linuxeye.com):" domain
	if [ -z "`echo $domain | grep '.*\..*'`" ]; then
		echo -e "\033[31minput error\033[0m"
	else
		break
	fi
done
if [ ! -f "/usr/local/nginx/conf/vhost/$domain.conf" ]; then
	echo "################################"
	echo "domain=$domain"
	echo "################################"
else
	echo "################################"
	echo "$domain is exist!"
	echo "################################"
	exit 1
fi

while :
do
        read -p "Do you want to add more domain name? (y/n)" moredomainame_yn 
        if [ "$moredomainame_yn" != 'y' ] && [ "$moredomainame_yn" != 'n' ];then
                echo -e "\033[31minput error! please input 'y' or 'n'\033[0m"
        else
                break 
        fi
done
if [ "$moredomainame_yn" == 'y' ]; then
	while :
	do
		read -p "Type domainname,example(blog.linuxeye.com bbs.linuxeye.com):" moredomain
		if [ -z "`echo $moredomain | grep '.*\..*'`" ]; then
			echo -e "\033[31minput error\033[0m"
		else
			echo "################################"
			echo -e "domain list=\033[32m$moredomain\033[0m"
			echo "################################"
			moredomainame=" $moredomain"
			break
		fi
	done
fi

# check ngx_pagespeed and add ngx_pagespeed
script -c "/usr/local/nginx/sbin/nginx -V" -f /tmp/typescript > /dev/null 2>&1
if [ ! -z "`cat /tmp/typescript | grep ngx_pagespeed`" ];then
        rm -rf /tmp/typescript
        while :
        do
                read -p "Do you want to use ngx_pagespeed module? (y/n)" ngx_pagespeed_yn
                if [ "$ngx_pagespeed_yn" != 'y' ] && [ "$ngx_pagespeed_yn" != 'n' ];then
                        echo -e "\033[31minput error! please input 'y' or 'n'\033[0m"
                else
                        if [ "$ngx_pagespeed_yn" == 'y' ];then
                                ngx_pagespeed='pagespeed on;\npagespeed FileCachePath /var/ngx_pagespeed_cache;\npagespeed RewriteLevel CoreFilters;\npagespeed EnableFilters local_storage_cache;\npagespeed EnableFilters collapse_whitespace,remove_comments;\npagespeed EnableFilters outline_css;\npagespeed EnableFilters flatten_css_imports;\npagespeed EnableFilters move_css_above_scripts;\npagespeed EnableFilters move_css_to_head;\npagespeed EnableFilters outline_javascript;\npagespeed EnableFilters combine_javascript;\npagespeed EnableFilters combine_css;\npagespeed EnableFilters rewrite_javascript;\npagespeed EnableFilters rewrite_css,sprite_images;\npagespeed EnableFilters rewrite_style_attributes;\npagespeed EnableFilters recompress_images;\npagespeed EnableFilters resize_images;\npagespeed EnableFilters convert_meta_tags;\nlocation ~ "\\.pagespeed\\.([a-z]\\.)?[a-z]{2}\\.[^.]{10}\\.[^.]+" { add_header "" ""; }\nlocation ~ "^/ngx_pagespeed_static/" { }\nlocation ~ "^/ngx_pagespeed_beacon$" { }\nlocation /ngx_pagespeed_statistics { allow 127.0.0.1; deny all; }\nlocation /ngx_pagespeed_message { allow 127.0.0.1; deny all; }'
                        else
                                ngx_pagespeed=
                        fi
                        break
                fi
        done
fi

while :
do
        read -p "Do you want to add hotlink protection? (y/n)" anti_hotlinking_yn 
        if [ "$anti_hotlinking_yn" != 'y' ] && [ "$anti_hotlinking_yn" != 'n' ];then
                echo -e "\033[31minput error! please input 'y' or 'n'\033[0m"
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

echo "Please input the directory for the domain:$domain :"
read -p "(Default directory: /home/wwwroot/$domain):" vhostdir
if [ -z "$vhostdir" ]; then
	vhostdir="/home/wwwroot/$domain"
	echo "################################"
	echo -e "Virtual Host Directory=\033[32m$vhostdir\033[0m"
	echo "################################"
fi

while :
do
        read -p "Allow Rewrite rule? (y/n)" rewrite_yn
        if [ "$rewrite_yn" != 'y' ] && [ "$rewrite_yn" != 'n' ];then
                echo -e "\033[31minput error! please input 'y' or 'n'\033[0m"
        else
                break 
        fi
done
if [ "$rewrite_yn" == 'n' ];then
	rewrite="none"
	touch "/usr/local/nginx/conf/$rewrite.conf"
else
	echo "Please input the rewrite of programme :"
	echo -e "\033[32mwordpress\033[0m,\033[32mdiscuz\033[0m,\033[32mphpwind\033[0m,\033[32mtypecho\033[0m,\033[32mecshop\033[0m,\033[32mdrupal\033[0m rewrite was exist."
	read -p "(Default rewrite: other):" rewrite
	if [ "$rewrite" == "" ]; then
		rewrite="other"
	fi
	echo "################################"
	echo -e "You choose rewrite=\033[32m$rewrite\033[0m" 
	echo "################################"
	if [ -s "/root/lnmp/conf/$rewrite.conf" ];then
		/bin/cp /root/lnmp/conf/$rewrite.conf /usr/local/nginx/conf/$rewrite.conf
	else
		touch "/usr/local/nginx/conf/$rewrite.conf"
	fi
fi


while :
do
        read -p "Allow access_log? (y/n)" access_yn 
        if [ "$access_yn" != 'y' ] && [ "$access_yn" != 'n' ];then
                echo -e "\033[31minput error! please input 'y' or 'n'\033[0m"
        else
                break 
        fi
done
if [ "$access_yn" == 'n' ]; then
	al="access_log off;"
else
	al="access_log  /home/wwwlogs/$domain.log combined;"
	echo "################################"
	echo -e "You access log file=\033[32m/home/wwwlogs/$domain.log\033[0m"
	echo "################################"
fi


[ ! -d /usr/local/nginx/conf/vhost ] && mkdir /usr/local/nginx/conf/vhost

echo "Create Virtul Host directory......"
mkdir -p $vhostdir
echo "set permissions of Virtual Host directory......"
chown -R www.www $vhostdir

cat >/usr/local/nginx/conf/vhost/$domain.conf<<EOF
server {
listen 80;
server_name $domain$moredomainame;
$al
index index.html index.htm index.jsp index.php ;
include $rewrite.conf;
root $vhostdir;
#error_page 404 /404.html;
if ( \$query_string ~* ".*[\;'\<\>].*" ){
	return 404;
}
$anti_hotlinking
`echo -e $ngx_pagespeed`
location ~ .*\.(php|php5)?$  {
      fastcgi_pass  127.0.0.1:9000;
      fastcgi_index index.php;
      include fastcgi.conf;
	}
location ~ .*\.(htm|html|gif|jpg|jpeg|png|bmp|swf|ioc|rar|zip|txt|flv|mid|doc|ppt|pdf|xls|mp3|wma)$ {
        expires      30d;
	}

location ~ .*\.(js|css)?$ {
        expires      1h;
        }
}
EOF

echo "Test Nginx configure file......"
/usr/local/nginx/sbin/nginx -t
echo ""
echo "Restart Nginx......"
/usr/local/nginx/sbin/nginx -s reload

echo "#######################################################################"
echo "#                    LNMP for CentOS/RadHat 5/6                       #"
echo "# For more information please visit http://blog.linuxeye.com/31.html  #"
echo "#######################################################################"
echo ''
echo -e "`printf "%-32s" "Your domain"`:\033[32m$domain\033[0m"
echo -e "`printf "%-32s" "Virtualhost conf:"`\033[32m/usr/local/nginx/conf/vhost/$domain.conf\033[0m"
echo -e "`printf "%-32s" "Directory of:"`\033[32m$vhostdir\033[0m"
[ "$rewrite_yn" == 'y' ] && echo -e "`printf "%-32s" "Rewrite rule:"`\033[32m$rewrite\033[0m" 
echo ''
