#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 7+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

pushd tools > /dev/null
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

DB_COS_BK() {
  for D in `echo $db_name | tr ',' ' '`
  do
    ./db_bk.sh $D
    DB_GREP="DB_${D}_`date +%Y`"
    DB_FILE=`ls -lrt $backup_dir | grep ${DB_GREP} | tail -1 | awk '{print $NF}'`
    ${python_install_dir}/bin/coscmd upload $backup_dir/$DB_FILE /`date +%F`/$DB_FILE
    [ $? -eq 0 ] && ${python_install_dir}/bin/coscmd delete -r `date +%F --date="$expired_days days ago"` > /dev/null 2>&1
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
    if [ `du -sm "$wwwroot_dir/$WebSite" | awk '{print $1}'` -lt 1024 ];then
      ./website_bk.sh $W
      Web_GREP="Web_${W}_`date +%Y`"
      Web_FILE=`ls -lrt $backup_dir | grep ${Web_GREP} | tail -1 | awk '{print $NF}'`
      echo "file:::$backup_dir/$Web_FILE $backup_dir push" >> config_bakcup.txt
      echo "com:::[ -e "$backup_dir/$Web_FILE" ] && rm -rf $backup_dir/Web_${W}_$(date +%Y%m%d --date="$expired_days days ago")_*.tgz" >> config_bakcup.txt
    else
      echo "file:::$wwwroot_dir/$W $backup_dir push" >> config_bakcup.txt
    fi
  done
}

WEB_COS_BK() {
  for W in `echo $website_name | tr ',' ' '`
  do
    [ ! -e "$wwwroot_dir/$WebSite" ] && { echo "[$wwwroot_dir/$WebSite] not exist"; break; }
    PUSH_FILE="$backup_dir/Web_${W}_$(date +%Y%m%d_%H).tgz"
    if [ ! -e "$PUSH_FILE" ]; then
      pushd $wwwroot_dir
      tar czf $PUSH_FILE ./$W
      popd
    fi
    ${python_install_dir}/bin/coscmd upload $PUSH_FILE /`date +%F`/Web_${W}_$(date +%Y%m%d_%H).tgz
    [ $? -eq 0 ] && { [ -e "$PUSH_FILE" ] && rm -rf $PUSH_FILE; ${python_install_dir}/bin/coscmd delete -r `date +%F --date="$expired_days days ago"` > /dev/null 2>&1; }
  done
}

if [ "$backup_destination" == 'local' ]; then
  [ -n "`echo $backup_content | grep -ow db`" ] && DB_Local_BK
  [ -n "`echo $backup_content | grep -ow web`" ] && WEB_Local_BK
elif [ "$backup_destination" == 'remote' ]; then
  echo "com:::[ ! -e "$backup_dir" ] && mkdir -p $backup_dir" > config_bakcup.txt
  [ -n "`echo $backup_content | grep -ow db`" ] && DB_Remote_BK
  [ -n "`echo $backup_content | grep -ow web`" ] && WEB_Remote_BK
  ./mabs.sh -c config_bakcup.txt -T -1 | tee mabs.log
elif [ "$backup_destination" == 'cos' ]; then
  [ -n "`echo $backup_content | grep -ow db`" ] && DB_COS_BK
  [ -n "`echo $backup_content | grep -ow web`" ] && WEB_COS_BK
elif [ "$backup_destination" == 'local,remote' ]; then
  echo "com:::[ ! -e "$backup_dir" ] && mkdir -p $backup_dir" > config_bakcup.txt
  [ -n "`echo $backup_content | grep -ow db`" ] && DB_Local_BK
  [ -n "`echo $backup_content | grep -ow web`" ] && WEB_Local_BK
  [ -n "`echo $backup_content | grep -ow db`" ] && DB_Remote_BK
  [ -n "`echo $backup_content | grep -ow web`" ] && WEB_Remote_BK
  ./mabs.sh -c config_bakcup.txt -T -1 | tee mabs.log	
elif [ "$backup_destination" == 'local,cos' ]; then
  [ -n "`echo $backup_content | grep -ow db`" ] && DB_Local_BK
  [ -n "`echo $backup_content | grep -ow db`" ] && DB_COS_BK
  [ -n "`echo $backup_content | grep -ow web`" ] && WEB_Local_BK
  [ -n "`echo $backup_content | grep -ow web`" ] && WEB_COS_BK
elif [ "$backup_destination" == 'remote,cos' ]; then
  echo "com:::[ ! -e "$backup_dir" ] && mkdir -p $backup_dir" > config_bakcup.txt
  [ -n "`echo $backup_content | grep -ow db`" ] && DB_Remote_BK 
  [ -n "`echo $backup_content | grep -ow db`" ] && DB_COS_BK
  [ -n "`echo $backup_content | grep -ow web`" ] && WEB_Remote_BK 
  [ -n "`echo $backup_content | grep -ow web`" ] && WEB_COS_BK
  ./mabs.sh -c config_bakcup.txt -T -1 | tee mabs.log	
fi
