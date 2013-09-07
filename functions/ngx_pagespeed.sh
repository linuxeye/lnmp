#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_ngx_pagespeed()
{
cd $lnmp_dir/src
. ../functions/download.sh 
. ../options.conf

rm -rf release* ngx_pagespeed-release*
src_url=https://dl.google.com/dl/page-speed/psol/1.6.29.5.tar.gz && Download_src
[ -s "release-1.6.29.5-beta" ] && echo "release-1.6.29.5-beta found" || wget -c --no-check-certificate https://github.com/pagespeed/ngx_pagespeed/archive/release-1.6.29.5-beta.zip

unzip -q release-1.6.29.5-beta
tar xzf 1.6.29.5.tar.gz -C ngx_pagespeed-release-1.6.29.5-beta
[ "$Web_server" == '1' ] && cd nginx-1.4.2/
[ "$Web_server" == '2' ] && cd tengine-1.5.1/
make clean

if [ "$je_tc_malloc" == '1' ];then
	[ "$Web_server" == '1' ] && malloc_module="--with-ld-opt='-ljemalloc'"
	[ "$Web_server" == '2' ] && malloc_module='--with-jemalloc'
elif [ "$je_tc_malloc" == '2' ];then
        malloc_module='--with-google_perftools_module'
fi

[ "$Web_server" == '2' ] && tengine_options='--with-http_concat_module=shared --with-http_sysguard_module=shared'

if [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 64 ] ;then
	./configure --prefix=$web_install_dir --user=www --group=www --with-http_stub_status_module --with-http_ssl_module --with-http_flv_module --with-http_gzip_static_module --add-module=../ngx_pagespeed-release-1.6.29.5-beta --with-cc-opt='-DLINUX=2 -D_REENTRANT -D_LARGEFILE64_SOURCE -pthread' $malloc_module $tengine_options
else
	./configure --prefix=$web_install_dir --user=www --group=www --with-http_stub_status_module --with-http_ssl_module --with-http_flv_module --with-http_gzip_static_module --add-module=../ngx_pagespeed-release-1.6.29.5-beta --with-cc-opt='-DLINUX=2 -D_REENTRANT -D_LARGEFILE64_SOURCE -march=i686 -pthread' $malloc_module $tengine_options
fi

make
if [ -f "objs/nginx" ];then
	/bin/mv $web_install_dir/sbin/nginx $web_install_dir/sbin/nginx$(date +%m%d)
	/bin/cp objs/nginx $web_install_dir/sbin/nginx
	kill -USR2 `cat /var/run/nginx.pid`
	kill -QUIT `cat /var/run/nginx.pid.oldbin`
	mkdir /var/ngx_pagespeed_cache
	chown -R www.www /var/ngx_pagespeed_cache
	echo -e "\033[32minstall ngx_pagespeed module successfully! \033[0m"
else
	echo -e "\033[31minstall ngx_pagespeed failed\033[0m"
fi
cd ../
}
