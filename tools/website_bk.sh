#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

. ../options.conf

WebSite=$1
LogFile=$backup_dir/website.log
[ ! -e "$home_dir/$WebSite" ] && { echo "[$home_dir/$WebSite] not exist" >> $LogFile ;  exit 1 ; }

[ ! -e "$backup_dir" ] && mkdir -p $backup_dir

rsync -crazP --delete $home_dir/$WebSite $backup_dir
