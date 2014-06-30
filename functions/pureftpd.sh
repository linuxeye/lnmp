#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_PureFTPd()
{
cd $lnmp_dir/src
. ../functions/download.sh 
. ../functions/check_os.sh
. ../options.conf

src_url=http://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-1.0.36.tar.gz && Download_src
src_url=http://machiel.generaal.net/files/pureftpd/ftp_v2.1.tar.gz && Download_src

tar xzf pure-ftpd-1.0.36.tar.gz
cd pure-ftpd-1.0.36
[ $OS == 'Ubuntu' ] && ln -s $db_install_dir/lib/libmysqlclient.so /usr/lib
./configure --prefix=$pureftpd_install_dir CFLAGS=-O2 --with-mysql=$db_install_dir --with-quotas --with-cookie --with-virtualhosts --with-virtualchroot --with-diraliases --with-sysquotas --with-ratios --with-altlog --with-paranoidmsg --with-shadow --with-welcomemsg  --with-throttling --with-uploadscript --with-language=english --with-rfc2640
make && make install
if [ -d "$pureftpd_install_dir" ];then
        echo -e "\033[32mPure-Ftp install successfully! \033[0m"
	cp configuration-file/pure-config.pl $pureftpd_install_dir/sbin
	sed -i "s@/usr/local/pureftpd@$pureftpd_install_dir@" $pureftpd_install_dir/sbin/pure-config.pl
	chmod +x $pureftpd_install_dir/sbin/pure-config.pl
	cp contrib/redhat.init /etc/init.d/pureftpd
	cd ../../
	sed -i "s@fullpath=.*@fullpath=$pureftpd_install_dir/sbin/\$prog@" /etc/init.d/pureftpd
	sed -i "s@pureftpwho=.*@pureftpwho=$pureftpd_install_dir/sbin/pure-ftpwho@" /etc/init.d/pureftpd
	sed -i "s@/etc/pure-ftpd.conf@$pureftpd_install_dir/pure-ftpd.conf@" /etc/init.d/pureftpd
	chmod +x /etc/init.d/pureftpd
	OS_CentOS='chkconfig --add pureftpd \n
chkconfig pureftpd on'
	OS_Debian_Ubuntu="sed -i 's@^. /etc/rc.d/init.d/functions@. /lib/lsb/init-functions@' /etc/init.d/pureftpd \n
update-rc.d pureftpd defaults"
	OS_command

	/bin/cp conf/pure-ftpd.conf $pureftpd_install_dir/
	sed -i "s@^MySQLConfigFile.*@MySQLConfigFile   $pureftpd_install_dir/pureftpd-mysql.conf@" $pureftpd_install_dir/pure-ftpd.conf
	sed -i "s@^LimitRecursion.*@LimitRecursion	65535 8@" $pureftpd_install_dir/pure-ftpd.conf
	/bin/cp conf/pureftpd-mysql.conf $pureftpd_install_dir/
	conn_ftpusers_dbpwd=`cat /dev/urandom | head -1 | md5sum | head -c 8`
	sed -i "s@^conn_ftpusers_dbpwd.*@conn_ftpusers_dbpwd=$conn_ftpusers_dbpwd@" options.conf
	sed -i 's/tmppasswd/'$conn_ftpusers_dbpwd'/g' $pureftpd_install_dir/pureftpd-mysql.conf
	sed -i 's/conn_ftpusers_dbpwd/'$conn_ftpusers_dbpwd'/g' conf/script.mysql
	sed -i 's/ftpmanagerpwd/'$ftpmanagerpwd'/g' conf/script.mysql
	ulimit -s unlimited
	service mysqld restart
	$db_install_dir/bin/mysql -uroot -p$dbrootpwd < conf/script.mysql
	service pureftpd start

	cd src 
	tar xzf ftp_v2.1.tar.gz
	sed -i 's/tmppasswd/'$conn_ftpusers_dbpwd'/' ftp/config.php
	sed -i "s/myipaddress.com/`echo $local_IP`/" ftp/config.php
	sed -i 's@\$DEFUserID.*;@\$DEFUserID = "501";@' ftp/config.php
	sed -i 's@\$DEFGroupID.*;@\$DEFGroupID = "501";@' ftp/config.php
	sed -i 's@iso-8859-1@UTF-8@' ftp/language/english.php
	/bin/cp ../conf/chinese.php ftp/language/
	sed -i 's@\$LANG.*;@\$LANG = "chinese";@' ftp/config.php
	rm -rf  ftp/install.php
	mv ftp $home_dir/default
	cd ..

	# iptables Ftp
	iptables -I INPUT 5 -p tcp -m state --state NEW -m tcp --dport 21 -j ACCEPT
	iptables -I INPUT 6 -p tcp -m state --state NEW -m tcp --dport 20000:30000 -j ACCEPT
	OS_CentOS='service iptables save'
	OS_Debian_Ubuntu='iptables-save > /etc/iptables.up.rules'
	OS_command
else
	cd ../../
        echo -e "\033[31mPure-Ftp install failed, Please contact the author! \033[0m"
        kill -9 $$
fi
}
