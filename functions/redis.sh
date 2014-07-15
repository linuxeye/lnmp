#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_redis()
{
cd $lnmp_dir/src
. ../functions/download.sh 
. ../functions/check_os.sh
. ../options.conf

if [ -e "$php_install_dir/bin/phpize" ];then
	src_url=http://pecl.php.net/get/redis-2.2.5.tgz && Download_src
	tar xzf redis-2.2.5.tgz
	cd redis-2.2.5
	make clean
	$php_install_dir/bin/phpize
	./configure --with-php-config=$php_install_dir/bin/php-config
	make && make install
	cd ..
	/bin/rm -rf redis-2.2.5
	if [ -f "$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions | grep zts`/redis.so" ];then
		[ -z "`cat $php_install_dir/etc/php.ini | grep '^extension_dir'`" ] && sed -i "s@extension_dir = \"ext\"@extension_dir = \"ext\"\nextension_dir = \"$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions  | grep zts`\"@" $php_install_dir/etc/php.ini
		sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "redis.so"@' $php_install_dir/etc/php.ini
		[ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
	else
	        echo -e "\033[31mPHP Redis module install failed, Please contact the author! \033[0m"
	fi
fi

src_url=http://download.redis.io/releases/redis-2.8.13.tar.gz && Download_src
tar xzf redis-2.8.13.tar.gz
cd redis-2.8.13
if [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 32 ];then
	sed -i '1i\CFLAGS= -march=i686' src/Makefile
	sed -i 's@^OPT=.*@OPT=-O2 -march=i686@' src/.make-settings
fi

make

if [ -f "src/redis-server" ];then
	mkdir -p $redis_install_dir/{bin,etc,var}
	/bin/cp src/{redis-benchmark,redis-check-aof,redis-check-dump,redis-cli,redis-sentinel,redis-server} $redis_install_dir/bin/
	/bin/cp redis.conf $redis_install_dir/etc/
	ln -s $redis_install_dir/bin/* /usr/local/bin/
	sed -i 's@pidfile.*@pidfile /var/run/redis.pid@' $redis_install_dir/etc/redis.conf
	sed -i "s@logfile.*@logfile $redis_install_dir/var/redis.log@" $redis_install_dir/etc/redis.conf
	sed -i "s@^dir.*@dir $redis_install_dir/var@" $redis_install_dir/etc/redis.conf
	sed -i 's@daemonize no@daemonize yes@' $redis_install_dir/etc/redis.conf

	Memtatol=`free -m | grep 'Mem:' | awk '{print $2}'`
	if [ $Memtatol -le 512 ];then
		[ -z "`grep ^maxmemory $redis_install_dir/etc/redis.conf`" ] && sed -i 's@maxmemory <bytes>@maxmemory <bytes>\nmaxmemory 64000000@' $redis_install_dir/etc/redis.conf
	elif [ $Memtatol -gt 512 -a $Memtatol -le 1024 ];then
		[ -z "`grep ^maxmemory $redis_install_dir/etc/redis.conf`" ] && sed -i 's@maxmemory <bytes>@maxmemory <bytes>\nmaxmemory 128000000@' $redis_install_dir/etc/redis.conf
	elif [ $Memtatol -gt 1024 -a $Memtatol -le 1500 ];then
		[ -z "`grep ^maxmemory $redis_install_dir/etc/redis.conf`" ] && sed -i 's@maxmemory <bytes>@maxmemory <bytes>\nmaxmemory 256000000@' $redis_install_dir/etc/redis.conf
	elif [ $Memtatol -gt 1500 -a $Memtatol -le 2500 ];then
		[ -z "`grep ^maxmemory $redis_install_dir/etc/redis.conf`" ] && sed -i 's@maxmemory <bytes>@maxmemory <bytes>\nmaxmemory 360000000@' $redis_install_dir/etc/redis.conf
	elif [ $Memtatol -gt 2500 -a $Memtatol -le 3500 ];then
		[ -z "`grep ^maxmemory $redis_install_dir/etc/redis.conf`" ] && sed -i 's@maxmemory <bytes>@maxmemory <bytes>\nmaxmemory 512000000@' $redis_install_dir/etc/redis.conf
	elif [ $Memtatol -gt 3500 ];then
		[ -z "`grep ^maxmemory $redis_install_dir/etc/redis.conf`" ] && sed -i 's@maxmemory <bytes>@maxmemory <bytes>\nmaxmemory 1024000000@' $redis_install_dir/etc/redis.conf
	fi

	cd ..
	/bin/rm -rf redis-2.8.13
	cd ..
	OS_CentOS='/bin/cp init/Redis-server-init-CentOS /etc/init.d/redis-server \n
chkconfig --add redis-server \n
chkconfig redis-server on'
	OS_Debian_Ubuntu="useradd -M -s /sbin/nologin redis \n
chown -R redis:redis $redis_install_dir/var/ \n
/bin/cp init/Redis-server-init-Ubuntu /etc/init.d/redis-server \n
update-rc.d redis-server defaults"
	OS_command
	sed -i "s@/usr/local/redis@$redis_install_dir@g" /etc/init.d/redis-server
	#[ -z "`grep 'vm.overcommit_memory' /etc/sysctl.conf`" ] && echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
	#sysctl -p
	service redis-server start
else
	cd ../../
	echo -e "\033[31mRedis install failed, Please contact the author! \033[0m"
fi
}
