#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       http://oneinstack.com
#       https://github.com/lj2007331/oneinstack

cd tools
. ../options.conf

DB_Local_BK() {
    for D in `echo $db_name | tr ',' ' '`
    do
        ./db_bk.sh $D
    done
}

DB_Remote_BK() {
    for D in `echo $db_name | tr ',' ' '`
    do
        ./db_bk.sh $D
        DB_GREP="DB_${D}_`date +%Y`"
        DB_FILE=`ls -lrt $backup_dir | grep ${DB_GREP} | tail -1 | awk '{print $NF}'`
        echo "file:::$backup_dir/$DB_FILE $backup_dir push" >> config_bakcup.txt
        echo "com:::[ -e "$backup_dir/$DB_FILE" ] && rm -rf $backup_dir/DB_${D}_$(date +%Y%m%d --date="$expired_days days ago")_*.tgz" >> config_bakcup.txt
    done
}

WEB_Local_BK() {
    for W in `echo $website_name | tr ',' ' '`
    do
        ./website_bk.sh $W
    done
}

WEB_Remote_BK() {
    for W in `echo $website_name | tr ',' ' '`
    do
        echo "file:::$wwwroot_dir/$W $backup_dir push" >> config_bakcup.txt
    done
}

if [ "$local_bankup_yn" == 'y' -a "$remote_bankup_yn" == 'n' ];then
    WEB_Local_BK
    DB_Local_BK
elif [ "$local_bankup_yn" == 'n' -a "$remote_bankup_yn" == 'y' ];then
    echo "com:::[ ! -e "$backup_dir" ] && mkdir -p $backup_dir" > config_bakcup.txt
    DB_Remote_BK
    WEB_Remote_BK
    ./mabs.sh -c config_bakcup.txt -T -1 | tee mabs.log
elif [ "$local_bankup_yn" == 'y' -a "$remote_bankup_yn" == 'y' ];then
    echo "com:::[ ! -e "$backup_dir" ] && mkdir -p $backup_dir" > config_bakcup.txt
    WEB_Local_BK
    WEB_Remote_BK
    DB_Local_BK
    DB_Remote_BK
    ./mabs.sh -c config_bakcup.txt -T -1 | tee mabs.log	
fi
