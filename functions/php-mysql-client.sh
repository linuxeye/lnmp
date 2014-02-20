#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_PHP-MySQL-Client()
{
cd $lnmp_dir/src
. ../functions/download.sh 
. ../options.conf

src_url=http://www.cmake.org/files/v2.8/cmake-2.8.12.2.tar.gz && Download_src 
src_url=http://cdn.mysql.com/Downloads/MySQL-5.5/mysql-5.5.36.tar.gz && Download_src

if [ ! -e "`which cmake`" ];then
        tar xzf cmake-2.8.12.2.tar.gz
        cd cmake-2.8.12.2
        CFLAGS= CXXFLAGS= ./configure
        make && make install
        cd ..
fi

tar zxf mysql-5.5.36.tar.gz
cd mysql-5.5.36
cmake . -DCMAKE_INSTALL_PREFIX=$mysql_install_dir
make mysqlclient libmysql 
mkdir -p $mysql_install_dir/{lib,bin}
/bin/cp libmysql/libmysqlclient* $mysql_install_dir/lib
/bin/cp scripts/mysql_config $mysql_install_dir/bin
/bin/cp -R include $mysql_install_dir
cd ../../
}
