#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       http://oneinstack.com
#       https://github.com/lj2007331/oneinstack

. ../options.conf

WebSite=$1
LogFile=$backup_dir/website.log
[ ! -e "$wwwroot_dir/$WebSite" ] && { echo "[$wwwroot_dir/$WebSite] not exist" >> $LogFile ;  exit 1 ; }

[ ! -e "$backup_dir" ] && mkdir -p $backup_dir

rsync -crazP --delete $wwwroot_dir/$WebSite $backup_dir
