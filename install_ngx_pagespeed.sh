#!/bin/bash
echo "#######################################################################"
echo "#                    LNMP for CentOS/RadHat 5/6                       #"
echo "# For more information please visit http://blog.linuxeye.com/318.html #"
echo "#######################################################################"
echo ''
read -p "Do you want to install ngx_pagespeed? (y/n)" nps_yn
if [ $nps_yn == 'y' ];then
cd /root/lnmp/source
rm -rf release* ngx_pagespeed-release*
wget --no-check-certificate https://github.com/pagespeed/ngx_pagespeed/archive/release-1.6.29.5-beta.zip
unzip -q release-1.6.29.5-beta
wget https://dl.google.com/dl/page-speed/psol/1.6.29.5.tar.gz
tar xzf 1.6.29.5.tar.gz -C ngx_pagespeed-release-1.6.29.5-beta
cd nginx-1.4.2/
make clean
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ;then
./configure --prefix=/usr/local/nginx --user=www --group=www --with-http_stub_status_module --with-http_ssl_module \
--add-module=../ngx_pagespeed-release-1.6.29.5-beta \
--with-cc-opt='-DLINUX=2 -D_REENTRANT -D_LARGEFILE64_SOURCE -pthread'
else
./configure --prefix=/usr/local/nginx --user=www --group=www --with-http_stub_status_module --with-http_ssl_module \
--add-module=../ngx_pagespeed-release-1.6.29.5-beta \
--with-cc-opt='-DLINUX=2 -D_REENTRANT -D_LARGEFILE64_SOURCE -march=i686 -pthread'
fi
make
if [ -f "objs/nginx" ];then
	/bin/mv /usr/local/nginx/sbin/nginx /usr/local/nginx/sbin/nginx$(date +%m%d)
	/bin/cp objs/nginx /usr/local/nginx/sbin/nginx
	kill -USR2 `cat /usr/local/nginx/logs/nginx.pid`
	kill -QUIT `cat /usr/local/nginx/logs/nginx.pid.oldbin`
	mkdir /var/ngx_pagespeed_cache
	chown www.www /var/ngx_pagespeed_cache
	/bin/cp /root/lnmp/vhost.sh /root/lnmp/vhost_ngx_pagespeed.sh
	sed -i 's@root $vhostdir;@root $vhostdir;\n\tpagespeed on;\n\tpagespeed FileCachePath /var/ngx_pagespeed_cache;\n\tlocation ~ "\\.pagespeed\\.([a-z]\\.)?[a-z]{2}\\.[^.]{10}\\.[^.]+" { add_header "" ""; }\n\tlocation ~ "^/ngx_pagespeed_static/" { }\n\tlocation ~ "^/ngx_pagespeed_beacon$" { }\n\tlocation /ngx_pagespeed_statistics { allow 127.0.0.1; deny all; }\n\tlocation /ngx_pagespeed_message { allow 127.0.0.1; deny all; }@' /root/lnmp/vhost_ngx_pagespeed.sh
	echo -e "\033[32minstall ngx_pagespeed module successfully! \033[0m"
	echo -e "add Virtual Hosts:               \033[32m/root/lnmp/vhost.sh\033[0m"
	echo -e "add ngx_pagespeed Virtual Hosts: \033[32m/root/lnmp/vhost_ngx_pagespeed.sh\033[0m"
else
	echo -e "add Virtual Hosts:               \033[31minstall ngx_pagespeed failed\033[0m"
fi
fi
