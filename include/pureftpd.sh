#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       http://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_PureFTPd() {
cd $oneinstack_dir/src
src_url=http://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-$pureftpd_version.tar.gz && Download_src

tar xzf pure-ftpd-$pureftpd_version.tar.gz

id -u $run_user >/dev/null 2>&1
[ $? -ne 0 ] && useradd -M -s /sbin/nologin $run_user

cd pure-ftpd-$pureftpd_version
[ ! -d "$pureftpd_install_dir" ] && mkdir -p $pureftpd_install_dir
./configure --prefix=$pureftpd_install_dir CFLAGS=-O2 --with-puredb --with-quotas --with-cookie --with-virtualhosts --with-virtualchroot --with-diraliases --with-sysquotas --with-ratios --with-altlog --with-paranoidmsg --with-shadow --with-welcomemsg  --with-throttling --with-uploadscript --with-language=english --with-rfc2640
make && make install
if [ -e "$pureftpd_install_dir/sbin/pure-ftpwho" ];then
    echo "${CSUCCESS}Pure-Ftp install successfully! ${CEND}"
    [ ! -e "$pureftpd_install_dir/etc" ] && mkdir $pureftpd_install_dir/etc
    cp configuration-file/pure-config.pl $pureftpd_install_dir/sbin
    sed -i "s@/usr/local/pureftpd@$pureftpd_install_dir@" $pureftpd_install_dir/sbin/pure-config.pl
    chmod +x $pureftpd_install_dir/sbin/pure-config.pl
    cp contrib/redhat.init /etc/init.d/pureftpd
    sed -i "s@fullpath=.*@fullpath=$pureftpd_install_dir/sbin/\$prog@" /etc/init.d/pureftpd
    sed -i "s@pureftpwho=.*@pureftpwho=$pureftpd_install_dir/sbin/pure-ftpwho@" /etc/init.d/pureftpd
    sed -i "s@/etc/pure-ftpd.conf@$pureftpd_install_dir/etc/pure-ftpd.conf@" /etc/init.d/pureftpd
    chmod +x /etc/init.d/pureftpd
    [ "$OS" == 'CentOS' ] && { chkconfig --add pureftpd; chkconfig pureftpd on; }
    [[ $OS =~ ^Ubuntu$|^Debian$ ]] && { sed -i 's@^. /etc/rc.d/init.d/functions@. /lib/lsb/init-functions@' /etc/init.d/pureftpd; [ -z "`grep ^'# Default-Start' /etc/init.d/pureftpd`" ] && sed -i "s@^# chkconfig.*@# chkconfig&\n# Default-Start: 2 3 4 5\n# Default-Stop: 0 1 6@" /etc/init.d/pureftpd; update-rc.d pureftpd defaults; }
    [ "$Debian_version" == '7' ] && sed -i 's@/var/lock/subsys/@/var/lock/@g' /etc/init.d/pureftpd 
    cd ../../

    /bin/cp config/pure-ftpd.conf $pureftpd_install_dir/etc
    sed -i "s@^PureDB.*@PureDB	$pureftpd_install_dir/etc/pureftpd.pdb@" $pureftpd_install_dir/etc/pure-ftpd.conf
    sed -i "s@^LimitRecursion.*@LimitRecursion	65535 8@" $pureftpd_install_dir/etc/pure-ftpd.conf
    ulimit -s unlimited
    service pureftpd start

    # iptables Ftp
    if [ "$OS" == 'CentOS' ];then
        if [ -z "`grep '20000:30000' /etc/sysconfig/iptables`" ];then
            iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 21 -j ACCEPT
            iptables -I INPUT 6 -p tcp -m state --state NEW -m tcp --dport 20000:30000 -j ACCEPT
            service iptables save
        fi
    elif [[ $OS =~ ^Ubuntu$|^Debian$ ]];then 
        if [ -z "`grep '20000:30000' /etc/iptables.up.rules`" ];then
            iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 21 -j ACCEPT
            iptables -I INPUT 6 -p tcp -m state --state NEW -m tcp --dport 20000:30000 -j ACCEPT
            iptables-save > /etc/iptables.up.rules
        fi
    fi
else
    rm -rf $pureftpd_install_dir
    echo "${CFAILURE}Pure-Ftp install failed, Please contact the author! ${CEND}"
    kill -9 $$
fi
}
