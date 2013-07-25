#!/bin/bash
cd /root/lnmp/source
wget https://github.com/pagespeed/ngx_pagespeed/archive/release-1.6.29.3-beta.zip
unzip -q release-1.6.29.3-beta
wget https://dl.google.com/dl/page-speed/psol/1.6.29.3.tar.gz
tar xzf 1.6.29.3.tar.gz -C ngx_pagespeed-release-1.6.29.3-beta
cd nginx-1.4.2/
make clean
./configure --prefix=/usr/local/nginx --user=www --group=www --with-http_stub_status_module --with-http_ssl_module \
--add-module=../ngx_pagespeed-release-1.6.29.3-beta \
--with-cc-opt='-DLINUX=2 -D_REENTRANT -D_LARGEFILE64_SOURCE -march=i686 -pthread'
make
mv /usr/local/nginx/sbin/nginx /usr/local/nginx/sbin/nginx$(date +%m%d)
/bin/cp objs/nginx /usr/local/nginx/sbin/nginx
kill -USR2 `cat /usr/local/nginx/logs/nginx.pid`
kill -QUIT `cat /usr/local/nginx/logs/nginx.pid.oldbin`
mkdir /var/ngx_pagespeed_cache
chown www.www /var/ngx_pagespeed_cache
cp /root/lnmp/vhost.sh /root/lnmp/vhost_no_ngx_pagespeed.sh
sed -i 's@root $vhostdir;@root $vhostdir;\n\tpagespeed on;\n\tpagespeed FileCachePath /var/ngx_pagespeed_cache;\n\tlocation ~ "\\.pagespeed\\.([a-z]\\.)?[a-z]{2}\\.[^.]{10}\\.[^.]+" { add_header "" ""; }\n\tlocation ~ "^/ngx_pagespeed_static/" { }\n\tlocation ~ "^/ngx_pagespeed_beacon$" { }\n\tlocation /ngx_pagespeed_statistics { allow 127.0.0.1; deny all; }\n\tlocation /ngx_pagespeed_message { allow 127.0.0.1; deny all; }@' /root/lnmp/vhost.sh
