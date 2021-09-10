#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_OpenResty() {
  pushd ${oneinstack_dir}/src > /dev/null
  id -g ${run_group} >/dev/null 2>&1
  [ $? -ne 0 ] && groupadd ${run_group}
  id -u ${run_user} >/dev/null 2>&1
  [ $? -ne 0 ] && useradd -g ${run_group} -M -s /sbin/nologin ${run_user}

  tar xzf pcre-${pcre_ver}.tar.gz
  tar xzf openresty-${openresty_ver}.tar.gz
  tar xzf openssl-${openssl11_ver}.tar.gz
  pushd openresty-${openresty_ver} > /dev/null

  # close debug
  sed -i 's@CFLAGS="$CFLAGS -g"@#CFLAGS="$CFLAGS -g"@' bundle/nginx-${openresty_ver%.*}/auto/cc/gcc # close debug

  [ ! -d "${openresty_install_dir}" ] && mkdir -p ${openresty_install_dir}
  ./configure --prefix=${openresty_install_dir} --user=${run_user} --group=${run_group} --with-http_stub_status_module --with-http_sub_module --with-http_v2_module --with-http_ssl_module --with-http_gzip_static_module --with-http_realip_module --with-http_flv_module --with-http_mp4_module --with-openssl=../openssl-${openssl11_ver} --with-pcre=../pcre-${pcre_ver} --with-pcre-jit --with-ld-opt='-ljemalloc -Wl,-u,pcre_version' ${nginx_modules_options}
  make -j ${THREAD} && make install
  if [ -e "${openresty_install_dir}/nginx/conf/nginx.conf" ]; then
    popd > /dev/null
    rm -rf pcre-${pcre_ver} openssl-${openssl11_ver} openresty-${openresty_ver}
    echo "${CSUCCESS}OpenResty installed successfully! ${CEND}"
  else
    rm -rf ${openresty_install_dir}
    echo "${CFAILURE}OpenResty install failed, Please Contact the author! ${CEND}"
    kill -9 $$
  fi

  [ -z "`grep ^'export PATH=' /etc/profile`" ] && echo "export PATH=${openresty_install_dir}/nginx/sbin:\$PATH" >> /etc/profile
  [ -n "`grep ^'export PATH=' /etc/profile`" -a -z "`grep ${openresty_install_dir} /etc/profile`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=${openresty_install_dir}/nginx/sbin:\1@" /etc/profile
  . /etc/profile

  if [ -e /bin/systemctl ]; then
    /bin/cp ../init.d/nginx.service /lib/systemd/system/
    sed -i "s@/usr/local/nginx@${openresty_install_dir}/nginx@g" /lib/systemd/system/nginx.service
    systemctl enable nginx
  else
    [ "${PM}" == 'yum' ] && { /bin/cp ../init.d/Nginx-init-RHEL /etc/init.d/nginx; sed -i "s@/usr/local/nginx@${openresty_install_dir}/nginx@g" /etc/init.d/nginx; chkconfig --add nginx; chkconfig nginx on; }
    [ "${PM}" == 'apt-get' ] && { /bin/cp ../init.d/Nginx-init-Ubuntu /etc/init.d/nginx; sed -i "s@/usr/local/nginx@${openresty_install_dir}/nginx@g" /etc/init.d/nginx; update-rc.d nginx defaults; }
  fi

  mv ${openresty_install_dir}/nginx/conf/nginx.conf{,_bk}
  if [ "${apache_flag}" == 'y' ] || [ -e "${apache_install_dir}/bin/httpd" ]; then
    /bin/cp ../config/nginx_apache.conf ${openresty_install_dir}/nginx/conf/nginx.conf 
  elif { [[ ${tomcat_option} =~ ^[1-4]$ ]] || [ -e "${tomcat_install_dir}/conf/server.xml" ]; } && { [[ ! ${php_option} =~ ^[1-9]$|^10$ ]] && [ ! -e "${php_install_dir}/bin/php" ]; }; then
    /bin/cp ../config/nginx_tomcat.conf ${openresty_install_dir}/nginx/conf/nginx.conf 
  else
    /bin/cp ../config/nginx.conf ${openresty_install_dir}/nginx/conf/nginx.conf
    [[ "${php_option}" =~ ^[1-9]$|^10$ ]] && [ -z "`grep '/php-fpm_status' ${openresty_install_dir}/nginx/conf/nginx.conf`" ] &&  sed -i "s@index index.html index.php;@index index.html index.php;\n    location ~ /php-fpm_status {\n        #fastcgi_pass remote_php_ip:9000;\n        fastcgi_pass unix:/dev/shm/php-cgi.sock;\n        fastcgi_index index.php;\n        include fastcgi.conf;\n        allow 127.0.0.1;\n        deny all;\n        }@" ${openresty_install_dir}/nginx/conf/nginx.conf
  fi
  cat > ${openresty_install_dir}/nginx/conf/proxy.conf << EOF
proxy_connect_timeout 300s;
proxy_send_timeout 900;
proxy_read_timeout 900;
proxy_buffer_size 32k;
proxy_buffers 4 64k;
proxy_busy_buffers_size 128k;
proxy_redirect off;
proxy_hide_header Vary;
proxy_set_header Accept-Encoding '';
proxy_set_header Referer \$http_referer;
proxy_set_header Cookie \$http_cookie;
proxy_set_header Host \$host;
proxy_set_header X-Real-IP \$remote_addr;
proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto \$scheme;
EOF
  sed -i "s@/data/wwwroot/default@${wwwroot_dir}/default@" ${openresty_install_dir}/nginx/conf/nginx.conf
  sed -i "s@/data/wwwlogs@${wwwlogs_dir}@g" ${openresty_install_dir}/nginx/conf/nginx.conf
  sed -i "s@^user www www@user ${run_user} ${run_group}@" ${openresty_install_dir}/nginx/conf/nginx.conf

  # logrotate nginx log
  cat > /etc/logrotate.d/nginx << EOF
${wwwlogs_dir}/*nginx.log {
  daily
  rotate 5
  missingok
  dateext
  compress
  notifempty
  sharedscripts
  postrotate
    [ -e /var/run/nginx.pid ] && kill -USR1 \`cat /var/run/nginx.pid\`
  endscript
}
EOF
  popd > /dev/null
  ldconfig
  service nginx start
}
