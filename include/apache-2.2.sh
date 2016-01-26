#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       http://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_Apache-2-2() {
cd $oneinstack_dir/src
src_url=http://mirrors.linuxeye.com/apache/httpd/httpd-$apache_2_version.tar.gz && Download_src 

id -u $run_user >/dev/null 2>&1
[ $? -ne 0 ] && useradd -M -s /sbin/nologin $run_user 

tar xzf httpd-$apache_2_version.tar.gz
cd httpd-$apache_2_version
[ ! -d "$apache_install_dir" ] && mkdir -p $apache_install_dir
[ "$ZendGuardLoader_yn" == 'y' -o "$ionCube_yn" == 'y' ] && MPM=prefork || MPM=worker
./configure --prefix=$apache_install_dir --enable-headers --enable-deflate --enable-mime-magic --enable-so --enable-rewrite --enable-ssl --with-ssl --enable-expires --enable-static-support --enable-suexec --disable-userdir --with-included-apr --with-mpm=$MPM --disable-userdir
make && make install
if [ -e "$apache_install_dir/conf/httpd.conf" ];then
    echo "${CSUCCESS}Apache install successfully! ${CEND}"
    cd ..
    rm -rf httpd-$apache_2_version
else
    rm -rf $apache_install_dir
    echo "${CFAILURE}Apache install failed, Please contact the author! ${CEND}"
    kill -9 $$
fi

[ -z "`grep ^'export PATH=' /etc/profile`" ] && echo "export PATH=$apache_install_dir/bin:\$PATH" >> /etc/profile 
[ -n "`grep ^'export PATH=' /etc/profile`" -a -z "`grep $apache_install_dir /etc/profile`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=$apache_install_dir/bin:\1@" /etc/profile
. /etc/profile

/bin/cp $apache_install_dir/bin/apachectl /etc/init.d/httpd
sed -i '2a # chkconfig: - 85 15' /etc/init.d/httpd
sed -i '3a # description: Apache is a World Wide Web server. It is used to serve' /etc/init.d/httpd
chmod +x /etc/init.d/httpd
[ "$OS" == 'CentOS' ] && { chkconfig --add httpd; chkconfig httpd on; }
[[ $OS =~ ^Ubuntu$|^Debian$ ]] && update-rc.d httpd defaults

sed -i "s@^User daemon@User $run_user@" $apache_install_dir/conf/httpd.conf
sed -i "s@^Group daemon@Group $run_user@" $apache_install_dir/conf/httpd.conf
if [ "$Nginx_version" == '3' -a ! -e "$web_install_dir/sbin/nginx" ];then
    sed -i 's/^#ServerName www.example.com:80/ServerName 0.0.0.0:80/' $apache_install_dir/conf/httpd.conf
    TMP_PORT=80
    TMP_IP=$IPADDR
elif [ "$Nginx_version" == '1' -o "$Nginx_version" == '2' -o -e "$web_install_dir/sbin/nginx" ];then
    sed -i 's/^#ServerName www.example.com:80/ServerName 127.0.0.1:88/' $apache_install_dir/conf/httpd.conf
    sed -i 's@^Listen.*@Listen 127.0.0.1:88@' $apache_install_dir/conf/httpd.conf
    TMP_PORT=88
    TMP_IP=127.0.0.1
fi
sed -i "s@AddType\(.*\)Z@AddType\1Z\n    AddType application/x-httpd-php .php .phtml\n    AddType application/x-httpd-php-source .phps@" $apache_install_dir/conf/httpd.conf
sed -i "s@#AddHandler cgi-script .cgi@AddHandler cgi-script .cgi .pl@" $apache_install_dir/conf/httpd.conf
sed -i 's@^#LoadModule rewrite_module@LoadModule rewrite_module@' $apache_install_dir/conf/httpd.conf
sed -i 's@^#LoadModule\(.*\)mod_deflate.so@LoadModule\1mod_deflate.so@' $apache_install_dir/conf/httpd.conf
sed -i 's@DirectoryIndex index.html@DirectoryIndex index.html index.php@' $apache_install_dir/conf/httpd.conf
sed -i "s@^DocumentRoot.*@DocumentRoot \"$wwwroot_dir/default\"@" $apache_install_dir/conf/httpd.conf
sed -i "s@^<Directory \"$apache_install_dir/htdocs\">@<Directory \"$wwwroot_dir/default\">@" $apache_install_dir/conf/httpd.conf
sed -i "s@^#Include conf/extra/httpd-mpm.conf@Include conf/extra/httpd-mpm.conf@" $apache_install_dir/conf/httpd.conf

#logrotate apache log
cat > /etc/logrotate.d/apache << EOF
$wwwlogs_dir/*apache.log {
daily
rotate 5
missingok
dateext
compress
notifempty
sharedscripts
postrotate
[ -f $apache_install_dir/logs/httpd.pid ] && kill -USR1 \`cat $apache_install_dir/logs/httpd.pid\`
endscript
}
EOF

mkdir $apache_install_dir/conf/vhost
cat >> $apache_install_dir/conf/vhost/0.conf << EOF
NameVirtualHost *:$TMP_PORT
<VirtualHost *:$TMP_PORT>
    ServerAdmin admin@linuxeye.com
    DocumentRoot "$wwwroot_dir/default"
    ServerName $TMP_IP 
    ErrorLog "$wwwlogs_dir/error_apache.log"
    CustomLog "$wwwlogs_dir/access_apache.log" common
<Directory "$wwwroot_dir/default">
    SetOutputFilter DEFLATE
    Options FollowSymLinks ExecCGI
    AllowOverride All
    Order allow,deny
    Allow from all
    DirectoryIndex index.html index.php
</Directory>
</VirtualHost>
EOF

cat >> $apache_install_dir/conf/httpd.conf <<EOF
<IfModule mod_headers.c>
    AddOutputFilterByType DEFLATE text/html text/plain text/css text/xml text/javascript
    <FilesMatch "\.(js|css|html|htm|png|jpg|swf|pdf|shtml|xml|flv|gif|ico|jpeg)\$">
        RequestHeader edit "If-None-Match" "^(.*)-gzip(.*)\$" "\$1\$2"
        Header edit "ETag" "^(.*)-gzip(.*)\$" "\$1\$2"
    </FilesMatch>
    DeflateCompressionLevel 6
    SetOutputFilter DEFLATE
</IfModule>

ServerTokens ProductOnly
ServerSignature Off
Include conf/vhost/*.conf
EOF

if [ "$Nginx_version" != '3' -o -e "$web_install_dir/sbin/nginx" ];then
    src_url=http://mirrors.linuxeye.com/oneinstack/src/mod_remoteip.c && Download_src
    $apache_install_dir/bin/apxs -i -c -n mod_remoteip.so mod_remoteip.c
    cat > $apache_install_dir/conf/extra/httpd-remoteip.conf << EOF
LoadModule remoteip_module modules/mod_remoteip.so
RemoteIPHeader X-Forwarded-For
RemoteIPInternalProxy 127.0.0.1
EOF
    sed -i "s@Include conf/extra/httpd-mpm.conf@Include conf/extra/httpd-mpm.conf\nInclude conf/extra/httpd-remoteip.conf@" $apache_install_dir/conf/httpd.conf
fi
service httpd start
cd ..
}
