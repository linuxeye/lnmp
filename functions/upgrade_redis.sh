#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Upgrade_Redis()
{
cd $lnmp_dir/src
[ ! -d "$redis_install_dir" ] && echo -e "\033[31mThe Redis is not installed on your system!\033[0m " && exit 1
Old_redis_version=`$redis_install_dir/bin/redis-cli --version | awk '{print $2}'`
echo -e "Current Redis Version: \033[32m$Old_redis_version\033[0m"
while :
do
        echo
        read -p "Please input upgrade Redis Version(example: 2.8.4): " redis_version
	if [ "$redis_version" != "$Old_redis_version" ];then
		[ ! -e "redis-$redis_version.tar.gz" ] && wget -c http://download.redis.io/releases/redis-$redis_version.tar.gz > /dev/null 2>&1
		if [ -e "redis-$redis_version.tar.gz" ];then
			echo -e "Download \033[32mredis-$redis_version.tar.gz\033[0m successfully! "
			break
		else
			echo -e "\033[31mRedis version does not exist!\033[0m"
		fi
	else
		echo -e "\033[31minput error! The upgrade Redis version is the same as the old version\033[0m"
	fi
done

if [ -e "redis-$redis_version.tar.gz" ];then
        echo -e "\033[32mredis-$redis_version.tar.gz\033[0m [found]"
        echo "Press Ctrl+c to cancel or Press any key to continue..."
        char=`get_char`
        tar xzf redis-$redis_version.tar.gz
        cd redis-$redis_version
	make clean
	if [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 32 ];then
	        sed -i '1i\CFLAGS= -march=i686' src/Makefile
	        sed -i 's@^OPT=.*@OPT=-O2 -march=i686@' src/.make-settings
	fi

	make

	if [ -f "src/redis-server" ];then
		echo -e "\nRestarting Redis..."
		service redis-server stop
	        /bin/cp src/{redis-benchmark,redis-check-aof,redis-check-dump,redis-cli,redis-sentinel,redis-server} $redis_install_dir/bin/
		service redis-server start
	        echo -e "You have \033[32msuccessfully\033[0m upgrade from \033[32m$Old_redis_version\033[0m to \033[32m$redis_version\033[0m"
        else
                echo -e "\033[31mUpgrade Redis failed! \033[0m"
        fi
        cd ..
fi
}
