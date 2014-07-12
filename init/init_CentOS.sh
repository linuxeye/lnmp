#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

cd src
. ../functions/download.sh
src_url=http://blog.linuxeye.com/lnmp/src/yum-3.4.3.tar.gz && Download_src
tar zxf yum-3.4.3.tar.gz
cd yum-3.4.3
./yummain.py install yum -y
cd ..
sed -i 's@^exclude@#exclude@' /etc/yum.conf
yum clean all

cd /etc/yum.repos.d/
rename repo repo_bk *.repo
rename repo_bk repo *ent*
cd -
#public_IP=`../functions/get_public_ip.py`
#if [ "`../functions/get_ip_area.py $public_IP`" == 'CN' ];then
	if [ -n "$(cat /etc/redhat-release | grep '6\.')" ];then
		#wget -c http://blog.linuxeye.com/wp-content/uploads/2013/12/CentOS6-Base.repo -P /etc/yum.repos.d
		if [ ! -z "$(cat /etc/redhat-release | grep 'Red Hat')" ];then
	        	/bin/mv /etc/yum.repos.d/CentOS-Base.repo{,_bk}
			wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo
			sed -i 's@\$releasever@6@g' /etc/yum.repos.d/CentOS-Base.repo
	                sed -i 's@gpgcheck=1@gpgcheck=0@g' /etc/yum.repos.d/CentOS-Base.repo
		fi
	elif [ -n "$(cat /etc/redhat-release | grep '5\.')" ];then
		#wget -c http://blog.linuxeye.com/wp-content/uploads/2013/12/CentOS5-Base.repo -P /etc/yum.repos.d
		if [ ! -z "$(cat /etc/redhat-release | grep 'Red Hat')" ];then
	        	/bin/mv /etc/yum.repos.d/CentOS-Base.repo{,_bk}
			wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-5.repo
			sed -i 's@\$releasever@5@g' /etc/yum.repos.d/CentOS-Base.repo
	                sed -i 's@gpgcheck=1@gpgcheck=0@g' /etc/yum.repos.d/CentOS-Base.repo
		fi
	fi

	yum makecache
#fi

if [ -n "$(cat /etc/redhat-release | grep '6\.')" ];then
	yum -y groupremove "FTP Server" "PostgreSQL Database client" "PostgreSQL Database server" "MySQL Database server" "MySQL Database client" "Web Server" "Office Suite and Productivity" "E-mail server" "Ruby Support" "Printing client" 
elif [ -n "$(cat /etc/redhat-release | grep '5\.')" ];then
	yum -y groupremove "FTP Server" "Windows File Server" "PostgreSQL Database" "News Server" "MySQL Database" "DNS Name Server" "Web Server" "Dialup Networking Support" "Mail Server" "Ruby" "Office/Productivity" "Sound and Video" "Printing Support" "OpenFabrics Enterprise Distribution"
fi

yum check-update

# check upgrade OS
[ "$upgrade_yn" == 'y' ] && yum -y upgrade

# Install needed packages
for Package in gcc gcc-c++ make autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssl-devel libxslt-devel libevent-devel libtool libtool-ltdl bison gd-devel vim-enhanced pcre-devel zip unzip ntpdate sysstat patch bc expect rsync
do
	yum -y install $Package
done

# use gcc-4.4
if [ -n "`gcc --version | head -n1 | grep '4\.1\.'`" ];then
        yum -y install gcc44 gcc44-c++ libstdc++44-devel
	export CC="gcc44" CXX="g++44"
fi

# check sendmail
[ "$sendmail_yn" == 'y' ] && yum -y install sendmail && service sendmail restart

# closed Unnecessary services and remove obsolete rpm package
for Service in `chkconfig --list | grep 3:on | awk '{print $1}'`;do chkconfig --level 3 $Service off;done
for Service in sshd network crond iptables messagebus irqbalance syslog rsyslog sendmail;do chkconfig --level 3 $Service on;done

# Close SELINUX
setenforce 0
sed -i 's/^SELINUX=.*$/SELINUX=disabled/' /etc/selinux/config

# initdefault
sed -i 's/^id:.*$/id:3:initdefault:/' /etc/inittab
init q

