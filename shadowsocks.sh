#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#        Install Shadowsocks Server
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#######################################################################
#       OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+      #
#                   Install Shadowsocks Server                        #
#       For more information please visit https://oneinstack.com      #
#######################################################################
"

cd src
. ../options.conf
. ../include/color.sh
. ../include/check_os.sh
. ../include/download.sh

# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

PUBLIC_IPADDR=`../include/get_public_ipaddr.py`

[ "$CentOS_RHEL_version" == '5' ] && { echo "${CWARNING}Shadowsocks only support CentOS6,7 or Debian or Ubuntu! ${CEND}"; exit 1; }

Check_shadowsocks() {
    [ -f /usr/local/bin/ss-server ] && SS_version=1
    [ -f /usr/bin/ssserver -o -f /usr/local/bin/ssserver ] && SS_version=2
}

AddUser_shadowsocks() {
while :; do echo
    read -p "Please input password for shadowsocks: " Shadowsocks_password
    [ -n "`echo $Shadowsocks_password | grep '[+|&]'`" ] && { echo "${CWARNING}input error,not contain a plus sign (+) and & ${CEND}"; continue; }
    (( ${#Shadowsocks_password} >= 5 )) && break || echo "${CWARNING}Shadowsocks password least 5 characters! ${CEND}"
done
}

Iptables_set() {
if [ -e '/etc/sysconfig/iptables' ];then
    Shadowsocks_Already_port=`grep -oE '9[0-9][0-9][0-9]' /etc/sysconfig/iptables | head -n 1`
elif [ -e '/etc/iptables.up.rules' ];then
    Shadowsocks_Already_port=`grep -oE '9[0-9][0-9][0-9]' /etc/iptables.up.rules | head -n 1`
fi

if [ -n "$Shadowsocks_Already_port" ];then
    Shadowsocks_Default_port=`expr $Shadowsocks_Already_port + 1`
else
    Shadowsocks_Default_port=9001
fi

while :; do echo
    read -p "Please input Shadowsocks port(Default: $Shadowsocks_Default_port): " Shadowsocks_port
    [ -z "$Shadowsocks_port" ] && Shadowsocks_port=$Shadowsocks_Default_port
    if [ $Shadowsocks_port -ge 1 >/dev/null 2>&1 -a $Shadowsocks_port -le 65535 >/dev/null 2>&1 ];then
        [ -z "`netstat -an | grep :$Shadowsocks_port`" ] && break || echo "${CWARNING}This port is already used! ${CEND}"
    else
        echo "${CWARNING}input error! Input range: 1~65535${CEND}"
    fi
done

if [ "$OS" == 'CentOS' ];then
    if [ -z "`grep -E $Shadowsocks_port /etc/sysconfig/iptables`" ];then
        iptables -I INPUT 4 -p udp -m state --state NEW -m udp --dport $Shadowsocks_port -j ACCEPT
        iptables -I INPUT 4 -p tcp -m state --state NEW -m tcp --dport $Shadowsocks_port -j ACCEPT
        service iptables save
    fi
elif [[ $OS =~ ^Ubuntu$|^Debian$ ]];then
    if [ -z "`grep -E $Shadowsocks_port /etc/iptables.up.rules`" ];then
        iptables -I INPUT 4 -p udp -m state --state NEW -m udp --dport $Shadowsocks_port -j ACCEPT
        iptables -I INPUT 4 -p tcp -m state --state NEW -m tcp --dport $Shadowsocks_port -j ACCEPT
        iptables-save > /etc/iptables.up.rules
    fi
else
    echo "${CWARNING}This port is already in iptables! ${CEND}"
fi

}

Def_parameter() {
if [ "$OS" == 'CentOS' ]; then
    while :; do echo
        echo 'Please select Shadowsocks server version:'
        echo -e "\t${CMSG}1${CEND}. Install Shadowsocks-libev"
        echo -e "\t${CMSG}2${CEND}. Install Shadowsocks-python"
        read -p "Please input a number:(Default 1 press Enter) " SS_version
        [ -z "$SS_version" ] && SS_version=1
        if [[ ! $SS_version =~ ^[1-2]$ ]];then
            echo "${CWARNING}input error! Please only input number 1,2${CEND}"
        else
            break
        fi
    done
    AddUser_shadowsocks
    Iptables_set
    for Package in wget unzip openssl-devel gcc swig python python-devel python-setuptools autoconf libtool libevent automake make curl curl-devel zlib-devel perl perl-devel cpio expat-devel gettext-devel git asciidoc xmlto
    do
        yum -y install $Package
    done
elif [[ $OS =~ ^Ubuntu$|^Debian$ ]];then
    SS_version=2
    AddUser_shadowsocks
    Iptables_set
    apt-get -y update
    for Package in python-dev python-pip curl wget unzip gcc swig automake make perl cpio git
    do
        apt-get -y install $Package
    done
fi
}

Install_shadowsocks-python() {
src_url=http://mirrors.linuxeye.com/oneinstack/src/ez_setup.py && Download_src

which pip > /dev/null 2>&1
[ $? -ne 0 ] && [ "$OS" == 'CentOS' ] && { python ez_setup.py install; sleep 1; easy_install pip; }

if [ -f /usr/bin/pip ]; then
    pip install M2Crypto
    pip install greenlet
    pip install gevent
    pip install shadowsocks
    if [ -f /usr/bin/ssserver -o -f /usr/local/bin/ssserver ]; then
        /bin/cp ../init.d/Shadowsocks-python-init /etc/init.d/shadowsocks
        chmod +x /etc/init.d/shadowsocks
        [ "$OS" == 'CentOS' ] && { chkconfig --add shadowsocks; chkconfig shadowsocks on; }
        [[ $OS =~ ^Ubuntu$|^Debian$ ]] && update-rc.d shadowsocks defaults
        [ ! -e /usr/bin/ssserver -a -e /usr/local/bin/ssserver ] && sed -i 's@Shadowsocks_bin=.*@Shadowsocks_bin=/usr/local/bin/ssserver@' /etc/init.d/shadowsocks
    else
        echo
        echo "${CQUESTION}Shadowsocks-python install failed! Please visit https://oneinstack.com${CEND}"
        exit 1
    fi
fi
}

Install_shadowsocks-libev() {
git clone https://github.com/shadowsocks/shadowsocks-libev.git
cd shadowsocks-libev
./configure
make -j ${THREAD} && make install
cd ..
if [ -f  /usr/local/bin/ss-server ];then
    /bin/cp ../init.d/Shadowsocks-libev-init /etc/init.d/shadowsocks
    chmod +x /etc/init.d/shadowsocks
    [ "$OS" == 'CentOS' ] && { chkconfig --add shadowsocks; chkconfig shadowsocks on; }
else
   echo
   echo "${CQUESTION}Shadowsocks-libev install failed! Please visit https://oneinstack.com${CEND}"
   exit 1
fi

}

Uninstall_shadowsocks(){
while :; do echo
    read -p "Do you want to uninstall Shadowsocks? [y/n]: " Shadowsocks_yn
    if [[ ! $Shadowsocks_yn =~ ^[y,n]$ ]];then
        echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
        break
    fi
done

if [ "$Shadowsocks_yn" == 'y' ]; then
    [ -n "`ps -ef | grep -v grep | grep -iE "ssserver|ss-server"`" ] && /etc/init.d/shadowsocks stop
    [ "$OS" == 'CentOS' ] && chkconfig --del shadowsocks
    [[ $OS =~ ^Ubuntu$|^Debian$ ]] && update-rc.d -f shadowsocks remove
    rm -rf /etc/shadowsocks /var/run/shadowsocks.pid /etc/init.d/shadowsocks
    if [ "$SS_version" == '1' ];then
        rm -f /usr/local/bin/ss-local
        rm -f /usr/local/bin/ss-tunnel
        rm -f /usr/local/bin/ss-server
        rm -f /usr/local/bin/ss-manager
        rm -f /usr/local/bin/ss-redir
        rm -f /usr/local/lib/libshadowsocks.a
        rm -f /usr/local/lib/libshadowsocks.la
        rm -f /usr/local/include/shadowsocks.h
        rm -f /usr/local/lib/pkgconfig/shadowsocks-libev.pc
        rm -f /usr/local/share/man/man1/ss-local.1
        rm -f /usr/local/share/man/man1/ss-tunnel.1
        rm -f /usr/local/share/man/man1/ss-server.1
        rm -f /usr/local/share/man/man1/ss-manager.1
        rm -f /usr/local/share/man/man1/ss-redir.1
        rm -f /usr/local/share/man/man8/shadowsocks.8
        if [ $? -eq 0 ]; then
            echo "${CSUCCESS}Shadowsocks-libev uninstall success! ${CEND}"
        else
            echo "${CFAILURE}Shadowsocks-libev uninstall failed! ${CEND}"
        fi
    elif [ "$SS_version" == '2' ];then
        pip uninstall -y shadowsocks
        if [ $? -eq 0 ]; then
            echo "${CSUCCESS}Shadowsocks-python uninstall success! ${CEND}"
        else
            echo "${CFAILURE}Shadowsocks-python uninstall failed! ${CEND}"
        fi
    fi
else
    echo "${CMSG}Shadowsocks uninstall cancelled! ${CEND}"
fi
}

Config_shadowsocks(){
[ ! -d '/etc/shadowsocks' ] && mkdir /etc/shadowsocks
[ "$SS_version" == '1' ] && cat > /etc/shadowsocks/config.json<<EOF
{
    "server":"0.0.0.0",
    "server_port":$Shadowsocks_port,
    "local_address":"127.0.0.1",
    "local_port":1080,
    "password":"$Shadowsocks_password",
    "timeout":300,
    "method":"aes-256-cfb",
}
EOF

[ "$SS_version" == '2' ] && cat > /etc/shadowsocks/config.json<<EOF
{
    "server":"0.0.0.0",
    "local_address":"127.0.0.1",
    "local_port":1080,
    "port_password":{
    "$Shadowsocks_port":"$Shadowsocks_password"
    },
    "timeout":300,
    "method":"aes-256-cfb",
    "fast_open":false
}
EOF
}

AddUser_Config_shadowsocks(){
[ ! -e /etc/shadowsocks/config.json ] && { echo "${CFAILURE}Shadowsocks is not installed! ${CEND}"; exit 1; }
[ -z "`grep \"$Shadowsocks_port\" /etc/shadowsocks/config.json`" ] && sed -i "s@\"port_password\":{@\"port_password\":{\n\t\"$Shadowsocks_port\":\"$Shadowsocks_password\",@" /etc/shadowsocks/config.json || { echo "${CWARNING}This port is already in /etc/shadowsocks/config.json${CEND}"; exit 1; }
}

Print_User_shadowsocks(){
printf "
Your Server IP: ${CMSG}$PUBLIC_IPADDR${CEND}
Your Server Port: ${CMSG}$Shadowsocks_port${CEND}
Your Password: ${CMSG}$Shadowsocks_password${CEND}
Your Local IP: ${CMSG}127.0.0.1${CEND}
Your Local Port: ${CMSG}1080${CEND}
Your Encryption Method: ${CMSG}aes-256-cfb${CEND}
"
}

case "$1" in
install)
    Def_parameter
    [ "$SS_version" == '1' ] && Install_shadowsocks-libev
    [ "$SS_version" == '2' ] && Install_shadowsocks-python
    Config_shadowsocks
    service shadowsocks start
    Print_User_shadowsocks
    ;;
adduser)
    Check_shadowsocks
    if [ "$SS_version" == '2' ];then
        AddUser_shadowsocks
        Iptables_set
        AddUser_Config_shadowsocks
        service shadowsocks restart
        Print_User_shadowsocks
    else
        printf "
        Sorry, we have no plan to support multi port configuration. Actually you can use multiple instances instead. For example:
        ss-server -c /etc/shadowsocks/config1.json -f /var/run/shadowsocks-server/pid1
        ss-server -c /etc/shadowsocks/config2.json -f /var/run/shadowsocks-server/pid2
        ss-server -c /etc/shadowsocks/config3.json -f /var/run/shadowsocks-server/pid3
        "
    fi
    ;;
uninstall)
    Check_shadowsocks
    Uninstall_shadowsocks
    ;;
*)
    echo
    echo $"Usage: ${CMSG}$0${CEND} { ${CMSG}install${CEND} | ${CMSG}adduser${CEND} | ${CMSG}uninstall${CEND} }"
    echo
    exit 1
esac
