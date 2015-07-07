#!/bin/bash
#
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com
#
# Install Shadowsocks(Python) Server 

# Check if user is root
[ $(id -u) != "0" ] && { echo -e "\033[31mError: You must be root to run this script\033[0m"; exit 1; } 

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#######################################################################
#       OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+      #
#                  Install Shadowsocks(Python) Server                 #
#       For more information please visit http://oneinstack.com       #
#######################################################################
"

[ ! -d src ] && mkdir src
cd src
. ../options.conf
. ../functions/download.sh
. ../functions/check_os.sh

Public_IP=`../functions/get_public_ip.py`

if [ "$OS" == 'CentOS' ];then
	[ -z "$(grep -E ' 7\.| 6\.' /etc/redhat-release)" ] && { echo -e "\033[31mShadowsocks only support CentOS6,7 or Debian or Ubuntu! \033[0m"; exit 1; }
fi

Install_shadowsocks(){
if [ "$OS" == 'CentOS' ]; then
	for Package in wget unzip openssl-devel gcc swig python python-devel python-setuptools autoconf libtool libevent automake make curl curl-devel zlib-devel perl perl-devel cpio expat-devel gettext-devel
        do
                yum -y install $Package
        done
else
	apt-get -y update
        for Package in python-dev python-pip curl wget unzip gcc swig automake make perl cpio
        do
                apt-get -y install $Package
        done
fi

src_url=http://mirrors.linuxeye.com/lnmp/src/ez_setup.py && Download_src
src_url=http://mirrors.linuxeye.com/lnmp/init/Shadowsocks-init && Download_src

which pip > /dev/null 2>&1
if [ $? -ne 0 ]; then
	OS_CentOS='python ez_setup.py install \n
easy_install pip'
	OS_command
fi

if [ -f /usr/bin/pip ]; then
	pip install M2Crypto
	pip install greenlet
	pip install gevent
	pip install shadowsocks
	if [ -f /usr/bin/ssserver -o -f /usr/local/bin/ssserver ]; then
		/bin/cp Shadowsocks-init /etc/init.d/shadowsocks
		chmod +x /etc/init.d/shadowsocks
		OS_CentOS='chkconfig --add shadowsocks \n
chkconfig shadowsocks on'
		OS_Debian_Ubuntu="update-rc.d shadowsocks defaults"
		OS_command
		[ ! -e /usr/bin/ssserver -a -e /usr/local/bin/ssserver ] && sed -i 's@Shadowsocks_bin=.*@Shadowsocks_bin=/usr/local/bin/ssserver@' /etc/init.d/shadowsocks
	else
		echo
		echo "Shadowsocks install failed! Please visit http://oneinstack.com"
		exit 1
	fi
fi
}

Uninstall_shadowsocks(){
while :
do
        echo
        read -p "Do you want to uninstall Shadowsocks? [y/n]: " Shadowsocks_yn 
        if [ "$Shadowsocks_yn" != 'y' -a "$Shadowsocks_yn" != 'n' ];then
                echo -e "\033[31minput error! Please only input 'y' or 'n'\033[0m"
        else
                break
        fi
done

if [ "$Shadowsocks_yn" == 'y' ]; then
    [ -n "`ps -ef | grep -v grep | grep -i "ssserver"`" ] && /etc/init.d/shadowsocks stop
    OS_CentOS='chkconfig --del shadowsocks'
    OS_Debian_Ubuntu="update-rc.d -f shadowsocks remove"
    OS_command

    /bin/rm -rf /etc/shadowsocks.json /var/run/shadowsocks.pid /etc/init.d/shadowsocks
    pip uninstall -y shadowsocks
    if [ $? -eq 0 ]; then
        echo -e "\033[32mShadowsocks uninstall success! \033[0m"
    else
        echo -e "\033[31mShadowsocks uninstall failed! \033[0m"
    fi
else
    echo -e "\033[32mShadowsocks uninstall cancelled! \033[0m"
fi
}

AddUser_shadowsocks(){
while :
do
        echo
        read -p "Please input password for shadowsocks: " Shadowsocks_password
        [ -n "`echo $Shadowsocks_password | grep '[+|&]'`" ] && { echo -e "\033[31minput error,not contain a plus sign (+) and & \033[0m"; continue; }
        (( ${#Shadowsocks_password} >= 5 )) && break || echo -e "\033[31mshadowsocks password least 5 characters! \033[0m"
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
        if [ $Shadowsocks_port -ge 9001 >/dev/null 2>&1 -a $Shadowsocks_port -le 9099 >/dev/null 2>&1 ];then
                break
        else
                echo -e "\033[31minput error! Input range: 9001~9099\033[0m"
        fi
done

if [ -e '/etc/sysconfig/iptables' ];then
        if [ -z "`grep -E $Shadowsocks_port /etc/sysconfig/iptables`" ];then
                iptables -I INPUT 4 -p tcp -m state --state NEW -m tcp --dport $Shadowsocks_port -j ACCEPT
        fi
elif [ -e '/etc/iptables.up.rules' ];then
        if [ -z "`grep -E $Shadowsocks_port /etc/iptables.up.rules`" ];then
                iptables -I INPUT 4 -p tcp -m state --state NEW -m tcp --dport $Shadowsocks_port -j ACCEPT
        fi
else
	echo -e "\033[31mThis port is already in iptables\033[0m"
fi

OS_CentOS='service iptables save'
OS_Debian_Ubuntu='iptables-save > /etc/iptables.up.rules'
OS_command
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
[ ! -e /etc/shadowsocks.json ] && { echo -e "\033[31mShadowsocks is not installed\033[0m"; exit 1; }
[ -z "`grep \"$Shadowsocks_port\" /etc/shadowsocks.json`" ] && sed -i "s@\"port_password\":{@\"port_password\":{\n\t\"$Shadowsocks_port\":\"$Shadowsocks_password\",@" /etc/shadowsocks.json || { echo -e "\033[31mThis port is already in /etc/shadowsocks.json\033[0m"; exit 1; } 
}

Print_User_shadowsocks(){
echo
echo -e "Your Server IP: \033[032m$Public_IP\033[0m"
echo -e "Your Server Port: \033[032m$Shadowsocks_port\033[0m"
echo -e "Your Password: \033[032m$Shadowsocks_password\033[0m"
echo -e "Your Local IP: \033[032m127.0.0.1\033[0m"
echo -e "Your Local Port: \033[032m1080\033[0m"
echo -e "Your Encryption Method: \033[032maes-256-cfb\033[0m"
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
	echo -e $"\033[035mUsage:\033[0m \033[032m $0 {install|adduser|uninstall}\033[0m"
	echo
	exit 1
esac
