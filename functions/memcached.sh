#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_memcached()
{
cd $lnmp_dir/src
. ../functions/download.sh 
. ../functions/check_os.sh
. ../options.conf

src_url=http://www.memcached.org/files/memcached-$memcached_version.tar.gz && Download_src

# memcached server
useradd -M -s /sbin/nologin memcached
tar xzf memcached-$memcached_version.tar.gz
cd memcached-$memcached_version
[ ! -d "$memcached_install_dir" ] && mkdir -p $memcached_install_dir
./configure --prefix=$memcached_install_dir
make && make install
cd ../
/bin/rm -rf memcached-$memcached_version
if [ -d "$memcached_install_dir/bin" ];then
        echo -e "\033[32mmemcached install successfully! \033[0m"
	ln -s $memcached_install_dir/bin/memcached /usr/bin/memcached
	OS_CentOS='/bin/cp ../init/Memcached-init-CentOS /etc/init.d/memcached \n
chkconfig --add memcached \n
chkconfig memcached on'
	OS_Debian_Ubuntu='/bin/cp ../init/Memcached-init-Ubuntu /etc/init.d/memcached \n
update-rc.d memcached defaults'
	OS_command
	sed -i "s@/usr/local/memcached@$memcached_install_dir@g" /etc/init.d/memcached
	service memcached start
else
	rm -rf $memcached_install_dir
        echo -e "\033[31mmemcached install failed, Please contact the author! \033[0m"
        kill -9 $$
fi

if [ -e "$php_install_dir/bin/phpize" ];then
	src_url=https://launchpad.net/libmemcached/1.0/$libmemcached_version/+download/libmemcached-$libmemcached_version.tar.gz && Download_src
	src_url=http://pecl.php.net/get/memcached-$memcached_pecl_version.tgz && Download_src
	src_url=http://pecl.php.net/get/memcache-$memcache_pecl_version.tgz && Download_src
	# php memcache extension
	tar xzf memcache-$memcache_pecl_version.tgz 
	cd memcache-$memcache_pecl_version 
	make clean
	$php_install_dir/bin/phpize
	./configure --with-php-config=$php_install_dir/bin/php-config
	make && make install
	cd ..
	/bin/rm -rf memcache-$memcache_pecl_version
	if [ -f "$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions | grep zts`/memcache.so" ];then
		[ -z "`cat $php_install_dir/etc/php.ini | grep '^extension_dir'`" ] && sed -i "s@extension_dir = \"ext\"@extension_dir = \"ext\"\nextension_dir = \"$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions | grep zts`\"@" $php_install_dir/etc/php.ini
	        sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "memcache.so"@' $php_install_dir/etc/php.ini
	        [ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
	else
	        echo -e "\033[31mPHP memcache module install failed, Please contact the author! \033[0m"
	fi

	# php memcached extension
	tar xzf libmemcached-$libmemcached_version.tar.gz
	cd libmemcached-$libmemcached_version
	OS_CentOS='yum -y install cyrus-sasl-devel'
	OS_Debian_Ubuntu='sed -i "s@lthread -pthread -pthreads@lthread -lpthread -pthreads@" ./configure'
	OS_command
	./configure --with-memcached=$memcached_install_dir
	make && make install
	cd ..
	/bin/rm -rf libmemcached-$libmemcached_version

	tar xzf memcached-$memcached_pecl_version.tgz
	cd memcached-$memcached_pecl_version
	make clean
	$php_install_dir/bin/phpize
	./configure --with-php-config=$php_install_dir/bin/php-config
	make && make install
	cd ../
	/bin/rm -rf memcached-$memcached_pecl_version
	if [ -f "$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions | grep zts`/memcached.so" ];then
		[ -z "`cat $php_install_dir/etc/php.ini | grep '^extension_dir'`" ] && sed -i "s@extension_dir = \"ext\"@extension_dir = \"ext\"\nextension_dir = \"$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions/ | grep zts`\"@" $php_install_dir/etc/php.ini
	        sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "memcached.so"\nmemcached.use_sasl = 1@' $php_install_dir/etc/php.ini
	        [ "$Apache_version" != '1' -a "$Apache_version" != '2' ] && service php-fpm restart || service httpd restart
	else
	        echo -e "\033[31mPHP memcached module install failed, Please contact the author! \033[0m"
	fi
fi
cd ../
}
