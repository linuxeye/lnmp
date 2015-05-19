#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_tcmalloc()
{
cd $lnmp_dir/src
. ../functions/download.sh

src_url=https://googledrive.com/host/0B6NtGsLhIcf7MWxMMF9JdTN3UVk/gperftools-$tcmalloc_version.tar.gz && Download_src

tar xzf gperftools-$tcmalloc_version.tar.gz 
cd gperftools-$tcmalloc_version
./configure --enable-frame-pointers
make && make install
cd ..
/bin/rm -rf gperftools-$tcmalloc_version

if [ -f "/usr/local/lib/libtcmalloc.so" ];then
	echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
	ldconfig
else
	echo -e "\033[31mgperftools install failed, Please contact the author! \033[0m"
	kill -9 $$
fi
cd ..
}
