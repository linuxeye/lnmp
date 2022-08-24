#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_Panel() {
  pushd ${oneinstack_dir}/../ > /dev/null
  git clone https://github.com/oneinstack/panel.git
  pushd panel > /dev/null
  sed -i "s@/root/oneinstack/options.conf@${oneinstack_dir}/options.conf@" panel/settings.py
  ${python_install_dir}/bin/pip3 install -r requirements.txt
  ${python_install_dir}/bin/python3 manage.py makemigrations
  ${python_install_dir}/bin/python3 manage.py migrate
  /bin/cp ${oneinstack_dir}/init.d/panel.service /lib/systemd/system/
  sed -i "s@/root/git/repo/panel@`pwd`@g" /lib/systemd/system/panel.service
  systemctl enable panel

  # Panel iptables
  Panel_port=`cat data/port.conf`
  if [ "${PM}" == 'yum' ]; then
    if [ -n "`grep 'dport 80 ' /etc/sysconfig/iptables`" ] && [ -z "$(grep -w ${Panel_port} /etc/sysconfig/iptables)" ]; then
      iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport ${Panel_port} -j ACCEPT
      service iptables save
      ip6tables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport ${Panel_port} -j ACCEPT
      service ip6tables save
    fi
  elif [ "${PM}" == 'apt-get' ]; then
    if [ -e '/etc/iptables/rules.v4' ]; then
      if [ -n "`grep 'dport 80 ' /etc/iptables/rules.v4`" ] && [ -z "$(grep -w ${Panel_port} /etc/iptables/rules.v4)" ]; then
        iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport ${Panel_port} -j ACCEPT
        iptables-save > /etc/iptables/rules.v4
        ip6tables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport ${Panel_port} -j ACCEPT
        ip6tables-save > /etc/iptables/rules.v6
      fi
    elif [ -e '/etc/iptables.up.rules' ]; then
      if [ -n "`grep 'dport 80 ' /etc/iptables.up.rules`" ] && [ -z "$(grep -w ${Panel_port} /etc/iptables.up.rules)" ]; then
        iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport ${Panel_port} -j ACCEPT
        iptables-save > /etc/iptables.up.rules
      fi
    fi
  fi

  popd > /dev/null
  popd > /dev/null
  systemctl start panel
}

Upgrade_Panel() {
  pushd ${oneinstack_dir}/../panel > /dev/null
  git pull
  ${python_install_dir}/bin/pip3 install -r requirements.txt -U
  ${python_install_dir}/bin/python3 manage.py makemigrations
  ${python_install_dir}/bin/python3 manage.py migrate
  popd > /dev/null
  systemctl reload panel
}

Uninstall_Panel() {
  systemctl stop panel
  pushd ${oneinstack_dir}/../ > /dev/null
  rm -rf panel
  popd > /dev/null
}
