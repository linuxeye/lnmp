#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 7+ and Ubuntu 12+
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
  ./configure --prefix=${pureftpd_install_dir} CFLAGS=-O2 --with-puredb --with-quotas --with-cookie --with-virtualhosts --with-virtualchroot --with-diraliases --with-sysquotas --with-ratios --with-altlog --with-paranoidmsg --with-shadow --with-welcomemsg --with-throttling --with-uploadscript --with-language=english --with-rfc2640 --with-tls
  make -j ${THREAD} && make install
  popd
  if [ -e "${pureftpd_install_dir}/sbin/pure-ftpwho" ]; then
    if [ -e /bin/systemctl ]; then
      /bin/cp ../init.d/pureftpd.service /lib/systemd/system/
      sed -i "s@/usr/local/pureftpd@${pureftpd_install_dir}@g" /lib/systemd/system/pureftpd.service
      systemctl enable pureftpd
    else
      /bin/cp ../init.d/Pureftpd-init /etc/init.d/pureftpd
      sed -i "s@/usr/local/pureftpd@${pureftpd_install_dir}@g" /etc/init.d/pureftpd
      chmod +x /etc/init.d/pureftpd
      [ "${PM}" == 'yum' ] && { chkconfig --add pureftpd; chkconfig pureftpd on; }
      [ "${PM}" == 'apt' ] && { sed -i 's@^. /etc/rc.d/init.d/functions@. /lib/lsb/init-functions@' /etc/init.d/pureftpd; update-rc.d pureftpd defaults; }
      [ "${Debian_ver}" == '7' ] && sed -i 's@/var/lock/subsys/@/var/lock/@g' /etc/init.d/pureftpd
    fi

    [ ! -e "${pureftpd_install_dir}/etc" ] && mkdir ${pureftpd_install_dir}/etc
    /bin/cp ../config/pure-ftpd.conf ${pureftpd_install_dir}/etc
    sed -i "s@^PureDB.*@PureDB  ${pureftpd_install_dir}/etc/pureftpd.pdb@" ${pureftpd_install_dir}/etc/pure-ftpd.conf
    sed -i "s@^LimitRecursion.*@LimitRecursion  65535 8@" ${pureftpd_install_dir}/etc/pure-ftpd.conf
    [ -z "${IPADDR}" ] && IPADDR=127.0.0.1
    [ ! -d /etc/ssl/private ] && mkdir -p /etc/ssl/private
    openssl dhparam -out /etc/ssl/private/pure-ftpd-dhparams.pem 2048
    openssl req -x509 -days 7300 -sha256 -nodes -subj "/C=CN/ST=Shanghai/L=Shanghai/O=OneinStack/CN=${IPADDR}" -newkey rsa:2048 -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem
    chmod 600 /etc/ssl/private/pure-ftpd*.pem
    sed -i "s@^# TLS.*@&\nCertFile                   /etc/ssl/private/pure-ftpd.pem@" ${pureftpd_install_dir}/etc/pure-ftpd.conf
    sed -i "s@^# TLS.*@&\nTLSCipherSuite             HIGH:MEDIUM:+TLSv1:\!SSLv2:\!SSLv3@" ${pureftpd_install_dir}/etc/pure-ftpd.conf
    sed -i "s@^# TLS.*@TLS                        1@" ${pureftpd_install_dir}/etc/pure-ftpd.conf
    ulimit -s unlimited
    service pureftpd start

    # iptables Ftp
    if [ "${iptables_yn}" == 'y' ]; then
      if [ "${PM}" == 'yum' ]; then
        if [ -z "$(grep '20000:30000' /etc/sysconfig/iptables)" ]; then
          iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 21 -j ACCEPT
          iptables -I INPUT 6 -p tcp -m state --state NEW -m tcp --dport 20000:30000 -j ACCEPT
          service iptables save
        fi
      elif [ "${PM}" == 'apt' ]; then
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
