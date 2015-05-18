#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_PureFTPd()
{
cd $lnmp_dir/src
. ../functions/download.sh 
. ../functions/check_os.sh
. ../options.conf

src_url=http://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-1.0.37.tar.gz && Download_src

tar xzf pure-ftpd-1.0.37.tar.gz
cd pure-ftpd-1.0.37
./configure --prefix=$pureftpd_install_dir CFLAGS=-O2 --with-puredb --with-quotas --with-cookie --with-virtualhosts --with-virtualchroot --with-diraliases --with-sysquotas --with-ratios --with-altlog --with-paranoidmsg --with-shadow --with-welcomemsg  --with-throttling --with-uploadscript --with-language=english --with-rfc2640
make && make install
if [ -d "$pureftpd_install_dir" ];then
        echo -e "\033[32mPure-Ftp install successfully! \033[0m"
	[ ! -e "$pureftpd_install_dir/etc" ] && mkdir $pureftpd_install_dir/etc
	cp configuration-file/pure-config.pl $pureftpd_install_dir/sbin
	sed -i "s@/usr/local/pureftpd@$pureftpd_install_dir@" $pureftpd_install_dir/sbin/pure-config.pl
	chmod +x $pureftpd_install_dir/sbin/pure-config.pl
	cp contrib/redhat.init /etc/init.d/pureftpd
	cd ../../
	sed -i "s@fullpath=.*@fullpath=$pureftpd_install_dir/sbin/\$prog@" /etc/init.d/pureftpd
	sed -i "s@pureftpwho=.*@pureftpwho=$pureftpd_install_dir/sbin/pure-ftpwho@" /etc/init.d/pureftpd
	sed -i "s@/etc/pure-ftpd.conf@$pureftpd_install_dir/etc/pure-ftpd.conf@" /etc/init.d/pureftpd
	chmod +x /etc/init.d/pureftpd
	OS_CentOS='chkconfig --add pureftpd \n
chkconfig pureftpd on'
	OS_Debian_Ubuntu="sed -i 's@^. /etc/rc.d/init.d/functions@. /lib/lsb/init-functions@' /etc/init.d/pureftpd \n
update-rc.d pureftpd defaults"
	OS_command

	/bin/cp conf/pure-ftpd.conf $pureftpd_install_dir/etc
	sed -i "s@^PureDB.*@PureDB	$pureftpd_install_dir/etc/pureftpd.pdb@" $pureftpd_install_dir/etc/pure-ftpd.conf
	sed -i "s@^LimitRecursion.*@LimitRecursion	65535 8@" $pureftpd_install_dir/etc/pure-ftpd.conf
	ulimit -s unlimited
	service pureftpd start

	# iptables Ftp
	if [ -e '/etc/sysconfig/iptables' ];then
		if [ -z "`grep '20000:30000' /etc/sysconfig/iptables`" ];then
			iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 21 -j ACCEPT
			iptables -I INPUT 6 -p tcp -m state --state NEW -m tcp --dport 20000:30000 -j ACCEPT
		fi
	elif [ -e '/etc/iptables.up.rules' ];then
		if [ -z "`grep '20000:30000' /etc/iptables.up.rules`" ];then
			iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 21 -j ACCEPT
			iptables -I INPUT 6 -p tcp -m state --state NEW -m tcp --dport 20000:30000 -j ACCEPT
		fi
	fi
	OS_CentOS='service iptables save'
	OS_Debian_Ubuntu='iptables-save > /etc/iptables.up.rules'
	OS_command
else
	cd ../../
        echo -e "\033[31mPure-Ftp install failed, Please contact the author! \033[0m"
        kill -9 $$
fi
}
