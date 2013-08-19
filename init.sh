#!/bin/bash
# Configure yum source
cd /tmp
wget -c http://yum.baseurl.org/download/3.4/yum-3.4.3.tar.gz
tar zxf yum-3.4.3.tar.gz
cd yum-3.4.3
./yummain.py install yum -y
cd ..
rm -rf yum-3.4.3*
sed -i 's@^exclude@#exclude@' /etc/yum.conf
yum clean all
yum check-update

mv /etc/yum.repos.d/CentOS-Debuginfo.repo /etc/yum.repos.d/CentOS-Debuginfo.repo$(date +%m%d)
mv /etc/yum.repos.d/CentOS-Media.repo /etc/yum.repos.d/CentOS-Media.repo$(date +%m%d)
mv /etc/yum.repos.d/CentOS-Vault.repo /etc/yum.repos.d/CentOS-Vault.repo$(date +%m%d)

# Remove obsolete rpm package
if [ -z "$(cat /etc/redhat-release | grep '5\.')" ];then
	yum -y groupremove "FTP Server" "Text-based Internet" "Windows File Server" "PostgreSQL Database" "News Server" "MySQL Database" "DNS Name Server" "Web Server" "Dialup Networking Support" "Mail Server" "Ruby" "Office/Productivity" "Sound and Video" "X Window System" "X Software Development" "Printing Support" "OpenFabrics Enterprise Distribution"
else
	yum -y groupremove "FTP Server" "PostgreSQL Database client" "PostgreSQL Database server" "MySQL Database server" "MySQL Database client" "Web Server" "Office Suite and Productivity" "Ruby Support" "X Window System" "Printing client" "Desktop*"
fi

# Update rpm package
yum -y update

# Install dependencies package
yum -y install gcc gcc-c++ make autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssl-devel nss_ldap openldap openldap-devel openldap-clients openldap-servers libxslt-devel libevent-devel ntp libtool libtool-ltdl bison gd-devel vim-enhanced pcre-devel zip unzip sendmail

# chkconfig 
chkconfig --list | awk '{print "chkconfig " $1 " off"}' > /tmp/chkconfiglist.sh;/bin/sh /tmp/chkconfiglist.sh;rm -rf /tmp/chkconfiglist.sh
chkconfig crond on
chkconfig irqbalance on
chkconfig network on
chkconfig sshd on
chkconfig rsyslog on #CentOS 6
chkconfig syslog on #CentOS/RHEL 5
chkconfig iptables on
chkconfig sendmail on
service sendmail restart

# /etc/hosts
[ "$(hostname -i)" != "127.0.0.1" ] && sed -i "s@^127.0.0.1\(.*\)@127.0.0.1   `hostname` \1@" /etc/hosts

# Close SELINUX
setenforce 0
sed -i 's/^SELINUX=.*$/SELINUX=disabled/' /etc/selinux/config

# initdefault
sed -i 's/^id:.*$/id:3:initdefault:/' /etc/inittab
/sbin/init q
# PS1
echo 'PS1="\[\e[37;40m\][\[\e[32;40m\]\u\[\e[37;40m\]@\h \[\e[35;40m\]\W\[\e[0m\]]\\$ \[\e[33;40m\]"' >> /etc/profile

# Record command
sed -i 's/^HISTSIZE=.*$/HISTSIZE=100/' /etc/profile
echo "export PROMPT_COMMAND='{ msg=\$(history 1 | { read x y; echo \$y; });user=\$(whoami); echo \$(date \"+%Y-%m-%d %H:%M:%S\"):\$user:\`pwd\`/:\$msg ---- \$(who am i); } >> /tmp/\`hostname\`.\`whoami\`.history-timestamp'" >> /root/.bash_profile

# Wrong password five times locked 180s
sed -i '4a auth        required      pam_tally2.so deny=5 unlock_time=180' /etc/pam.d/system-auth

# alias vi
sed "s@alias mv=.*@alias mv='mv -i'\nalias vi=vim@" /root/.bashrc
echo 'syntax on' >> /etc/vimrc

# /etc/security/limits.conf
cat >> /etc/security/limits.conf <<EOF
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
EOF
echo "ulimit -SH 65535" >> /etc/rc.local

# /etc/sysctl.conf
sed -i 's/net.ipv4.tcp_syncookies.*$/net.ipv4.tcp_syncookies = 1/g' /etc/sysctl.conf
cat >> /etc/sysctl.conf << EOF
fs.file-max=65535
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.ip_local_port_range = 1024 65000
EOF
sysctl -p

if [ -z "$(cat /etc/redhat-release | grep '6\.')" ];then
	sed -i 's/3:2345:respawn/#3:2345:respawn/g' /etc/inittab
	sed -i 's/4:2345:respawn/#4:2345:respawn/g' /etc/inittab
	sed -i 's/5:2345:respawn/#5:2345:respawn/g' /etc/inittab
	sed -i 's/6:2345:respawn/#6:2345:respawn/g' /etc/inittab
	sed -i 's/ca::ctrlaltdel/#ca::ctrlaltdel/g' /etc/inittab
	sed -i 's@LANG=.*$@LANG="en_US.UTF-8"@g' /etc/sysconfig/i18n
else
	sed -i 's@^ACTIVE_CONSOLES.*@ACTIVE_CONSOLES=/dev/tty[1-2]@' /etc/sysconfig/init	
	sed -i 's@^start@#start@' /etc/init/control-alt-delete.conf
fi
/sbin/init q

# Set timezone
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# Update time
/usr/sbin/ntpdate pool.ntp.org 
echo '*/20 * * * * /usr/sbin/ntpdate pool.ntp.org > /dev/null 2>&1' > /var/spool/cron/root;chmod 600 /var/spool/cron/root
/sbin/service crond restart

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
-A INPUT -p icmp -m limit --limit 100/sec --limit-burst 100 -j ACCEPT
-A INPUT -p icmp -m limit --limit 1/s --limit-burst 10 -j ACCEPT
-A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j syn-flood
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A syn-flood -p tcp -m limit --limit 3/sec --limit-burst 6 -j RETURN
-A syn-flood -j REJECT --reject-with icmp-port-unreachable
COMMIT
EOF
/sbin/service iptables restart
source /etc/profile

###install tmux
mkdir tmux
cd tmux
wget -c http://cloud.github.com/downloads/libevent/libevent/libevent-2.0.21-stable.tar.gz 
wget -c http://downloads.sourceforge.net/project/tmux/tmux/tmux-1.8/tmux-1.8.tar.gz 
tar xzf libevent-2.0.21-stable.tar.gz
cd libevent-2.0.21-stable
./configure
make && make install
cd ../

tar xzf tmux-1.8.tar.gz
cd tmux-1.8
CFLAGS="-I/usr/local/include" LDFLAGS="-L//usr/local/lib" ./configure
make && make install
cd ../../
rm -rf tmux

if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
    ln -s /usr/local/lib/libevent-2.0.so.5 /usr/lib64/libevent-2.0.so.5
else
    ln -s /usr/local/lib/libevent-2.0.so.5 /usr/lib/libevent-2.0.so.5
fi

###install htop
mkdir htop
cd htop
wget -c http://downloads.sourceforge.net/project/htop/htop/1.0.2/htop-1.0.2.tar.gz 
tar xzf htop-1.0.2.tar.gz
cd htop-1.0.2
./configure
make && make install
cd ../../
rm -rf htop
