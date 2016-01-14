#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#        Install Shadowsocks(Python) Server 
#
# Project home page:
#       http://oneinstack.com
#       https://github.com/lj2007331/oneinstack

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#######################################################################
#       OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+      #
#                  Install Shadowsocks(Python) Server                 #
#       For more information please visit http://oneinstack.com       #
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

Install_shadowsocks(){
if [ "$OS" == 'CentOS' ]; then
    for Package in wget unzip openssl-devel gcc swig python python-devel python-setuptools autoconf libtool libevent automake make curl curl-devel zlib-devel perl perl-devel cpio expat-devel gettext-devel
    do
        yum -y install $Package
    done
elif [[ $OS =~ ^Ubuntu$|^Debian$ ]];then 
    apt-get -y update
    for Package in python-dev python-pip curl wget unzip gcc swig automake make perl cpio
    do
        apt-get -y install $Package
    done
fi

src_url=http://mirrors.linuxeye.com/oneinstack/src/ez_setup.py && Download_src

which pip > /dev/null 2>&1
[ $? -ne 0 ] && [ "$OS" == 'CentOS' ] && { python ez_setup.py install; sleep 1; easy_install pip; }

if [ -f /usr/bin/pip ]; then
    pip install M2Crypto
    pip install greenlet
    pip install gevent
    pip install shadowsocks
    if [ -f /usr/bin/ssserver -o -f /usr/local/bin/ssserver ]; then
        /bin/cp ../init.d/Shadowsocks-init /etc/init.d/shadowsocks
        chmod +x /etc/init.d/shadowsocks
        [ "$OS" == 'CentOS' ] && { chkconfig --add shadowsocks; chkconfig shadowsocks on; }
        [[ $OS =~ ^Ubuntu$|^Debian$ ]] && update-rc.d shadowsocks defaults
        [ ! -e /usr/bin/ssserver -a -e /usr/local/bin/ssserver ] && sed -i 's@Shadowsocks_bin=.*@Shadowsocks_bin=/usr/local/bin/ssserver@' /etc/init.d/shadowsocks
    else
        echo
        echo "${CQUESTION}Shadowsocks install failed! Please visit http://oneinstack.com${CEND}"
        exit 1
    fi
fi
}

Uninstall_shadowsocks(){
while :
do
    echo
    read -p "Do you want to uninstall Shadowsocks? [y/n]: " Shadowsocks_yn 
    if [[ ! $Shadowsocks_yn =~ ^[y,n]$ ]];then
        echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
        break
    fi
done

if [ "$Shadowsocks_yn" == 'y' ]; then
    [ -n "`ps -ef | grep -v grep | grep -i "ssserver"`" ] && /etc/init.d/shadowsocks stop
    [ "$OS" == 'CentOS' ] && chkconfig --del shadowsocks 
    [[ $OS =~ ^Ubuntu$|^Debian$ ]] && update-rc.d -f shadowsocks remove 

    rm -rf /etc/shadowsocks.json /var/run/shadowsocks.pid /etc/init.d/shadowsocks
    pip uninstall -y shadowsocks
    if [ $? -eq 0 ]; then
        echo "${CSUCCESS}Shadowsocks uninstall success! ${CEND}"
    else
        echo "${CFAILURE}Shadowsocks uninstall failed! ${CEND}"
    fi
else
    echo "${CMSG}Shadowsocks uninstall cancelled! ${CEND}"
fi
}

AddUser_shadowsocks(){
while :
do
    echo
    read -p "Please input password for shadowsocks: " Shadowsocks_password
    [ -n "`echo $Shadowsocks_password | grep '[+|&]'`" ] && { echo "${CWARNING}input error,not contain a plus sign (+) and & ${CEND}"; continue; }
    (( ${#Shadowsocks_password} >= 5 )) && break || echo "${CWARNING}Shadowsocks password least 5 characters! ${CEND}"
done
}

Iptables_set(){
if [ -e '/etc/sysconfig/iptables' ];then
    Shadowsocks_Already_port=`grep -oE '90[0-9][0-9]' /etc/sysconfig/iptables | head -n 1`
elif [ -e '/etc/iptables.up.rules' ];then
    Shadowsocks_Already_port=`grep -oE '90[0-9][0-9]' /etc/iptables.up.rules | head -n 1`
fi

if [ -n "$Shadowsocks_Already_port" ];then
    Shadowsocks_Default_port=`expr $Shadowsocks_Already_port + 1`
else
    Shadowsocks_Default_port=9001
fi

while :
do
    echo
    read -p "Please input Shadowsocks port(Default: $Shadowsocks_Default_port): " Shadowsocks_port
    [ -z "$Shadowsocks_port" ] && Shadowsocks_port=$Shadowsocks_Default_port
    if [ $Shadowsocks_port -ge 9000 >/dev/null 2>&1 -a $Shadowsocks_port -le 9100 >/dev/null 2>&1 ];then
        break
    else
        echo "${CWARNING}input error! Input range: 9001~9099${CEND}"
    fi
done

if [ "$OS" == 'CentOS' ];then
    if [ -z "`grep -E $Shadowsocks_port /etc/sysconfig/iptables`" ];then
        iptables -I INPUT 4 -p tcp -m state --state NEW -m tcp --dport $Shadowsocks_port -j ACCEPT
        service iptables save 
    fi
elif [[ $OS =~ ^Ubuntu$|^Debian$ ]];then 
    if [ -z "`grep -E $Shadowsocks_port /etc/iptables.up.rules`" ];then
        iptables -I INPUT 4 -p tcp -m state --state NEW -m tcp --dport $Shadowsocks_port -j ACCEPT
        iptables-save > /etc/iptables.up.rules 
    fi
else
    echo "${CWARNING}This port is already in iptables${CEND}"
fi

}

Config_shadowsocks(){
cat > /etc/shadowsocks.json<<EOF
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
[ ! -e /etc/shadowsocks.json ] && { echo "${CFAILURE}Shadowsocks is not installed! ${CEND}"; exit 1; }
[ -z "`grep \"$Shadowsocks_port\" /etc/shadowsocks.json`" ] && sed -i "s@\"port_password\":{@\"port_password\":{\n\t\"$Shadowsocks_port\":\"$Shadowsocks_password\",@" /etc/shadowsocks.json || { echo "${CWARNING}This port is already in /etc/shadowsocks.json${CEND}"; exit 1; } 
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
    AddUser_shadowsocks
    Iptables_set
    Install_shadowsocks
    Config_shadowsocks
    service shadowsocks start 
    Print_User_shadowsocks
    ;;
adduser)
    AddUser_shadowsocks
    Iptables_set
    AddUser_Config_shadowsocks
    service shadowsocks restart
    Print_User_shadowsocks
    ;;
uninstall)
    Uninstall_shadowsocks
    ;;
*)
    echo
    echo $"Usage: ${CMSG}$0${CEND} { ${CMSG}install${CEND} | ${CMSG}adduser${CEND} | ${CMSG}uninstall${CEND} }"
    echo
    exit 1
esac
