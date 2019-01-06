#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 7+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

oneinstack_dir=$(dirname "`readlink -f $0`")
pushd ${oneinstack_dir}/tools > /dev/null
. ../options.conf
[ ! -e "${backup_dir}" ] && mkdir -p ${backup_dir}

DB_Local_BK() {
  for D in `echo ${db_name} | tr ',' ' '`
  do
    ./db_bk.sh ${D}
  done
}

DB_Remote_BK() {
  for D in `echo ${db_name} | tr ',' ' '`
  do
    ./db_bk.sh ${D}
    DB_GREP="DB_${D}_`date +%Y%m%d`"
    DB_FILE=`ls -lrt ${backup_dir} | grep ${DB_GREP} | tail -1 | awk '{print $NF}'`
    echo "file:::${backup_dir}/${DB_FILE} ${backup_dir} push" >> config_backup.txt
    echo "com:::[ -e "${backup_dir}/${DB_FILE}" ] && rm -rf ${backup_dir}/DB_${D}_$(date +%Y%m%d --date="${expired_days} days ago")_*.tgz" >> config_backup.txt
  done
}

DB_OSS_BK() {
  for D in `echo ${db_name} | tr ',' ' '`
  do
    ./db_bk.sh ${D}
    DB_GREP="DB_${D}_`date +%Y%m%d`"
    DB_FILE=`ls -lrt ${backup_dir} | grep ${DB_GREP} | tail -1 | awk '{print $NF}'`
    /usr/local/bin/ossutil cp -f ${backup_dir}/${DB_FILE} oss://${oss_bucket}/`date +%F`/${DB_FILE}
    [ $? -eq 0 ] && /usr/local/bin/ossutil rm -rf oss://${oss_bucket}/`date +%F --date="${expired_days} days ago"`/
  done
}

DB_COS_BK() {
  for D in `echo ${db_name} | tr ',' ' '`
  do
    ./db_bk.sh ${D}
    DB_GREP="DB_${D}_`date +%Y%m%d`"
    DB_FILE=`ls -lrt ${backup_dir} | grep ${DB_GREP} | tail -1 | awk '{print $NF}'`
    ${python_install_dir}/bin/coscmd upload ${backup_dir}/${DB_FILE} /`date +%F`/${DB_FILE}
    [ $? -eq 0 ] && ${python_install_dir}/bin/coscmd delete -r -f `date +%F --date="${expired_days} days ago"` > /dev/null 2>&1
  done
}

DB_UPYUN_BK() {
  for D in `echo ${db_name} | tr ',' ' '`
  do
    ./db_bk.sh ${D}
    DB_GREP="DB_${D}_`date +%Y%m%d`"
    DB_FILE=`ls -lrt ${backup_dir} | grep ${DB_GREP} | tail -1 | awk '{print $NF}'`
    /usr/local/bin/upx put ${backup_dir}/${DB_FILE} /`date +%F`/${DB_FILE}
    [ $? -eq 0 ] && /usr/local/bin/upx rm -a `date +%F --date="${expired_days} days ago"` > /dev/null 2>&1
  done
}

DB_QINIU_BK() {
  for D in `echo ${db_name} | tr ',' ' '`
  do
    ./db_bk.sh ${D}
    DB_GREP="DB_${D}_`date +%Y%m%d`"
    DB_FILE=`ls -lrt ${backup_dir} | grep ${DB_GREP} | tail -1 | awk '{print $NF}'`
    /usr/local/bin/qshell rput ${qiniu_bucket} /`date +%F`/${DB_FILE} ${backup_dir}/${DB_FILE}
    if [ $? -eq 0 ]; then
      /usr/local/bin/qshell listbucket ${qiniu_bucket} /`date +%F --date="${expired_days} days ago"` /tmp/qiniu.txt > /dev/null 2>&1
      /usr/local/bin/qshell batchdelete -force ${qiniu_bucket} /tmp/qiniu.txt > /dev/null 2>&1
      rm -f /tmp/qiniu.txt
    fi
  done
}

DB_GDRIVE_BK() {
  for D in `echo ${db_name} | tr ',' ' '`
  do
    ./db_bk.sh ${D}
    DB_GREP="DB_${D}_`date +%Y%m%d`"
    DB_FILE=`ls -lrt ${backup_dir} | grep ${DB_GREP} | tail -1 | awk '{print $NF}'`
    Parent_id=$(/usr/local/bin/gdrive list --no-header -q "name = '`date +%F`'" | awk '{print $1}')
    [ -z ${Parent_id} ] && Parent_id=$(/usr/local/bin/gdrive mkdir `date +%F` | awk '{print $2}')
    /usr/local/bin/gdrive upload -p ${Parent_id} ${backup_dir}/${DB_FILE}
    if [ $? -eq 0 ]; then
      Parent_id=$(/usr/local/bin/gdrive list --no-header -q "name = '`date +%F --date="${expired_days} days ago"`'" | awk '{print $1}')
      [ -n ${Parent_id} ] && /usr/local/bin/gdrive delete -r -p ${Parent_id} > /dev/null 2>&1
    fi
  done
}

