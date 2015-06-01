#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

cd src
. ../functions/download.sh

# add swapfile
Mem=`free -m | awk '/Mem:/{print $2}'`
Swap=`free -m | awk '/Swap:/{print $2}'`
if [ "$Swap" == '0' ] ;then
if [ $Mem -le 1024 ];then
        dd if=/dev/zero of=/swapfile count=1024 bs=1M
        mkswap /swapfile
        swapon /swapfile
        chmod 600 /swapfile
elif [ $Mem -gt 1024 -a $Mem -le 2048 ];then
        dd if=/dev/zero of=/swapfile count=2048 bs=1M
        mkswap /swapfile
        swapon /swapfile
        chmod 600 /swapfile
fi
cat >> /etc/fstab << EOF
/swapfile    swap    swap    defaults    0 0
EOF
fi

for Package in apache2 apache2-doc apache2-utils apache2.2-common apache2.2-bin apache2-mpm-prefork apache2-doc apache2-mpm-worker mysql-client mysql-server mysql-common libmysqlclient18 php5 php5-common php5-cgi php5-mysql php5-curl php5-gd libmysql* mysql-*
do
        apt-get -y remove --purge $Package
done
dpkg -l | grep ^rc | awk '{print $2}' | xargs dpkg -P

apt-get -y update

# check upgrade OS
[ "$upgrade_yn" == 'y' ] && apt-get -y upgrade 

# Install needed packages
for Package in gcc g++ make cmake autoconf libjpeg8 libjpeg8-dev libpng12-0 libpng12-dev libpng3 libfreetype6 libfreetype6-dev libxml2 libxml2-dev zlib1g zlib1g-dev libc6 libc6-dev libglib2.0-0 libglib2.0-dev bzip2 libzip-dev libbz2-1.0 libncurses5 libncurses5-dev libaio1 libaio-dev libreadline-dev curl libcurl3 libcurl4-openssl-dev e2fsprogs libkrb5-3 libkrb5-dev libltdl-dev libidn11 libidn11-dev openssl libssl-dev libtool libevent-dev re2c libsasl2-dev libxslt1-dev patch vim zip unzip tmux htop wget bc expect rsync git
do
	apt-get -y install $Package
done

if [ -n "`cat /etc/issue | grep -E 14`" ];then
	apt-get -y install libcloog-ppl1
	apt-get -y remove bison
	src_url=http://ftp.gnu.org/gnu/bison/bison-2.7.1.tar.gz && Download_src 
	tar xzf bison-2.7.1.tar.gz
	cd bison-2.7.1
	./configure
	make && make install
	cd ..
	rm -rf bison-2.7.1
	ln -sf /usr/include/freetype2 /usr/include/freetype2/freetype
elif [ -n "`cat /etc/issue | grep -E 13`" ];then
	apt-get -y install bison libcloog-ppl1
elif [ -n "`cat /etc/issue | grep -E 12`" ];then
	apt-get -y install bison libcloog-ppl0
fi

# check sendmail
#[ "$sendmail_yn" == 'y' ] && apt-get -y install sendmail

# PS1
[ -z "`cat ~/.bashrc | grep ^PS1`" ] && echo "PS1='\${debian_chroot:+(\$debian_chroot)}\\[\\e[1;32m\\]\\u@\\h\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\033[00m\\]\\$ '" >> ~/.bashrc 

# history size 
sed -i 's/HISTSIZE=.*$/HISTSIZE=100/g' ~/.bashrc 
[ -z "`cat ~/.bashrc | grep history-timestamp`" ] && echo "export PROMPT_COMMAND='{ msg=\$(history 1 | { read x y; echo \$y; });user=\$(whoami); echo \$(date \"+%Y-%m-%d %H:%M:%S\"):\$user:\`pwd\`/:\$msg ---- \$(who am i); } >> /tmp/\`hostname\`.\`whoami\`.history-timestamp'" >> ~/.bashrc

