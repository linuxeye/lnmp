#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_Apache-2-4()
{
cd $lnmp_dir/src
. ../functions/download.sh
. ../functions/check_os.sh
. ../options.conf

src_url=http://downloads.sourceforge.net/project/pcre/pcre/8.35/pcre-8.35.tar.gz && Download_src
src_url=http://archive.apache.org/dist/apr/apr-1.5.0.tar.gz && Download_src 
src_url=http://archive.apache.org/dist/apr/apr-util-1.5.3.tar.gz && Download_src 
src_url=http://www.apache.org/dist/httpd/httpd-2.4.9.tar.gz && Download_src 

tar xzf pcre-8.35.tar.gz
cd pcre-8.35
./configure
make && make install
cd ../

useradd -M -s /sbin/nologin www
tar xzf httpd-2.4.9.tar.gz
tar xzf apr-1.5.0.tar.gz
tar xzf apr-util-1.5.3.tar.gz
cd httpd-2.4.9
/bin/cp -R ../apr-1.5.0 ./srclib/apr
/bin/cp -R ../apr-util-1.5.3 ./srclib/apr-util
./configure --prefix=$apache_install_dir --enable-headers --enable-deflate --enable-mime-magic --enable-so --enable-rewrite --enable-ssl --with-ssl --enable-expires --enable-static-support --enable-suexec --disable-userdir --with-included-apr --with-mpm=prefork --disable-userdir
make && make install
if [ -d "$apache_install_dir" ];then
        echo -e "\033[32mApache install successfully! \033[0m"
else
        echo -e "\033[31mApache install failed, Please contact the author! \033[0m"
        kill -9 $$
fi

[ -n "`cat /etc/profile | grep 'export PATH='`" -a -z "`cat /etc/profile | grep $apache_install_dir`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=$apache_install_dir/bin:\1@" /etc/profile
. /etc/profile

cd ..
/bin/rm -rf httpd-2.4.9
/bin/cp $apache_install_dir/bin/apachectl  /etc/init.d/httpd
sed -i '2a # chkconfig: - 85 15' /etc/init.d/httpd
sed -i '3a # description: Apache is a World Wide Web server. It is used to serve' /etc/init.d/httpd
chmod +x /etc/init.d/httpd
OS_CentOS='chkconfig --add httpd \n
chkconfig httpd on'
OS_Debian_Ubuntu='update-rc.d httpd defaults'
OS_command

sed -i 's@^User daemon@User www@' $apache_install_dir/conf/httpd.conf
sed -i 's@^Group daemon@Group www@' $apache_install_dir/conf/httpd.conf
if [ "$Nginx_version" == '3' ];then
	sed -i 's/^#ServerName www.example.com:80/ServerName 0.0.0.0:80/' $apache_install_dir/conf/httpd.conf
	TMP_PORT=80
        TMP_IP=$local_IP
elif [ "$Nginx_version" == '1' -o "$Nginx_version" == '2' ];then
	sed -i 's/^#ServerName www.example.com:80/ServerName 127.0.0.1:8080/' $apache_install_dir/conf/httpd.conf
	sed -i 's@^Listen.*@Listen 127.0.0.1:8080@' $apache_install_dir/conf/httpd.conf
	TMP_PORT=8080
	TMP_IP=127.0.0.1
fi
sed -i "s@AddType\(.*\)Z@AddType\1Z\n    AddType application/x-httpd-php .php .phtml\n    AddType application/x-httpd-php-source .phps@" $apache_install_dir/conf/httpd.conf
sed -i 's@^#LoadModule rewrite_module@LoadModule rewrite_module@' $apache_install_dir/conf/httpd.conf
sed -i 's@^#LoadModule\(.*\)mod_deflate.so@LoadModule\1mod_deflate.so@' $apache_install_dir/conf/httpd.conf
sed -i 's@DirectoryIndex index.html@DirectoryIndex index.html index.php@' $apache_install_dir/conf/httpd.conf
sed -i "s@^DocumentRoot.*@DocumentRoot \"$home_dir/default\"@" $apache_install_dir/conf/httpd.conf
sed -i "s@^<Directory \"$apache_install_dir/htdocs\">@<Directory \"$home_dir/default\">@" $apache_install_dir/conf/httpd.conf
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
<VirtualHost *:$TMP_PORT>
    ServerAdmin admin@linuxeye.com
    DocumentRoot "$home_dir/default"
    ServerName $TMP_IP 
    ErrorLog "$wwwlogs_dir/error_apache.log"
    CustomLog "$wwwlogs_dir/access_apache.log" common
<Directory "$home_dir/default">
    SetOutputFilter DEFLATE
    Options FollowSymLinks
    Require all granted
    AllowOverride All
    Order allow,deny
    Allow from all
    DirectoryIndex index.html index.php
</Directory>
</VirtualHost>
EOF

cat >> $apache_install_dir/conf/httpd.conf <<EOF
ServerTokens ProductOnly
ServerSignature Off
AddOutputFilterByType DEFLATE text/html text/plain text/css text/xml text/javascript
DeflateCompressionLevel 6
SetOutputFilter DEFLATE
Include conf/vhost/*.conf
EOF

if [ "$Nginx_version" != '3' ];then
	cat > $apache_install_dir/conf/extra/httpd-remoteip.conf << EOF
LoadModule remoteip_module modules/mod_remoteip.so
RemoteIPHeader X-Forwarded-For
`ifconfig | awk -F"[: ]+" '/inet addr/{print "RemoteIPInternalProxy " $4}'`
EOF
	sed -i "s@Include conf/extra/httpd-mpm.conf@Include conf/extra/httpd-mpm.conf\nInclude conf/extra/httpd-remoteip.conf@" $apache_install_dir/conf/httpd.conf
	sed -i "s@LogFormat \"%h %l@LogFormat \"%h %a %l@g" $apache_install_dir/conf/httpd.conf
fi
cd ..
service httpd start
}
