#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

. ../options.conf

DBname=$1
LogFile=$backup_dir/db.log
DumpFile=$backup_dir/DB_${DBname}_$(date +%Y%m%d).sql
NewFile=$backup_dir/DB_${DBname}_$(date +%Y%m%d).tgz
OldFile=$backup_dir/DB_${DBname}_$(date +%Y%m%d --date="$expired_days days ago").tgz

[ ! -e "$backup_dir" ] && mkdir -p $backup_dir

DB_tmp=`$db_install_dir/bin/mysql -uroot -p$dbrootpwd -e "show databases\G" | grep $DBname`
[ -z "$DB_tmp" ] && { echo "[$DBname] not exist" >> $LogFile ;  exit 1 ; }

if [ -f $OldFile ];then
	rm -f $OldFile
        echo "[$OldFile] Delete Old File Success" >> $LogFile
else
        echo "[$OldFile] Delete Old Backup File" >> $LogFile
fi

if [ -f $NewFile ];then
        echo "[$NewFile] The Backup File is exists,Can't Backup" >> $LogFile
else
	$db_install_dir/bin/mysqldump -uroot -p$dbrootpwd --opt --databases $DBname > $DumpFile 
	cd $backup_dir
        tar czf $NewFile ${DumpFile##*/} >> $LogFile 2>&1
        echo "[$NewFile] Backup success ">> $LogFile
        /bin/rm -f $DumpFile
fi
