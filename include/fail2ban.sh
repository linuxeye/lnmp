#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 8+ and Ubuntu 14+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_fail2ban() {
  pushd ${oneinstack_dir}/src > /dev/null
  src_url=http://mirrors.linuxeye.com/oneinstack/src/fail2ban-${fail2ban_ver}.tar.gz && Download_src
  tar xzf fail2ban-${fail2ban_ver}.tar.gz
  pushd fail2ban-${fail2ban_ver} > /dev/null
  sed -i 's@for i in xrange(50)@for i in range(50)@' fail2ban/__init__.py
  ${python_install_dir}/bin/python setup.py install
  if [ -e /bin/systemctl ]; then
    /bin/cp build/fail2ban.service /lib/systemd/system/
    systemctl enable fail2ban
  else
    if [ "${PM}" == 'yum' ]; then
      /bin/cp files/redhat-initd /etc/init.d/fail2ban
      sed -i "s@^FAIL2BAN=.*@FAIL2BAN=${python_install_dir}/bin/fail2ban-client@" /etc/init.d/fail2ban
      sed -i 's@Starting fail2ban.*@&\n    [ ! -e "/var/run/fail2ban" ] \&\& mkdir /var/run/fail2ban@' /etc/init.d/fail2ban
      chmod +x /etc/init.d/fail2ban
      chkconfig --add fail2ban
      chkconfig fail2ban on
    elif [ "${PM}" == 'apt-get' ]; then
      /bin/cp files/debian-initd /etc/init.d/fail2ban
      sed -i 's@2 3 4 5@3 4 5@' /etc/init.d/fail2ban
      sed -i "s@^DAEMON=.*@DAEMON=${python_install_dir}/bin/\$NAME-client@" /etc/init.d/fail2ban
      chmod +x /etc/init.d/fail2ban
      update-rc.d fail2ban defaults
    fi
  fi
  [ -z "`grep ^Port /etc/ssh/sshd_config`" ] && now_ssh_port=22 || now_ssh_port=`grep ^Port /etc/ssh/sshd_config | awk '{print $2}' | head -1`
  [ "${PM}" == 'yum' ] && LOGPATH=/var/log/secure
  [ "${PM}" == 'apt-get' ] && LOGPATH=/var/log/auth.log
  cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
ignoreip = 127.0.0.1/8
bantime  = 86400
findtime = 600
maxretry = 5
[ssh-iptables]
enabled = true
filter  = sshd
action  = iptables[name=SSH, port=${now_ssh_port}, protocol=tcp]
logpath = ${LOGPATH}
EOF
  cat > /etc/logrotate.d/fail2ban << EOF
/var/log/fail2ban.log {
    missingok
    notifempty
    postrotate
      ${python_install_dir}/bin/fail2ban-client flushlogs >/dev/null || true
    endscript
}
EOF
  sed -i 's@^iptables = iptables.*@iptables = iptables@' /etc/fail2ban/action.d/iptables-common.conf
  kill -9 `ps -ef | grep fail2ban | grep -v grep | awk '{print $2}'` > /dev/null 2>&1
  service fail2ban start
  popd > /dev/null
  if [ -e "${python_install_dir}/bin/fail2ban-server" ]; then
    echo; echo "${CSUCCESS}fail2ban installed successfully! ${CEND}"
  else
    echo; echo "${CFAILURE}fail2ban install failed, Please try again! ${CEND}"
  fi
  popd > /dev/null
}

Uninstall_fail2ban() {
  service fail2ban stop
  ${python_install_dir}/bin/pip uninstall -y fail2ban > /dev/null 2>&1
  rm -rf /etc/init.d/fail2ban /etc/fail2ban /etc/logrotate.d/fail2ban /var/log/fail2ban.* /var/run/fail2ban
  echo; echo "${CMSG}fail2ban uninstall completed${CEND}";
}
