#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       http://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_tcmalloc() {
cd $oneinstack_dir/src
src_url=http://mirrors.linuxeye.com/oneinstack/src/gperftools-$tcmalloc_version.tar.gz && Download_src

tar xzf gperftools-$tcmalloc_version.tar.gz 
cd gperftools-$tcmalloc_version
./configure --enable-frame-pointers
make && make install

if [ -f "/usr/local/lib/libtcmalloc.so" ];then
    echo '/usr/local/lib' > /etc/ld.so.conf.d/local.conf
    ldconfig
    echo "${CSUCCESS}tcmalloc module install successfully! ${CEND}"
    cd ..
    rm -rf gperftools-$tcmalloc_version
else
    echo "${CFAILURE}tcmalloc module install failed, Please contact the author! ${CEND}"
    kill -9 $$
fi
cd ..
}