WEB_LOCAL_BK() {
  for W in `echo ${website_name} | tr ',' ' '`
  do
    ./website_bk.sh $W
  done
}

WEB_Remote_BK() {
  for W in `echo ${website_name} | tr ',' ' '`
  do
    if [ `du -sm "${wwwroot_dir}/${WebSite}" | awk '{print $1}'` -lt 2048 ]; then
      ./website_bk.sh $W
      Web_GREP="Web_${W}_`date +%Y%m%d`"
      Web_FILE=`ls -lrt ${backup_dir} | grep ${Web_GREP} | tail -1 | awk '{print $NF}'`
      echo "file:::${backup_dir}/${Web_FILE} ${backup_dir} push" >> config_backup.txt
      echo "com:::[ -e "${backup_dir}/${Web_FILE}" ] && rm -rf ${backup_dir}/Web_${W}_$(date +%Y%m%d --date="${expired_days} days ago")_*.tgz" >> config_backup.txt
    else
      echo "file:::${wwwroot_dir}/$W ${backup_dir} push" >> config_backup.txt
    fi
  done
}

WEB_OSS_BK() {
  for W in `echo $website_name | tr ',' ' '`
  do
    [ ! -e "${wwwroot_dir}/${WebSite}" ] && { echo "[${wwwroot_dir}/${WebSite}] not exist"; break; }
    PUSH_FILE="${backup_dir}/Web_${W}_$(date +%Y%m%d_%H).tgz"
    if [ ! -e "${PUSH_FILE}" ]; then
      pushd ${wwwroot_dir} > /dev/null
      tar czf ${PUSH_FILE} ./$W
      popd > /dev/null
    fi
    /usr/local/bin/ossutil cp -f ${PUSH_FILE} oss://${oss_bucket}/`date +%F`/${PUSH_FILE##*/}
    [ $? -eq 0 ] && { [ -e "${PUSH_FILE}" ] && rm -rf ${PUSH_FILE}; /usr/local/bin/ossutil rm -rf oss://${oss_bucket}/`date +%F --date="${expired_days} days ago"`/; }
  done
}

WEB_COS_BK() {
  for W in `echo ${website_name} | tr ',' ' '`
  do
    [ ! -e "${wwwroot_dir}/${WebSite}" ] && { echo "[${wwwroot_dir}/${WebSite}] not exist"; break; }
    PUSH_FILE="${backup_dir}/Web_${W}_$(date +%Y%m%d_%H).tgz"
    if [ ! -e "${PUSH_FILE}" ]; then
      pushd ${wwwroot_dir} > /dev/null
      tar czf ${PUSH_FILE} ./$W
      popd > /dev/null
    fi
    ${python_install_dir}/bin/coscmd upload ${PUSH_FILE} /`date +%F`/${PUSH_FILE##*/}
    if [ $? -eq 0 ]; then
      ${python_install_dir}/bin/coscmd delete -r -f `date +%F --date="${expired_days} days ago"` > /dev/null 2>&1
      [ -e "${PUSH_FILE}" -a -z "`echo ${backup_destination} | grep -ow 'local'`" ] && rm -rf ${PUSH_FILE}
    fi
  done
}

WEB_UPYUN_BK() {
  for W in `echo ${website_name} | tr ',' ' '`
  do
    [ ! -e "${wwwroot_dir}/${WebSite}" ] && { echo "[${wwwroot_dir}/${WebSite}] not exist"; break; }
    [ ! -e "${backup_dir}" ] && mkdir -p ${backup_dir}
    PUSH_FILE="${backup_dir}/Web_${W}_$(date +%Y%m%d_%H).tgz"
    if [ ! -e "${PUSH_FILE}" ]; then
      pushd ${wwwroot_dir} > /dev/null
      tar czf ${PUSH_FILE} ./$W
      popd > /dev/null
    fi
    /usr/local/bin/upx put ${PUSH_FILE} /`date +%F`/${PUSH_FILE##*/}
    if [ $? -eq 0 ]; then
      /usr/local/bin/upx rm -a `date +%F --date="${expired_days} days ago"` > /dev/null 2>&1
      [ -e "${PUSH_FILE}" -a -z "`echo ${backup_destination} | grep -ow 'local'`" ] && rm -rf ${PUSH_FILE}
    fi
  done
}

WEB_QINIU_BK() {
  for W in `echo ${website_name} | tr ',' ' '`
  do
    [ ! -e "${wwwroot_dir}/${WebSite}" ] && { echo "[${wwwroot_dir}/${WebSite}] not exist"; break; }
    [ ! -e "${backup_dir}" ] && mkdir -p ${backup_dir}
    PUSH_FILE="${backup_dir}/Web_${W}_$(date +%Y%m%d_%H).tgz"
    if [ ! -e "${PUSH_FILE}" ]; then
      pushd ${wwwroot_dir} > /dev/null
      tar czf ${PUSH_FILE} ./$W
      popd > /dev/null
    fi
    /usr/local/bin/qshell rput ${qiniu_bucket} /`date +%F`/${PUSH_FILE##*/} ${PUSH_FILE}
    if [ $? -eq 0 ]; then
      /usr/local/bin/qshell listbucket ${qiniu_bucket} /`date +%F --date="${expired_days} days ago"` /tmp/qiniu.txt > /dev/null 2>&1
      /usr/local/bin/qshell batchdelete -force ${qiniu_bucket} /tmp/qiniu.txt > /dev/null 2>&1
      rm -f /tmp/qiniu.txt
    fi
  done
}

WEB_GDRIVE_BK() {
  for W in `echo ${website_name} | tr ',' ' '`
  do
    [ ! -e "${wwwroot_dir}/${WebSite}" ] && { echo "[${wwwroot_dir}/${WebSite}] not exist"; break; }
    [ ! -e "${backup_dir}" ] && mkdir -p ${backup_dir}
    PUSH_FILE="${backup_dir}/Web_${W}_$(date +%Y%m%d_%H).tgz"
    if [ ! -e "${PUSH_FILE}" ]; then
      pushd ${wwwroot_dir} > /dev/null
      tar czf ${PUSH_FILE} ./$W
      popd > /dev/null
    fi
    Parent_id=$(/usr/local/bin/gdrive list --no-header -q "name = '`date +%F`'" | awk '{print $1}')
    [ -z ${Parent_id} ] && Parent_id=$(/usr/local/bin/gdrive mkdir `date +%F` | awk '{print $2}')
    /usr/local/bin/gdrive upload -p ${Parent_id} ${PUSH_FILE}
    if [ $? -eq 0 ]; then
      Parent_id=$(/usr/local/bin/gdrive list --no-header -q "name = '`date +%F --date="${expired_days} days ago"`'" | awk '{print $1}')
      [ -n ${Parent_id} ] && /usr/local/bin/gdrive delete -r -p ${Parent_id} > /dev/null 2>&1
    fi
  done
}

for DEST in `echo ${backup_destination} | tr ',' ' '`
do
  if [ "${DEST}" == 'local' ]; then
    [ -n "`echo ${backup_content} | grep -ow db`" ] && DB_Local_BK
    [ -n "`echo ${backup_content} | grep -ow web`" ] && WEB_LOCAL_BK
  fi
  if [ "${DEST}" == 'remote' ]; then
    echo "com:::[ ! -e "${backup_dir}" ] && mkdir -p ${backup_dir}" > config_backup.txt
    [ -n "`echo ${backup_content} | grep -ow db`" ] && DB_Remote_BK
    [ -n "`echo ${backup_content} | grep -ow web`" ] && WEB_Remote_BK
    ./mabs.sh -c config_backup.txt -T -1 | tee -a mabs.log
  fi
  if [ "${DEST}" == 'oss' ]; then
    [ -n "`echo ${backup_content} | grep -ow db`" ] && DB_OSS_BK
    [ -n "`echo ${backup_content} | grep -ow web`" ] && WEB_OSS_BK
  fi
  if [ "${DEST}" == 'cos' ]; then
    [ -n "`echo ${backup_content} | grep -ow db`" ] && DB_COS_BK
    [ -n "`echo ${backup_content} | grep -ow web`" ] && WEB_COS_BK
  fi
  if [ "${DEST}" == 'upyun' ]; then
    [ -n "`echo ${backup_content} | grep -ow db`" ] && DB_UPYUN_BK
    [ -n "`echo ${backup_content} | grep -ow web`" ] && WEB_UPYUN_BK
  fi
  if [ "${DEST}" == 'qiniu' ]; then
    [ -n "`echo ${backup_content} | grep -ow db`" ] && DB_QINIU_BK
    [ -n "`echo ${backup_content} | grep -ow web`" ] && WEB_QINIU_BK
  fi
  if [ "${DEST}" == 'gdrive' ]; then
    [ -n "`echo ${backup_content} | grep -ow db`" ] && WEB_GDRIVE_BK
    [ -n "`echo ${backup_content} | grep -ow web`" ] && WEB_GDRIVE_BK
  fi
done
