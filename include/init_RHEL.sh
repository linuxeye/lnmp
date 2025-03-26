#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com

# Close SELINUX
setenforce 0
sed -i 's/^SELINUX=.*$/SELINUX=disabled/' /etc/selinux/config

# Custom profile
cat > /etc/profile.d/lnmp.sh << EOF
HISTSIZE=10000
PS1="\[\e[37;40m\][\[\e[32;40m\]\u\[\e[37;40m\]@\h \[\e[35;40m\]\W\[\e[0m\]]\\\\$ "
HISTTIMEFORMAT="%F %T \$(whoami) "

alias l='ls -AFhlt'
alias lh='l | head'
alias vi=vim

GREP_OPTIONS="--color=auto"
alias grep='grep --color'
alias egrep='egrep --color'
alias fgrep='fgrep --color'
EOF
[[ "${Platform}" =~ ^euleros$|^openeuler$ ]] && sed -i '/HISTTIMEFORMAT=/d' /etc/profile.d/lnmp.sh

[[ ! "${Platform}" =~ ^euleros$|^openeuler$ ]] && [ -z "$(grep ^'PROMPT_COMMAND=' /etc/bashrc)" ] && cat >> /etc/bashrc << EOF
PROMPT_COMMAND='{ msg=\$(history 1 | { read x y; echo \$y; });logger "[euid=\$(whoami)]":\$(who am i):[\`pwd\`]"\$msg"; }'
EOF

# /etc/security/limits.conf
[ -e /etc/security/limits.d/*nproc.conf ] && rename nproc.conf nproc.conf_bk /etc/security/limits.d/*nproc.conf
sed -i '/^# End of file/,$d' /etc/security/limits.conf
cat >> /etc/security/limits.conf <<EOF
# End of file
* soft nproc 1000000
* hard nproc 1000000
* soft nofile 1000000
* hard nofile 1000000
EOF

# /etc/hosts
[ "$(hostname -i | awk '{print $1}')" != "127.0.0.1" ] && sed -i "s@127.0.0.1.*localhost@&\n127.0.0.1 $(hostname)@g" /etc/hosts

# Set timezone
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/${timezone} /etc/localtime

# ip_conntrack table full dropping packets
echo -e "modprobe nf_conntrack\nmodprobe nf_conntrack_ipv4" > /etc/sysconfig/modules/nf_conntrack.modules
chmod +x /etc/sysconfig/modules/nf_conntrack.modules
modprobe nf_conntrack
modprobe nf_conntrack_ipv4
echo options nf_conntrack hashsize=131072 > /etc/modprobe.d/nf_conntrack.conf

# /etc/sysctl.conf
[ ! -e "/etc/sysctl.conf_bk" ] && /bin/mv /etc/sysctl.conf{,_bk}
cat > /etc/sysctl.conf << EOF
fs.file-max=1000000
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_sack = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_rmem = 4096 87380 4194304
net.ipv4.tcp_wmem = 4096 16384 4194304
net.ipv4.tcp_max_syn_backlog = 16384
net.core.netdev_max_backlog = 32768
net.core.somaxconn = 32768
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_fin_timeout = 20
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_syncookies = 1
#net.ipv4.tcp_tw_len = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.ip_local_port_range = 1024 65000
net.nf_conntrack_max = 6553500
net.netfilter.nf_conntrack_max = 6553500
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_established = 3600
EOF
sysctl -p

if [ ${RHEL_ver} -ge 7 >/dev/null 2>&1 ]; then
  sed -i 's@LANG=.*$@LANG="en_US.UTF-8"@g' /etc/locale.conf
fi

# firewall
if [ "${firewall_flag}" == 'y' ]; then
  systemctl enable firewalld
  systemctl start firewalld
  firewall-cmd --permanent --zone=public --add-port={22/tcp,80/tcp,443/tcp}
  [ "${ssh_port}" != "22" ] && firewall-cmd --permanent --zone=public --add-port=${ssh_port}/tcp
  firewall-cmd --reload
else
  systemctl stop firewalld
  systemctl disable firewalld
fi
systemctl restart rsyslog sshd

. /etc/profile
