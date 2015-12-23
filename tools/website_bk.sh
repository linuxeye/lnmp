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
LogFile=$backup_dir/web.log
NewFile=$backup_dir/Web_${WebSite}_$(date +%Y%m%d_%H).tgz
OldFile=$backup_dir/Web_${WebSite}_$(date +%Y%m%d --date="$expired_days days ago")*.tgz
[ ! -e "$backup_dir" ] && mkdir -p $backup_dir
[ ! -e "$wwwroot_dir/$WebSite" ] && { echo "[$wwwroot_dir/$WebSite] not exist" >> $LogFile ;  exit 1 ; }

if [ `du -sm "$wwwroot_dir/$WebSite" | awk '{print $1}'` -lt 1024 ];then
    if [ -n "`ls $OldFile 2>/dev/null`" ];then
        /bin/rm -f $OldFile
        echo "[$OldFile] Delete Old File Success" >> $LogFile
    else
        echo "[$OldFile] Delete Old Backup File" >> $LogFile
    fi
    
    if [ -e "$NewFile" ];then
        echo "[$NewFile] The Backup File is exists, Can't Backup" >> $LogFile
    else
        cd $wwwroot_dir
        tar czf $NewFile ./${WebSite} >> $LogFile 2>&1
        echo "[$NewFile] Backup success ">> $LogFile
        cd -
    fi
else
    rsync -crazP --delete $wwwroot_dir/$WebSite $backup_dir
fi
