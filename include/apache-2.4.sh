#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_Apache24() {
  pushd ${oneinstack_dir}/src > /dev/null
  tar xzf pcre-${pcre_ver}.tar.gz
  pushd pcre-${pcre_ver}
  ./configure
  make -j ${THREAD} && make install
  popd
  id -u ${run_user} >/dev/null 2>&1
  [ $? -ne 0 ] && useradd -M -s /sbin/nologin ${run_user}
  tar xzf httpd-${apache24_ver}.tar.gz
  tar xzf nghttp2-${nghttp2_ver}.tar.gz
  tar xzf apr-${apr_ver}.tar.gz
  tar xzf apr-util-${apr_util_ver}.tar.gz

  # install nghttp2
  if [ ! -e "/usr/local/lib/libnghttp2.so" ]; then
    pushd nghttp2-${nghttp2_ver}
    ./configure
    make -j ${THREAD} && make install
    popd
    echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf; ldconfig
    rm -rf nghttp2-${nghttp2_ver}
  fi

  pushd httpd-${apache24_ver}
  [ ! -d "${apache_install_dir}" ] && mkdir -p ${apache_install_dir}
  /bin/cp -R ../apr-${apr_ver} ./srclib/apr
  /bin/cp -R ../apr-util-${apr_util_ver} ./srclib/apr-util
  [[ "${php_option}" =~ ^[1-4]$ ]] && Apache_mpm_arg='--with-mpm=prefork'
  LDFLAGS=-ldl LD_LIBRARY_PATH=${openssl_install_dir}/lib ./configure --prefix=${apache_install_dir} ${Apache_mpm_arg} --enable-mpms-shared=all --with-included-apr --enable-headers --enable-deflate --enable-so --enable-dav --enable-rewrite --enable-ssl --with-ssl=${openssl_install_dir} --enable-http2 --with-nghttp2=/usr/local --enable-expires --enable-static-support --enable-suexec --enable-modules=all --enable-mods-shared=all
  make -j ${THREAD} && make install
  unset LDFLAGS
  if [ -e "${apache_install_dir}/conf/httpd.conf" ]; then
    echo "${CSUCCESS}Apache installed successfully! ${CEND}"
    popd
    rm -rf httpd-${apache24_ver}
  else
    rm -rf ${apache_install_dir}
    echo "${CFAILURE}Apache install failed, Please contact the author! ${CEND}"
    kill -9 $$
  fi

  [ -z "`grep ^'export PATH=' /etc/profile`" ] && echo "export PATH=${apache_install_dir}/bin:\$PATH" >> /etc/profile
  [ -n "`grep ^'export PATH=' /etc/profile`" -a -z "`grep ${apache_install_dir} /etc/profile`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=${apache_install_dir}/bin:\1@" /etc/profile
  . /etc/profile

  sed -i "s@^export LD_LIBRARY_PATH.*@export LD_LIBRARY_PATH=${openssl_install_dir}/lib:\$LD_LIBRARY_PATH@" ${apache_install_dir}/bin/envvars
  /bin/cp ${apache_install_dir}/bin/apachectl /etc/init.d/httpd
  sed -i '2a # chkconfig: - 85 15' /etc/init.d/httpd
  sed -i '3a # description: Apache is a World Wide Web server. It is used to serve' /etc/init.d/httpd
  chmod +x /etc/init.d/httpd
  [ "$OS" == 'CentOS' ] && { chkconfig --add httpd; chkconfig httpd on; }
  [[ $OS =~ ^Ubuntu$|^Debian$ ]] && update-rc.d httpd defaults

  sed -i "s@^User daemon@User ${run_user}@" ${apache_install_dir}/conf/httpd.conf
  sed -i "s@^Group daemon@Group ${run_user}@" ${apache_install_dir}/conf/httpd.conf
  if [ "${nginx_option}" == '4' -a ! -e "${web_install_dir}/sbin/nginx" ]; then
    sed -i 's/^#ServerName www.example.com:80/ServerName 0.0.0.0:80/' ${apache_install_dir}/conf/httpd.conf
    TMP_PORT=80
  elif [[ ${nginx_option} =~ ^[1-3]$ ]] || [ -e "${web_install_dir}/sbin/nginx" ]; then
    sed -i 's/^#ServerName www.example.com:80/ServerName 127.0.0.1:88/' ${apache_install_dir}/conf/httpd.conf
    sed -i 's@^Listen.*@Listen 127.0.0.1:88@' ${apache_install_dir}/conf/httpd.conf
    TMP_PORT=88
  fi
  sed -i "s@AddType\(.*\)Z@AddType\1Z\n    AddType application/x-httpd-php .php .phtml\n    AddType application/x-httpd-php-source .phps@" ${apache_install_dir}/conf/httpd.conf
  sed -i "s@#AddHandler cgi-script .cgi@AddHandler cgi-script .cgi .pl@" ${apache_install_dir}/conf/httpd.conf
  sed -ri 's@^#(.*mod_suexec.so)@\1@' ${apache_install_dir}/conf/httpd.conf
  sed -ri 's@^#(.*mod_vhost_alias.so)@\1@' ${apache_install_dir}/conf/httpd.conf
  sed -ri 's@^#(.*mod_rewrite.so)@\1@' ${apache_install_dir}/conf/httpd.conf
  sed -ri 's@^#(.*mod_deflate.so)@\1@' ${apache_install_dir}/conf/httpd.conf
  sed -ri 's@^#(.*mod_expires.so)@\1@' ${apache_install_dir}/conf/httpd.conf
  sed -ri 's@^#(.*mod_ssl.so)@\1@' ${apache_install_dir}/conf/httpd.conf
  sed -ri 's@^#(.*mod_http2.so)@\1@' ${apache_install_dir}/conf/httpd.conf
  sed -i 's@DirectoryIndex index.html@DirectoryIndex index.html index.php@' ${apache_install_dir}/conf/httpd.conf
  sed -i "s@^DocumentRoot.*@DocumentRoot \"${wwwroot_dir}/default\"@" ${apache_install_dir}/conf/httpd.conf
  sed -i "s@^<Directory \"${apache_install_dir}/htdocs\">@<Directory \"${wwwroot_dir}/default\">@" ${apache_install_dir}/conf/httpd.conf
  sed -i "s@^#Include conf/extra/httpd-mpm.conf@Include conf/extra/httpd-mpm.conf@" ${apache_install_dir}/conf/httpd.conf

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
  cat > ${apache_install_dir}/conf/vhost/0.conf << EOF
<VirtualHost *:$TMP_PORT>
  ServerAdmin admin@example.com
  DocumentRoot "${wwwroot_dir}/default"
  ServerName 127.0.0.1
  ErrorLog "${wwwlogs_dir}/error_apache.log"
  CustomLog "${wwwlogs_dir}/access_apache.log" common
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
  popd
}
