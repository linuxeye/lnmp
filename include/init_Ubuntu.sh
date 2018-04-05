#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

# Custom profile
cat > /etc/profile.d/oneinstack.sh << EOF
HISTSIZE=10000
HISTTIMEFORMAT="%F %T \$(whoami) "

alias l='ls -AFhlt --color=auto'
alias lh='l | head'
alias ll='ls -l --color=auto'
alias ls='ls --color=auto'
alias vi=vim

GREP_OPTIONS="--color=auto"
alias grep='grep --color'
alias egrep='egrep --color'
alias fgrep='fgrep --color'
EOF

sed -i 's@^"syntax on@syntax on@' /etc/vim/vimrc

# PS1
[ -z "$(grep ^PS1 ~/.bashrc)" ] && echo "PS1='\${debian_chroot:+(\$debian_chroot)}\\[\\e[1;32m\\]\\u@\\h\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\033[00m\\]\\$ '" >> ~/.bashrc

# history
[ -z "$(grep history-timestamp ~/.bashrc)" ] && echo "PROMPT_COMMAND='{ msg=\$(history 1 | { read x y; echo \$y; });user=\$(whoami); echo \$(date \"+%Y-%m-%d %H:%M:%S\"):\$user:\`pwd\`/:\$msg ---- \$(who am i); } >> /tmp/\`hostname\`.\`whoami\`.history-timestamp'" >> ~/.bashrc

# /etc/security/limits.conf
[ -e /etc/security/limits.d/*nproc.conf ] && rename nproc.conf nproc.conf_bk /etc/security/limits.d/*nproc.conf
[ -z "$(grep 'session required pam_limits.so' /etc/pam.d/common-session)" ] && echo "session required pam_limits.so" >> /etc/pam.d/common-session
sed -i '/^# End of file/,$d' /etc/security/limits.conf
cat >> /etc/security/limits.conf <<EOF
# End of file
* soft nproc 65535
* hard nproc 65535
* soft nofile 65535
* hard nofile 65535
root soft nproc 65535
root hard nproc 65535
root soft nofile 65535
root hard nofile 65535
EOF

# /etc/hosts
[ "$(hostname -i | awk '{print $1}')" != "127.0.0.1" ] && sed -i "s@127.0.0.1.*localhost@&\n127.0.0.1 $(hostname)@g" /etc/hosts

# Set timezone
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# Set DNS
#cat > /etc/resolv.conf << EOF
#nameserver 114.114.114.114
#nameserver 8.8.8.8
#EOF

# /etc/sysctl.conf
[ -z "$(grep 'fs.file-max' /etc/sysctl.conf)" ] && cat >> /etc/sysctl.conf << EOF
fs.file-max=65535
fs.inotify.max_user_instances = 8192
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 32768
net.core.netdev_max_backlog = 32768
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_max_orphans = 32768
EOF
sysctl -p

sed -i 's@^ACTIVE_CONSOLES.*@ACTIVE_CONSOLES="/dev/tty[1-2]"@' /etc/default/console-setup
sed -i 's@^@#@g' /etc/init/tty[3-6].conf
locale-gen en_US.UTF-8
echo "en_US.UTF-8 UTF-8" > /var/lib/locales/supported.d/local
cat > /etc/default/locale << EOF
LANG=en_US.UTF-8
LANGUAGE=en_US:en
EOF
sed -i 's@^@#@g' /etc/init/control-alt-delete.conf

# Update time
ntpdate pool.ntp.org
[ ! -e "/var/spool/cron/crontabs/root" -o -z "$(grep ntpdate /var/spool/cron/crontabs/root 2>/dev/null)" ] && { echo "*/20 * * * * $(which ntpdate) pool.ntp.org > /dev/null 2>&1" >> /var/spool/cron/crontabs/root;chmod 600 /var/spool/cron/crontabs/root; }

# iptables
if [ "${iptables_yn}" == 'y' ]; then
  if [ -e "/etc/iptables.up.rules" ] && [ -n "$(grep '^:INPUT DROP' /etc/iptables.up.rules)" -a -n "$(grep 'NEW -m tcp --dport 22 -j ACCEPT' /etc/iptables.up.rules)" -a -n "$(grep 'NEW -m tcp --dport 80 -j ACCEPT' /etc/iptables.up.rules)" ]; then
    IPTABLES_STATUS=yes
  else
    IPTABLES_STATUS=no
  fi

  if [ "${IPTABLES_STATUS}" == "no" ]; then
    [ -e "/etc/iptables.up.rules" ] && /bin/mv /etc/iptables.up.rules{,_bk}
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
-A INPUT -p icmp -m limit --limit 1/sec --limit-burst 10 -j ACCEPT
-A INPUT -f -m limit --limit 100/sec --limit-burst 100 -j ACCEPT
-A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j syn-flood
-A INPUT -j REJECT --reject-with icmp-host-prohibited
-A syn-flood -p tcp -m limit --limit 3/sec --limit-burst 6 -j RETURN
-A syn-flood -j REJECT --reject-with icmp-port-unreachable
COMMIT
EOF
  fi

  FW_PORT_FLAG=$(grep -ow "dport ${ssh_port}" /etc/iptables.up.rules)
  [ -z "${FW_PORT_FLAG}" -a "${ssh_port}" != "22" ] && sed -i "s@dport 22 -j ACCEPT@&\n-A INPUT -p tcp -m state --state NEW -m tcp --dport ${ssh_port} -j ACCEPT@" /etc/iptables.up.rules
  iptables-restore < /etc/iptables.up.rules
  cat > /etc/network/if-pre-up.d/iptables << EOF
#!/bin/bash
/sbin/iptables-restore < /etc/iptables.up.rules
EOF
  chmod +x /etc/network/if-pre-up.d/iptables
fi
service rsyslog restart
service ssh restart

. /etc/profile
. ~/.bashrc
