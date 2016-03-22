#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       http://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_tomcat-8() {
cd $oneinstack_dir/src
. /etc/profile

src_url=http://mirrors.linuxeye.com/apache/tomcat/v$tomcat_8_version/apache-tomcat-$tomcat_8_version.tar.gz && Download_src
src_url=http://mirrors.linuxeye.com/apache/tomcat/v$tomcat_8_version/catalina-jmx-remote.jar && Download_src

id -u $run_user >/dev/null 2>&1
[ $? -ne 0 ] && useradd -M -s /bin/bash $run_user || { [ -z "`grep ^$run_user /etc/passwd | grep '/bin/bash'`" ] && usermod -s /bin/bash $run_user; }

tar xzf apache-tomcat-$tomcat_8_version.tar.gz
[ ! -d "$tomcat_install_dir" ] && mkdir -p $tomcat_install_dir
/bin/cp -R apache-tomcat-$tomcat_8_version/* $tomcat_install_dir

if [ -e "$tomcat_install_dir/conf/server.xml" ];then
    /bin/cp catalina-jmx-remote.jar $tomcat_install_dir/lib
    cd $tomcat_install_dir/lib
    [ ! -d "$tomcat_install_dir/lib/catalina" ] &&  mkdir $tomcat_install_dir/lib/catalina 
    cd $tomcat_install_dir/lib/catalina
    jar xf ../catalina.jar
    sed -i 's@^server.info=.*@server.info=Tomcat@' org/apache/catalina/util/ServerInfo.properties
    sed -i 's@^server.number=.*@server.number=8@' org/apache/catalina/util/ServerInfo.properties
    sed -i "s@^server.built=.*@server.built=`date`@" org/apache/catalina/util/ServerInfo.properties
    jar cf ../catalina.jar ./*
    cd ../../bin 
    rm -rf $tomcat_install_dir/lib/catalina 
    [ "$OS" == 'CentOS' ] && yum -y install apr apr-devel 
    [[ $OS =~ ^Ubuntu$|^Debian$ ]] && apt-get -y install libapr1-dev libaprutil1-dev 
    tar xzf tomcat-native.tar.gz 
    cd tomcat-native-*-src/jni/native/
    rm -rf /usr/local/apr
    ./configure --with-apr=/usr/bin/apr-1-config
    make && make install
    if [ -d "/usr/local/apr/lib" ];then
        [ $Mem -le 768 ] && Xms_Mem=`expr $Mem / 3` || Xms_Mem=256
        cat > $tomcat_install_dir/bin/setenv.sh << EOF
JAVA_OPTS='-Djava.security.egd=file:/dev/./urandom -server -Xms${Xms_Mem}m -Xmx`expr $Mem / 2`m'
CATALINA_OPTS="-Djava.library.path=/usr/local/apr/lib"
# -Djava.rmi.server.hostname=$IPADDR
# -Dcom.sun.management.jmxremote.password.file=\$CATALINA_BASE/conf/jmxremote.password
# -Dcom.sun.management.jmxremote.access.file=\$CATALINA_BASE/conf/jmxremote.access
# -Dcom.sun.management.jmxremote.ssl=false"
EOF
        cd ../../../;rm -rf tomcat-native-*
        chmod +x $tomcat_install_dir/bin/*.sh
        /bin/mv $tomcat_install_dir/conf/server.xml{,_bk} 
        cd $oneinstack_dir/src
        /bin/cp ../config/server.xml $tomcat_install_dir/conf
        sed -i "s@/usr/local/tomcat@$tomcat_install_dir@g" $tomcat_install_dir/conf/server.xml

        if [ ! -e "$nginx_install_dir/sbin/nginx" -a ! -e "$tengine_install_dir/sbin/nginx" -a ! -e "$apache_install_dir/conf/httpd.conf" ];then
            if [ "$OS" == 'CentOS' ];then
                if [ -z "`grep -w '8080' /etc/sysconfig/iptables`" ];then
                    iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 8080 -j ACCEPT
                    service iptables save
                fi
            elif [[ $OS =~ ^Ubuntu$|^Debian$ ]];then 
                if [ -z "`grep -w '8080' /etc/iptables.up.rules`" ];then
                    iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 8080 -j ACCEPT
                    iptables-save > /etc/iptables.up.rules
                fi
            fi
        fi

        [ ! -d "$tomcat_install_dir/conf/vhost" ] && mkdir $tomcat_install_dir/conf/vhost
        cat > $tomcat_install_dir/conf/vhost/localhost.xml << EOF
<Host name="localhost" appBase="webapps" unpackWARs="true" autoDeploy="true">
  <Context path="" docBase="$wwwroot_dir/default" debug="0" reloadable="false" crossContext="true"/>
  <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs" 
         prefix="localhost_access_log." suffix=".txt" pattern="%h %l %u %t &quot;%r&quot; %s %b" />
</Host>
EOF
        # logrotate tomcat catalina.out
        cat > /etc/logrotate.d/tomcat << EOF
$tomcat_install_dir/logs/catalina.out {
daily
rotate 5
missingok
dateext
compress
notifempty
copytruncate
}
EOF
        [ -z "`grep '<user username="admin" password=' $tomcat_install_dir/conf/tomcat-users.xml`" ] && sed -i "s@^</tomcat-users>@<role rolename=\"admin-gui\"/>\n<role rolename=\"admin-script\"/>\n<role rolename=\"manager-gui\"/>\n<role rolename=\"manager-script\"/>\n<user username=\"admin\" password=\"`cat /dev/urandom | head -1 | md5sum | head -c 10`\" roles=\"admin-gui,admin-script,manager-gui,manager-script\"/>\n</tomcat-users>@" $tomcat_install_dir/conf/tomcat-users.xml
        cat > $tomcat_install_dir/conf/jmxremote.access << EOF
monitorRole   readonly
controlRole   readwrite \
              create javax.management.monitor.*,javax.management.timer.* \
              unregister
EOF
        cat > $tomcat_install_dir/conf/jmxremote.password << EOF
monitorRole  `cat /dev/urandom | head -1 | md5sum | head -c 8` 
# controlRole   R&D
EOF
        chown -R $run_user.$run_user $tomcat_install_dir
        /bin/cp ../init.d/Tomcat-init /etc/init.d/tomcat
        sed -i "s@JAVA_HOME=.*@JAVA_HOME=$JAVA_HOME@" /etc/init.d/tomcat
        sed -i "s@^CATALINA_HOME=.*@CATALINA_HOME=$tomcat_install_dir@" /etc/init.d/tomcat
        sed -i "s@^TOMCAT_USER=.*@TOMCAT_USER=$run_user@" /etc/init.d/tomcat
        [ "$OS" == 'CentOS' ] && { chkconfig --add tomcat;chkconfig tomcat on; } 
        [[ $OS =~ ^Ubuntu$|^Debian$ ]] && update-rc.d tomcat defaults
        echo "${CSUCCESS}Tomcat install successfully! ${CEND}"
    fi
else
    rm -rf $tomcat_install_dir
    echo "${CFAILURE}Tomcat install failed, Please contact the author! ${CEND}" 
    kill -9 $$
fi
service tomcat start
cd ..
}
