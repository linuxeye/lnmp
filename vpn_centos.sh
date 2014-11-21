#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com
#
# This script's project home is:
#       http://blog.linuxeye.com/31.html
#       https://github.com/lj2007331/lnmp

# Check if user is root
[ $(id -u) != "0" ] && echo "Error: You must be root to run this script" && exit 1

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
clear
printf "
#######################################################################
#    LNMP/LAMP/LANMP for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+    #
# For more information please visit http://blog.linuxeye.com/31.html  #
#######################################################################
"
[ ! -e "src" ] && mkdir src
cd src
. ../functions/download.sh

while :
do
	echo
	read -p "Please input IP-Range(Default Range: 10.0.2): " iprange
	[ -z "$iprange" ] && iprange="10.0.2"
	if [ -z "`echo $iprange | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}$'`" ];then
		echo -e "\033[31minput error! Input format: xxx.xxx.xxx\033[0m"
	else
		break
	fi
done

echo
read -p "Please input PSK(Default PSK: psk): " MYPSK
[ -z "$MYPSK" ] && MYPSK="psk"

while :
do
	echo
        read -p "Please input username: " Username 
        [ -n "$Username" ] && break 
done

while :
do
	echo
        read -p "Please input password: " Password 
        [ -n "$Password" ] && break 
done
clear

public_IP=`../functions/get_public_ip.py`

get_char()
{
SAVEDSTTY=`stty -g`
stty -echo
stty cbreak
dd if=/dev/tty bs=1 count=1 2> /dev/null
stty -raw
stty echo
stty $SAVEDSTTY
}

echo ""
echo "ServerIP:$public_IP"
echo ""
echo "Server Local IP:$iprange.1"
echo ""
echo "Client Remote IP Range:$iprange.2-$iprange.254"
echo ""
echo "PSK:$MYPSK"
echo ""
echo "Press any key to start..."
char=`get_char`
clear

if [ -n "`grep 'CentOS Linux release 7' /etc/redhat-release`" ];then
        CentOS_REL=7
        for Package in wget ppp iptables iptables-services make gcc gmp-devel xmlto bison flex xmlto libpcap-devel lsof vim-enhanced
        do
                yum -y install $Package
        done
        echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
elif [ -n "`grep 'CentOS release 6' /etc/redhat-release`" ];then
        CentOS_REL=6
        for Package in wget ppp iptables make gcc gmp-devel xmlto bison flex xmlto libpcap-devel lsof vim-enhanced
        do
                yum -y install $Package
        done
        sed -i 's@net.ipv4.ip_forward.*@net.ipv4.ip_forward = 1@g' /etc/sysctl.conf
else
        echo -e "\033[31mDoes not support this OS, Please contact the author! \033[0m"
        exit 1
fi

sysctl -p
mknod /dev/random c 1 9
src_url=https://download.openswan.org/openswan/old/openswan-2.6/openswan-2.6.38.tar.gz && Download_src
tar xzf openswan-2.6.38.tar.gz
cd openswan-2.6.38
make programs install
cd ..

cat >/etc/ipsec.conf<<EOF
config setup
    nat_traversal=yes
    virtual_private=%v4:10.0.0.0/8,%v4:192.168.0.0/16,%v4:172.16.0.0/12
    oe=off
    protostack=netkey
    plutostderrlog=/var/log/ipsec.log

conn L2TP-PSK-NAT
    rightsubnet=vhost:%priv
    also=L2TP-PSK-noNAT

conn L2TP-PSK-noNAT
    authby=secret
    type=tunnel
    pfs=no
    auto=add
    keyingtries=3
    rekey=no
    ikelifetime=8h
    keylife=1h
    left=$public_IP
    leftprotoport=17/1701
    right=%any
    rightprotoport=17/%any
    rightsubnetwithin=0.0.0.0/0
    dpddelay=30
    dpdtimeout=120
    dpdaction=clear
EOF

cat >/etc/ipsec.secrets<<EOF
$public_IP %any: PSK "$MYPSK"
EOF

cat > /usr/bin/zl2tpset << EOF
#!/bin/bash
for each in /proc/sys/net/ipv4/conf/*
do
	echo 0 > \$each/accept_redirects
	echo 0 > \$each/send_redirects
done
EOF

chmod +x /usr/bin/zl2tpset
/usr/bin/zl2tpset
[ -z "`grep zl2tpset /etc/rc.local`" ] &&  echo '/usr/bin/zl2tpset' >> /etc/rc.local
service ipsec restart
src_url=http://pkgs.fedoraproject.org/repo/pkgs/xl2tpd/xl2tpd-1.3.6.tar.gz/2f526cc0c36cf6d8a74f1fb2e08c18ec/xl2tpd-1.3.6.tar.gz && Download_src
tar xzf xl2tpd-1.3.6.tar.gz
cd xl2tpd-1.3.6
make install

[ ! -e "/var/run/xl2tpd" ] && mkdir /var/run/xl2tpd
[ ! -e "/etc/xl2tpd" ] && mkdir /etc/xl2tpd
cd ..

cat >/etc/xl2tpd/xl2tpd.conf<<EOF
[global]
listen-addr = $public_IP
ipsec saref = yes
[lns default]
ip range = $iprange.2-$iprange.254
local ip = $iprange.1
refuse chap = yes
refuse pap = yes
require authentication = yes
ppp debug = yes
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
EOF

cat >/etc/ppp/options.xl2tpd<<EOF
require-mschap-v2
ms-dns 8.8.8.8
ms-dns 8.8.4.4
noccp
asyncmap 0
auth
crtscts
lock
hide-password
modem
debug
name l2tpd
proxyarp
lcp-echo-interval 30
lcp-echo-failure 4
idle 1800
mtu 1410
mru 1410
nodefaultroute
connect-delay 5000
logfd 2
logfile /var/log/l2tpd.log
EOF

cat >>/etc/ppp/chap-secrets<<EOF
$Username l2tpd $Password *
EOF

NETWORK_INT=`route | grep default | awk '{print $NF}'`
iptables -t nat -A POSTROUTING -s ${iprange}.0/24 -o $NETWORK_INT -j MASQUERADE
iptables -I FORWARD -s ${iprange}.0/24 -j ACCEPT
iptables -I FORWARD -d ${iprange}.0/24 -j ACCEPT
iptables -I INPUT -p udp --dport 1701 -j ACCEPT
iptables -I INPUT -p udp --dport 500 -j ACCEPT
iptables -I INPUT -p udp --dport 4500 -j ACCEPT
service iptables save
service ipsec restart
xl2tpd 
chkconfig ipsec on
clear
ipsec verify
printf "
Serverip:$public_IP
PSK:$MYPSK
username:$Username
password:$Password
"
