#!/bin/bash

# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script, please use root to create vhost" && exit 1

echo "#######################################################################"
echo "#                    LNMP for CentOS/RadHat 5/6                       #"
echo "# For more information please visit https://github.com/lj2007331/lnmp #"
echo "#######################################################################"
echo ''

while :
do
	read -p "Please input domain(example: www.test.com test.com):" domain
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

read -p "Do you want to add more domain name? (y/n)" add_more_domainame
if [ "$add_more_domainame" == 'y' ]; then
	while :
	do
		read -p "Type domainname,example(test.com bbs.test.com):" moredomain
		if [ -z "`echo $moredomain | grep '.*\..*'`" ]; then
			echo -e "\033[31minput error\033[0m"
		else
			echo "################################"
			echo domain list="$moredomain"
			echo "################################"
			moredomainame=" $moredomain"
			break
		fi
	done
fi

echo "Please input the directory for the domain:$domain :"
read -p "(Default directory: /home/wwwroot/$domain):" vhostdir
if [ -z "$vhostdir" ]; then
	vhostdir="/home/wwwroot/$domain"
fi
echo "################################"
echo Virtual Host Directory="$vhostdir"
echo "################################"

echo "################################"
read -p "Allow access_log? (y/n)" access_log
echo "################################"

if [ "$access_log" == 'n' ]; then
	al="access_log off;"
else
	al="access_log  logs/$domain.log;"
	echo "################################"
	echo You access log file="/usr/local/nginx/logs/$domain.log"
	echo "################################"
fi


if [ ! -d /usr/local/nginx/conf/vhost ]; then
	mkdir /usr/local/nginx/conf/vhost
fi

echo "Create Virtul Host directory......"
mkdir -p $vhostdir
echo "set permissions of Virtual Host directory......"
chown -R www.www $vhostdir

cat >/usr/local/nginx/conf/vhost/$domain.conf<<EOF
        server {
        listen  80;
        server_name     $domain$moredomainame;
	$al
        root $vhostdir;
        error_page  404  /404.html;
        index index.html index.htm index.jsp index.php ;
        location ~ .*\.(php|php5)?$  {
        #fastcgi_pass  unix:/tmp/php-cgi.sock;
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
echo "# For more information please visit https://github.com/lj2007331/lnmp #"
echo "#######################################################################"
echo ''
echo "Your domain:$domain"
echo "Directory of $domain:$vhostdir"
echo ''
echo "#######################################################################"