# /etc/security/limits.conf
[ -z "`cat /etc/security/limits.conf | grep 'nproc 65535'`" ] && cat >> /etc/security/limits.conf <<EOF
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
EOF
[ -z "`cat /etc/rc.local | grep 'ulimit -SH 65535'`" ] && echo "ulimit -SH 65535" >> /etc/rc.local

# /etc/hosts
[ "$(hostname -i | awk '{print $1}')" != "127.0.0.1" ] && sed -i "s@^127.0.0.1\(.*\)@127.0.0.1   `hostname` \1@" /etc/hosts

# Set timezone
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# Set DNS
#cat > /etc/resolv.conf << EOF
#nameserver 114.114.114.114
#nameserver 8.8.8.8
#EOF

# alias vi
[ -z "`cat ~/.bashrc | grep 'alias vi='`" ] && sed -i "s@^alias l=\(.*\)@alias l=\1\nalias vi='vim'@" ~/.bashrc

# /etc/sysctl.conf
[ -z "`cat /etc/sysctl.conf | grep 'fs.file-max'`" ] && cat >> /etc/sysctl.conf << EOF
fs.file-max=65535
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30 
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 65536 
net.ipv4.tcp_max_tw_buckets = 20000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 65535 
net.core.netdev_max_backlog = 262144
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 262144
EOF
sysctl -p

sed -i 's@^ACTIVE_CONSOLES.*@ACTIVE_CONSOLES="/dev/tty[1-2]"@' /etc/default/console-setup 
sed -i 's@^@#@g' /etc/init/tty[3-6].conf
echo 'en_US.UTF-8 UTF-8' > /var/lib/locales/supported.d/local
sed -i 's@^@#@g' /etc/init/control-alt-delete.conf 

# Update time
ntpdate pool.ntp.org 
[ -z "`grep 'pool.ntp.org' /var/spool/cron/root`" ] && { echo "*/20 * * * * `which ntpdate` pool.ntp.org > /dev/null 2>&1" >> /var/spool/cron/crontabs/root;chmod 600 /var/spool/cron/crontabs/root; } 
service cron restart

# iptables
if [ -e '/etc/iptables.up.rules' ] && [ -n "`grep ':INPUT DROP' /etc/iptables.up.rules`" -a -n "`grep 'NEW -m tcp --dport 22 -j ACCEPT' /etc/iptables.up.rules`" -a -n "`grep 'NEW -m tcp --dport 80 -j ACCEPT' /etc/iptables.up.rules`" ];then
        IPTABLES_STATUS=yes
else
        IPTABLES_STATUS=no
fi

if [ "$IPTABLES_STATUS" == 'no' ];then
cat > /etc/iptables.up.rules << EOF
# Firewall configuration written by system-config-securitylevel
# Manual customization of this file is not recommended.
*filter
:INPUT DROP [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:syn-flood - [0:0]
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT
-A INPUT -p icmp -m limit --limit 100/sec --limit-burst 100 -j ACCEPT
-A INPUT -p icmp -m limit --limit 1/s --limit-burst 10 -j ACCEPT
-A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j syn-flood
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A syn-flood -p tcp -m limit --limit 3/sec --limit-burst 6 -j RETURN
-A syn-flood -j REJECT --reject-with icmp-port-unreachable
COMMIT
EOF
fi

FW_PORT_FLAG=`grep -ow "dport $SSH_PORT" /etc/iptables.up.rules` 
[ -z "$FW_PORT_FLAG" -a "$SSH_PORT" != '22' ] && sed -i "s@dport 22 -j ACCEPT@&\n-A INPUT -p tcp -m state --state NEW -m tcp --dport $SSH_PORT -j ACCEPT@" /etc/iptables.up.rules 
iptables-restore < /etc/iptables.up.rules
echo 'pre-up iptables-restore < /etc/iptables.up.rules' >> /etc/network/interfaces
service ssh restart

. ~/.bashrc
