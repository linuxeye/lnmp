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
cd nginx-1.4.2/
make clean
if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ;then
./configure --prefix=$nginx_install_dir --user=www --group=www --with-http_stub_status_module --with-http_ssl_module \
--add-module=../ngx_pagespeed-release-1.6.29.5-beta \
--with-cc-opt='-DLINUX=2 -D_REENTRANT -D_LARGEFILE64_SOURCE -pthread'
else
./configure --prefix=$nginx_install_dir --user=www --group=www --with-http_stub_status_module --with-http_ssl_module \
--add-module=../ngx_pagespeed-release-1.6.29.5-beta \
--with-cc-opt='-DLINUX=2 -D_REENTRANT -D_LARGEFILE64_SOURCE -march=i686 -pthread'
fi
make
if [ -f "objs/nginx" ];then
	/bin/mv $nginx_install_dir/sbin/nginx $nginx_install_dir/sbin/nginx$(date +%m%d)
	/bin/cp objs/nginx $nginx_install_dir/sbin/nginx
	kill -USR2 `cat /var/run/nginx.pid`
	kill -QUIT `cat /var/run/nginx.pid.oldbin`
	mkdir /var/ngx_pagespeed_cache
	chown www.www /var/ngx_pagespeed_cache
	/bin/cp $lnmp_dir/vhost.sh $lnmp_dir/vhost_ngx_pagespeed.sh
	sed -i 's@root $vhostdir;@root $vhostdir;\n\tpagespeed on;\n\tpagespeed FileCachePath /var/ngx_pagespeed_cache;\n\tpagespeed RewriteLevel CoreFilters;\n\tpagespeed EnableFilters local_storage_cache;\n\tpagespeed EnableFilters collapse_whitespace,remove_comments;\n\tpagespeed EnableFilters outline_css;\n\tpagespeed EnableFilters flatten_css_imports;\n\tpagespeed EnableFilters move_css_above_scripts;\n\tpagespeed EnableFilters move_css_to_head;\n\tpagespeed EnableFilters outline_javascript;\n\tpagespeed EnableFilters combine_javascript;\n\tpagespeed EnableFilters combine_css;\n\tpagespeed EnableFilters rewrite_javascript;\n\tpagespeed EnableFilters rewrite_css,sprite_images;\n\tpagespeed EnableFilters rewrite_style_attributes;\n\tpagespeed EnableFilters recompress_images;\n\tpagespeed EnableFilters resize_images;\n\tpagespeed EnableFilters convert_meta_tags;\n\tlocation ~ "\\.pagespeed\\.([a-z]\\.)?[a-z]{2}\\.[^.]{10}\\.[^.]+" { add_header "" ""; }\n\tlocation ~ "^/ngx_pagespeed_static/" { }\n\tlocation ~ "^/ngx_pagespeed_beacon$" { }\n\tlocation /ngx_pagespeed_statistics { allow 127.0.0.1; deny all; }\n\tlocation /ngx_pagespeed_message { allow 127.0.0.1; deny all; }@' $lnmp_dir/vhost_ngx_pagespeed.sh
	echo -e "\033[32minstall ngx_pagespeed module successfully! \033[0m"
	echo -e "`printf "%-40s" "add ngx_pagespeed Virtual Hosts:"`\033[32m$lnmp_dir/vhost_ngx_pagespeed.sh\033[0m"
else
	echo -e "`printf "%-40s" "add Virtual Hosts:"`\033[31minstall ngx_pagespeed failed\033[0m"
	kill -9 $$
fi
}
