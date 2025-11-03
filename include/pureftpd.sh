#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com

Install_PureFTPd() {
  pushd ${current_dir}/src > /dev/null
  id -g ${run_group} >/dev/null 2>&1
  [ $? -ne 0 ] && groupadd ${run_group}
  id -u ${run_user} >/dev/null 2>&1
  [ $? -ne 0 ] && useradd -g ${run_group} -M -s /sbin/nologin ${run_user}

  tar xzf pure-ftpd-${pureftpd_ver}.tar.gz
  pushd pure-ftpd-${pureftpd_ver} > /dev/null
  [ ! -d "${pureftpd_install_dir}" ] && mkdir -p ${pureftpd_install_dir}
  ./configure --prefix=${pureftpd_install_dir} CFLAGS=-O2 --with-puredb --with-quotas --with-cookie --with-virtualhosts --with-virtualchroot --with-diraliases --with-sysquotas --with-ratios --with-altlog --with-paranoidmsg --with-shadow --with-welcomemsg --with-throttling --with-uploadscript --with-language=english --with-tls
  make -j ${THREAD} && make install
  popd > /dev/null
  if [ -e "${pureftpd_install_dir}/sbin/pure-ftpwho" ]; then
    /bin/cp ../init.d/pureftpd.service /lib/systemd/system/
    sed -i "s@/usr/local/pureftpd@${pureftpd_install_dir}@g" /lib/systemd/system/pureftpd.service
    systemctl enable pureftpd

    [ ! -e "${pureftpd_install_dir}/etc" ] && mkdir ${pureftpd_install_dir}/etc
    /bin/cp ../config/pure-ftpd.conf ${pureftpd_install_dir}/etc
    sed -i "s@^PureDB.*@PureDB  ${pureftpd_install_dir}/etc/pureftpd.pdb@" ${pureftpd_install_dir}/etc/pure-ftpd.conf
    sed -i "s@^LimitRecursion.*@LimitRecursion  65535 8@" ${pureftpd_install_dir}/etc/pure-ftpd.conf
    IPADDR=${IPADDR:-127.0.0.1}
    [ ! -d /etc/ssl/private ] && mkdir -p /etc/ssl/private
    openssl dhparam -out /etc/ssl/private/pure-ftpd-dhparams.pem 2048
    openssl req -x509 -days 7300 -sha256 -nodes -subj "/C=CN/ST=Shanghai/L=Shanghai/O=LinuxEye/CN=${IPADDR}" -newkey rsa:2048 -keyout /etc/ssl/private/pure-ftpd.pem -out /etc/ssl/private/pure-ftpd.pem
    chmod 600 /etc/ssl/private/pure-ftpd*.pem
    sed -i "s@^# TLS.*@&\nCertFile                   /etc/ssl/private/pure-ftpd.pem@" ${pureftpd_install_dir}/etc/pure-ftpd.conf
    sed -i "s@^# TLS.*@&\nTLSCipherSuite             HIGH:MEDIUM:+TLSv1:\!SSLv2:\!SSLv3@" ${pureftpd_install_dir}/etc/pure-ftpd.conf
    sed -i "s@^# TLS.*@TLS                        1@" ${pureftpd_install_dir}/etc/pure-ftpd.conf
    ulimit -s unlimited
    systemctl start pureftpd

    # Firewall Ftp
    if [ "${PM}" == 'yum' ]; then
      if [ "`firewall-cmd --state`" == "running" ]; then
        firewall-cmd --permanent --zone=public --add-port={21/tcp,20000-30000/tcp}
        firewall-cmd --reload
      fi
    elif [ "${PM}" == 'apt-get' ]; then
      if ufw status | grep -wq active; then
	  ufw allow 21/tcp
	  ufw allow 20000:30000/tcp
      fi
    fi

    echo "${CSUCCESS}Pure-Ftp installed successfully! ${CEND}"
    rm -rf pure-ftpd-${pureftpd_ver}
  else
    rm -rf ${pureftpd_install_dir}
    echo "${CFAILURE}Pure-Ftpd install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
    kill -9 $$; exit 1;
  fi
  popd > /dev/null
}
