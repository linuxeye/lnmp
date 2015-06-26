#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

. ../options.conf

WebSite=$1
LogFile=$backup_dir/website.log
[ ! -e "$wwwroot_dir/$WebSite" ] && { echo "[$wwwroot_dir/$WebSite] not exist" >> $LogFile ;  exit 1 ; }

[ ! -e "$backup_dir" ] && mkdir -p $backup_dir

rsync -crazP --delete $wwwroot_dir/$WebSite $backup_dir
