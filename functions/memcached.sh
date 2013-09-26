#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_memcached()
{
cd $lnmp_dir/src
. ../functions/download.sh 
. ../functions/check_os.sh
. ../options.conf

src_url=http://pkgs.fedoraproject.org/lookaside/pkgs/memcached/memcached-1.4.15.tar.gz/36ea966f5a29655be1746bf4949f7f69/memcached-1.4.15.tar.gz && Download_src
src_url=https://launchpad.net/libmemcached/1.0/1.0.16/+download/libmemcached-1.0.16.tar.gz && Download_src
src_url=http://pecl.php.net/get/memcached-2.1.0.tgz && Download_src
src_url=http://pecl.php.net/get/memcache-2.2.7.tgz && Download_src

# memcached server
useradd -M -s /sbin/nologin memcached
tar xzf memcached-1.4.15.tar.gz
cd memcached-1.4.15
./configure --prefix=$memcached_install_dir
make && make install
cd ../
if [ -d "$memcached_install_dir" ];then
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
        echo -e "\033[31mmemcached install failed, Please contact the author! \033[0m"
fi

# php memcache extension
tar xzf memcache-2.2.7.tgz 
cd memcache-2.2.7 
make clean
$php_install_dir/bin/phpize
./configure --with-php-config=$php_install_dir/bin/php-config
make && make install
cd ..
if [ -f "$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions`/memcache.so" ];then
        sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "memcache.so"@' $php_install_dir/etc/php.ini
        service php-fpm restart
else
        echo -e "\033[31mPHP memcache module install failed, Please contact the author! \033[0m"
fi

# php memcached extension
tar xzf libmemcached-1.0.16.tar.gz
cd libmemcached-1.0.16
./configure --with-memcached=$memcached_install_dir
make && make install
cd ..

tar xzf memcached-2.1.0.tgz
cd memcached-2.1.0
make clean
$php_install_dir/bin/phpize
./configure --with-php-config=$php_install_dir/bin/php-config
make && make install
cd ../
if [ -f "$php_install_dir/lib/php/extensions/`ls $php_install_dir/lib/php/extensions`/memcached.so" ];then
        sed -i 's@^extension_dir\(.*\)@extension_dir\1\nextension = "memcached.so"@' $php_install_dir/etc/php.ini
	service php-fpm restart
else
        echo -e "\033[31mPHP memcached module install failed, Please contact the author! \033[0m"
fi

cd ../
}
