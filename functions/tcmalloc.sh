#!/bin/bash
cd $lnmp_dir/src
. ../functions/download.sh

src_url=http://download.savannah.gnu.org/releases/libunwind/libunwind-1.1.tar.gz && Download_src
src_url=http://gperftools.googlecode.com/files/gperftools-2.1.tar.gz && Download_src

if [ `getconf WORD_BIT` == 32 ] && [ `getconf LONG_BIT` == 64 ];then
	tar xzf libunwind-1.1.tar.gz
	cd libunwind-1.1
	CFLAGS=-fPIC ./configure
	make CFLAGS=-fPIC
	make CFLAGS=-fPIC install
	cd ..
	tar xzf gperftools-2.1.tar.gz
	cd gperftools-2.1
	./configure
	make && make install
	cd ..
else
	tar xzf gperftools-2.1.tar.gz
        cd gperftools-2.1
        ./configure --enable-frame-pointers
	make && make install
	cd ..
fi
if [ -f "/usr/local/lib/libtcmalloc.so" ];then
	echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
	ldconfig
else
	echo -e "\033[31mgperftools install failed, Please contact the author! \033[0m"
	kill -9 $$
fi
cd ..
