#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 8+ and Ubuntu 14+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_Apache24() {
  pushd ${oneinstack_dir}/src > /dev/null
  tar xzf pcre-${pcre_ver}.tar.gz
  pushd pcre-${pcre_ver} > /dev/null
  ./configure
  make -j ${THREAD} && make install
  popd > /dev/null
  id -g ${run_group} >/dev/null 2>&1
  [ $? -ne 0 ] && groupadd ${run_group}
  id -u ${run_user} >/dev/null 2>&1
  [ $? -ne 0 ] && useradd -g ${run_group} -M -s /sbin/nologin ${run_user}
  tar xzf httpd-${apache24_ver}.tar.gz

  # install apr
  if [ ! -e "${apr_install_dir}/bin/apr-1-config" ]; then
    tar xzf apr-${apr_ver}.tar.gz
    pushd apr-${apr_ver} > /dev/null
    ./configure --prefix=${apr_install_dir}
    make -j ${THREAD} && make install
    popd > /dev/null
    rm -rf apr-${apr_ver}
  fi

  # install apr-util
  if [ ! -e "${apr_install_dir}/bin/apu-1-config" ]; then
    tar xzf apr-util-${apr_util_ver}.tar.gz
    pushd apr-util-${apr_util_ver} > /dev/null
    ./configure --prefix=${apr_install_dir} --with-apr=${apr_install_dir}
    make -j ${THREAD} && make install
    popd > /dev/null
    rm -rf apr-util-${apr_util_ver}
  fi

  # install nghttp2
  if [ ! -e "/usr/local/lib/libnghttp2.so" ]; then
    tar xzf nghttp2-${nghttp2_ver}.tar.gz
    pushd nghttp2-${nghttp2_ver} > /dev/null
    ./configure
    make -j ${THREAD} && make install
    popd > /dev/null
    [ -z "`grep /usr/local/lib /etc/ld.so.conf.d/*.conf`" ] && echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
    ldconfig
    rm -rf nghttp2-${nghttp2_ver}
  fi

  pushd httpd-${apache24_ver} > /dev/null
  [ ! -d "${apache_install_dir}" ] && mkdir -p ${apache_install_dir}
  LDFLAGS=-ldl ./configure --prefix=${apache_install_dir} --enable-mpms-shared=all --with-pcre --with-apr=${apr_install_dir} --with-apr-util=${apr_install_dir} --enable-headers --enable-mime-magic --enable-deflate --enable-proxy --enable-so --enable-dav --enable-rewrite --enable-remoteip --enable-expires --enable-static-support --enable-suexec --enable-mods-shared=most --enable-nonportable-atomics=yes --enable-ssl --with-ssl=${openssl_install_dir} --enable-http2 --with-nghttp2=/usr/local
  make -j ${THREAD} && make install
  popd > /dev/null
  unset LDFLAGS
  if [ -e "${apache_install_dir}/bin/httpd" ]; then
    echo "${CSUCCESS}Apache installed successfully! ${CEND}"
    rm -rf httpd-${apache24_ver} pcre-${pcre_ver}
  else
    rm -rf ${apache_install_dir}
    echo "${CFAILURE}Apache install failed, Please contact the author! ${CEND}" && lsb_release -a
    kill -9 $$
  fi

  [ -z "`grep ^'export PATH=' /etc/profile`" ] && echo "export PATH=${apache_install_dir}/bin:\$PATH" >> /etc/profile
  [ -n "`grep ^'export PATH=' /etc/profile`" -a -z "`grep ${apache_install_dir} /etc/profile`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=${apache_install_dir}/bin:\1@" /etc/profile
  . /etc/profile

  if [ -e /bin/systemctl ]; then
    /bin/cp ../init.d/httpd.service /lib/systemd/system/
    sed -i "s@/usr/local/apache@${apache_install_dir}@g" /lib/systemd/system/httpd.service
    systemctl enable httpd
  else
    /bin/cp ${apache_install_dir}/bin/apachectl /etc/init.d/httpd
    sed -i '2a # chkconfig: - 85 15' /etc/init.d/httpd
    sed -i '3a # description: Apache is a World Wide Web server. It is used to serve' /etc/init.d/httpd
    chmod +x /etc/init.d/httpd
    [ "${PM}" == 'yum' ] && { chkconfig --add httpd; chkconfig httpd on; }
    [ "${PM}" == 'apt-get' ] && update-rc.d httpd defaults
  fi

  sed -i "s@^User daemon@User ${run_user}@" ${apache_install_dir}/conf/httpd.conf
  sed -i "s@^Group daemon@Group ${run_group}@" ${apache_install_dir}/conf/httpd.conf
  if [[ ! ${nginx_option} =~ ^[1-3]$ ]] && [ ! -e "${web_install_dir}/sbin/nginx" ]; then
    sed -i 's/^#ServerName www.example.com:80/ServerName 0.0.0.0:80/' ${apache_install_dir}/conf/httpd.conf
    TMP_PORT=80
  elif [[ ${nginx_option} =~ ^[1-3]$ ]] || [ -e "${web_install_dir}/sbin/nginx" ]; then
    sed -i 's/^#ServerName www.example.com:80/ServerName 127.0.0.1:88/' ${apache_install_dir}/conf/httpd.conf
    sed -i 's@^Listen.*@Listen 127.0.0.1:88@' ${apache_install_dir}/conf/httpd.conf
    TMP_PORT=88
  fi
  sed -i "s@AddType\(.*\)Z@AddType\1Z\n    AddType application/x-httpd-php .php .phtml\n    AddType application/x-httpd-php-source .phps@" ${apache_install_dir}/conf/httpd.conf
  sed -i "s@#AddHandler cgi-script .cgi@AddHandler cgi-script .cgi .pl@" ${apache_install_dir}/conf/httpd.conf
  sed -ri 's@^#(LoadModule.*mod_proxy.so)@\1@' ${apache_install_dir}/conf/httpd.conf
  sed -ri 's@^#(LoadModule.*mod_proxy_fcgi.so)@\1@' ${apache_install_dir}/conf/httpd.conf
  sed -ri 's@^#(LoadModule.*mod_suexec.so)@\1@' ${apache_install_dir}/conf/httpd.conf
  sed -ri 's@^#(LoadModule.*mod_vhost_alias.so)@\1@' ${apache_install_dir}/conf/httpd.conf
  sed -ri 's@^#(LoadModule.*mod_rewrite.so)@\1@' ${apache_install_dir}/conf/httpd.conf
  sed -ri 's@^#(LoadModule.*mod_deflate.so)@\1@' ${apache_install_dir}/conf/httpd.conf
  sed -ri 's@^#(LoadModule.*mod_expires.so)@\1@' ${apache_install_dir}/conf/httpd.conf
  sed -ri 's@^#(LoadModule.*mod_ssl.so)@\1@' ${apache_install_dir}/conf/httpd.conf
  sed -ri 's@^#(LoadModule.*mod_http2.so)@\1@' ${apache_install_dir}/conf/httpd.conf
  sed -i 's@DirectoryIndex index.html@DirectoryIndex index.html index.php@' ${apache_install_dir}/conf/httpd.conf
  sed -i "s@^DocumentRoot.*@DocumentRoot \"${wwwroot_dir}/default\"@" ${apache_install_dir}/conf/httpd.conf
  sed -i "s@^<Directory \"${apache_install_dir}/htdocs\">@<Directory \"${wwwroot_dir}/default\">@" ${apache_install_dir}/conf/httpd.conf
  sed -i "s@^#Include conf/extra/httpd-mpm.conf@Include conf/extra/httpd-mpm.conf@" ${apache_install_dir}/conf/httpd.conf
  if [ "${apache_mpm_option}" == '2' ]; then
    sed -ri 's@^(LoadModule.*mod_mpm_event.so)@#\1@' ${apache_install_dir}/conf/httpd.conf
    sed -i 's@^#LoadModule mpm_prefork_module@LoadModule mpm_prefork_module@' ${apache_install_dir}/conf/httpd.conf
  elif [ "${apache_mpm_option}" == '3' ]; then
    sed -ri 's@^(LoadModule.*mod_mpm_event.so)@#\1@' ${apache_install_dir}/conf/httpd.conf
    sed -i 's@^#LoadModule mpm_worker_module@LoadModule mpm_worker_module@' ${apache_install_dir}/conf/httpd.conf
  fi

  #logrotate apache log
  cat > /etc/logrotate.d/apache << EOF
${wwwlogs_dir}/*apache.log {
  daily
  rotate 5
  missingok
  dateext
  compress
  notifempty
  sharedscripts
  postrotate
    [ -e /var/run/httpd.pid ] && kill -USR1 \`cat /var/run/httpd.pid\`
  endscript
}
EOF

  mkdir ${apache_install_dir}/conf/vhost
  [ "${apache_mode_option}" != '2' ] && Apache_fcgi=$(echo -e "<Files ~ (\\.user.ini|\\.htaccess|\\.git|\\.svn|\\.project|LICENSE|README.md)\$>\n    Order allow,deny\n    Deny from all\n  </Files>\n  <FilesMatch \\.php\$>\n    SetHandler \"proxy:unix:/dev/shm/php-cgi.sock|fcgi://localhost\"\n  </FilesMatch>")
  cat > ${apache_install_dir}/conf/vhost/0.conf << EOF
<VirtualHost *:$TMP_PORT>
  ServerAdmin admin@example.com
  DocumentRoot "${wwwroot_dir}/default"
  ServerName 127.0.0.1
  ErrorLog "${wwwlogs_dir}/error_apache.log"
  CustomLog "${wwwlogs_dir}/access_apache.log" common
  <Files ~ (\.user.ini|\.htaccess|\.git|\.svn|\.project|LICENSE|README.md)\$>
    Order allow,deny
    Deny from all
  </Files>
  ${Apache_fcgi}
<Directory "${wwwroot_dir}/default">
  SetOutputFilter DEFLATE
  Options FollowSymLinks ExecCGI
  Require all granted
  AllowOverride All
  Order allow,deny
  Allow from all
  DirectoryIndex index.html index.php
</Directory>
<Location /server-status>
  SetHandler server-status
  Order Deny,Allow
  Deny from all
  Allow from 127.0.0.1
</Location>
</VirtualHost>
EOF

  cat >> ${apache_install_dir}/conf/httpd.conf <<EOF
<IfModule mod_headers.c>
  AddOutputFilterByType DEFLATE text/html text/plain text/css text/xml text/javascript
  <FilesMatch "\.(js|css|html|htm|png|jpg|swf|pdf|shtml|xml|flv|gif|ico|jpeg)\$">
    RequestHeader edit "If-None-Match" "^(.*)-gzip(.*)\$" "\$1\$2"
    Header edit "ETag" "^(.*)-gzip(.*)\$" "\$1\$2"
  </FilesMatch>
  DeflateCompressionLevel 6
  SetOutputFilter DEFLATE
</IfModule>

ProtocolsHonorOrder On
PidFile /var/run/httpd.pid
ServerTokens ProductOnly
ServerSignature Off
Include conf/vhost/*.conf
EOF
  [ "${nginx_option}" == '4' -a ! -e "${web_install_dir}/sbin/nginx" ] && echo 'Protocols h2 http/1.1' >> ${apache_install_dir}/conf/httpd.conf
  if [ "${nginx_option}" != '4' -o -e "${web_install_dir}/sbin/nginx" ]; then
    cat > ${apache_install_dir}/conf/extra/httpd-remoteip.conf << EOF
LoadModule remoteip_module modules/mod_remoteip.so
RemoteIPHeader X-Forwarded-For
RemoteIPInternalProxy 127.0.0.1
EOF
    sed -i "s@Include conf/extra/httpd-mpm.conf@Include conf/extra/httpd-mpm.conf\nInclude conf/extra/httpd-remoteip.conf@" ${apache_install_dir}/conf/httpd.conf
    sed -i "s@LogFormat \"%h %l@LogFormat \"%h %a %l@g" ${apache_install_dir}/conf/httpd.conf
  fi
  ldconfig
  service httpd start
  popd > /dev/null
}