# PS1
[ -z "`cat ~/.bashrc | grep ^PS1`" ] && echo 'PS1="\[\e[37;40m\][\[\e[32;40m\]\u\[\e[37;40m\]@\h \[\e[35;40m\]\W\[\e[0m\]]\\$ "' >> ~/.bashrc 

# history size 
sed -i 's/^HISTSIZE=.*$/HISTSIZE=100/' /etc/profile
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

# Wrong password five times locked 180s
[ -z "`cat /etc/pam.d/system-auth | grep 'pam_tally2.so'`" ] && sed -i '4a auth        required      pam_tally2.so deny=5 unlock_time=180' /etc/pam.d/system-auth

# alias vi
[ -z "`cat ~/.bashrc | grep 'alias vi='`" ] && sed -i "s@alias mv=\(.*\)@alias mv=\1\nalias vi=vim@" ~/.bashrc && echo 'syntax on' >> /etc/vimrc

# /etc/sysctl.conf
sed -i 's/net.ipv4.tcp_syncookies.*$/net.ipv4.tcp_syncookies = 1/g' /etc/sysctl.conf
[ -z "`cat /etc/sysctl.conf | grep 'fs.file-max'`" ] && cat >> /etc/sysctl.conf << EOF
fs.file-max=65535
net.ipv4.tcp_fin_timeout = 30 
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 65535 
net.core.netdev_max_backlog = 262144
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 262144
EOF
sysctl -p

if [ -n "$(cat /etc/redhat-release | grep '5\.')" ];then
	sed -i 's/3:2345:respawn/#3:2345:respawn/g' /etc/inittab
	sed -i 's/4:2345:respawn/#4:2345:respawn/g' /etc/inittab
	sed -i 's/5:2345:respawn/#5:2345:respawn/g' /etc/inittab
	sed -i 's/6:2345:respawn/#6:2345:respawn/g' /etc/inittab
	sed -i 's/ca::ctrlaltdel/#ca::ctrlaltdel/g' /etc/inittab
	sed -i 's@LANG=.*$@LANG="en_US.UTF-8"@g' /etc/sysconfig/i18n
elif [ -n "$(cat /etc/redhat-release | grep '6\.')" ];then
	sed -i 's@^ACTIVE_CONSOLES.*@ACTIVE_CONSOLES=/dev/tty[1-2]@' /etc/sysconfig/init	
	sed -i 's@^start@#start@' /etc/init/control-alt-delete.conf
fi
init q

# Update time
ntpdate pool.ntp.org 
echo "*/20 * * * * `which ntpdate` pool.ntp.org > /dev/null 2>&1" >> /var/spool/cron/root;chmod 600 /var/spool/cron/root
service crond restart

# iptables
cat > /etc/sysconfig/iptables << EOF
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
service iptables restart

# install tmux
if [ ! -e "`which tmux`" ];then
	src_url=http://downloads.sourceforge.net/project/levent/libevent/libevent-2.0/libevent-2.0.21-stable.tar.gz && Download_src 
	src_url=http://downloads.sourceforge.net/project/tmux/tmux/tmux-1.8/tmux-1.8.tar.gz && Download_src 
	tar xzf libevent-2.0.21-stable.tar.gz
	cd libevent-2.0.21-stable
	./configure
	make && make install
	cd ..

	tar xzf tmux-1.8.tar.gz
	cd tmux-1.8
	CFLAGS="-I/usr/local/include" LDFLAGS="-L//usr/local/lib" ./configure
	make && make install
	cd ..

	if [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 64 ];then
	    ln -s /usr/local/lib/libevent-2.0.so.5 /usr/lib64/libevent-2.0.so.5
	else
	    ln -s /usr/local/lib/libevent-2.0.so.5 /usr/lib/libevent-2.0.so.5
	fi
fi

# install htop
if [ ! -e "`which htop`" ];then
	src_url=http://hisham.hm/htop/releases/1.0.3/htop-1.0.3.tar.gz && Download_src 
	tar xzf htop-1.0.3.tar.gz
	cd htop-1.0.3
	./configure
	make && make install
	cd ..
fi
cd ..
. /etc/profile
. ~/.bashrc
