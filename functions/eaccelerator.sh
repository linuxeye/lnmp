#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

Install_Redis()
{
cd $lnmp_dir/src
. ../functions/download.sh
. ../functions/check_os.sh
. ../options.conf

src_url=https://github.com/downloads/eaccelerator/eaccelerator/eaccelerator-0.9.6.1.tar.bz2 && Download_src
}
