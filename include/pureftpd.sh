#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_PureFTPd() {
  pushd ${oneinstack_dir}/src > /dev/null
  id -u ${run_user} >/dev/null 2>&1
  [ $? -ne 0 ] && useradd -M -s /sbin/nologin ${run_user}

  tar xzf pure-ftpd-${pureftpd_ver}.tar.gz
  pushd pure-ftpd-${pureftpd_ver}
  [ ! -d "${pureftpd_install_dir}" ] && mkdir -p ${pureftpd_install_dir}
  ./configure --prefix=${pureftpd_install_dir} CFLAGS=-O2 --with-puredb --with-quotas --with-cookie --with-virtualhosts --with-virtualchroot --with-diraliases --with-sysquotas --with-ratios --with-altlog --with-paranoidmsg --with-shadow --with-welcomemsg  --with-throttling --with-uploadscript --with-language=english --with-rfc2640
  make -j ${THREAD} && make install
  if [ -e "${pureftpd_install_dir}/sbin/pure-ftpwho" ]; then
    [ ! -e "${pureftpd_install_dir}/etc" ] && mkdir ${pureftpd_install_dir}/etc
    popd
    /bin/cp ../init.d/Pureftpd-init /etc/init.d/pureftpd
    /bin/cp ../config/pure-ftpd.conf ${pureftpd_install_dir}/etc
    sed -i "s@/usr/local/pureftpd@${pureftpd_install_dir}@g" /etc/init.d/pureftpd
    chmod +x /etc/init.d/pureftpd
    [ "${OS}" == "CentOS" ] && { chkconfig --add pureftpd; chkconfig pureftpd on; }
    [[ "${OS}" =~ ^Ubuntu$|^Debian$ ]] && { sed -i 's@^. /etc/rc.d/init.d/functions@. /lib/lsb/init-functions@' /etc/init.d/pureftpd; update-rc.d pureftpd defaults; }
    [ "${Debian_ver}" == '7' ] && sed -i 's@/var/lock/subsys/@/var/lock/@g' /etc/init.d/pureftpd

    sed -i "s@^PureDB.*@PureDB  ${pureftpd_install_dir}/etc/pureftpd.pdb@" ${pureftpd_install_dir}/etc/pure-ftpd.conf
    sed -i "s@^LimitRecursion.*@LimitRecursion  65535 8@" ${pureftpd_install_dir}/etc/pure-ftpd.conf
    ulimit -s unlimited
    service pureftpd start

    # iptables Ftp
    if [ "${iptables_yn}" == 'y' ]; then
      if [ "${OS}" == "CentOS" ]; then
        if [ -z "$(grep '20000:30000' /etc/sysconfig/iptables)" ]; then
          iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 21 -j ACCEPT
          iptables -I INPUT 6 -p tcp -m state --state NEW -m tcp --dport 20000:30000 -j ACCEPT
          service iptables save
        fi
      elif [[ "${OS}" =~ ^Ubuntu$|^Debian$ ]]; then
        if [ -z "$(grep '20000:30000' /etc/iptables.up.rules)" ]; then
          iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 21 -j ACCEPT
          iptables -I INPUT 6 -p tcp -m state --state NEW -m tcp --dport 20000:30000 -j ACCEPT
          iptables-save > /etc/iptables.up.rules
        fi
      fi
    fi

    echo "${CSUCCESS}Pure-Ftp installed successfully! ${CEND}"
    rm -rf pure-ftpd-${pureftpd_ver}
  else
    rm -rf ${pureftpd_install_dir}
    echo "${CFAILURE}Pure-Ftpd install failed, Please contact the author! ${CEND}"
    kill -9 $$
  fi
  popd
}
