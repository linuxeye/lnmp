#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
#

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

current_dir=$(dirname "`readlink -f $0`")
pushd ${current_dir}/tools > /dev/null
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
    ossutil cp -f ${backup_dir}/${DB_FILE} oss://${oss_bucket}/`date +%F`/${DB_FILE}
    if [ $? -eq 0 ]; then
      ossutil rm -rf oss://${oss_bucket}/`date +%F --date="${expired_days} days ago"`/
      [ -z "`echo ${backup_destination} | grep -ow 'local'`" ] && rm -f ${backup_dir}/${DB_FILE}
    fi
  done
}

DB_COS_BK() {
  for D in `echo ${db_name} | tr ',' ' '`
  do
    ./db_bk.sh ${D}
    DB_GREP="DB_${D}_`date +%Y%m%d`"
    DB_FILE=`ls -lrt ${backup_dir} | grep ${DB_GREP} | tail -1 | awk '{print $NF}'`
    coscli sync ${backup_dir}/${DB_FILE} cos://${cos_bucket}/`date +%F`/${DB_FILE}
    if [ $? -eq 0 ]; then
      coscli rm -rf cos://${cos_bucket}/`date +%F --date="${expired_days} days ago"` > /dev/null 2>&1
      [ -z "`echo ${backup_destination} | grep -ow 'local'`" ] && rm -f ${backup_dir}/${DB_FILE}
    fi
  done
}

DB_UPYUN_BK() {
  for D in `echo ${db_name} | tr ',' ' '`
  do
    ./db_bk.sh ${D}
    DB_GREP="DB_${D}_`date +%Y%m%d`"
    DB_FILE=`ls -lrt ${backup_dir} | grep ${DB_GREP} | tail -1 | awk '{print $NF}'`
    upx put ${backup_dir}/${DB_FILE} /`date +%F`/${DB_FILE}
    if [ $? -eq 0 ]; then
      upx rm -a `date +%F --date="${expired_days} days ago"` > /dev/null 2>&1
      [ -z "`echo ${backup_destination} | grep -ow 'local'`" ] && rm -f ${backup_dir}/${DB_FILE}
    fi
  done
}

DB_QINIU_BK() {
  for D in `echo ${db_name} | tr ',' ' '`
  do
    ./db_bk.sh ${D}
    DB_GREP="DB_${D}_`date +%Y%m%d`"
    DB_FILE=`ls -lrt ${backup_dir} | grep ${DB_GREP} | tail -1 | awk '{print $NF}'`
    qshell rput ${qiniu_bucket} /`date +%F`/${DB_FILE} ${backup_dir}/${DB_FILE}
    if [ $? -eq 0 ]; then
      qshell listbucket ${qiniu_bucket} /`date +%F --date="${expired_days} days ago"` /tmp/qiniu.txt > /dev/null 2>&1
      qshell batchdelete -force ${qiniu_bucket} /tmp/qiniu.txt > /dev/null 2>&1
      [ -z "`echo ${backup_destination} | grep -ow 'local'`" ] && rm -f ${backup_dir}/${DB_FILE}
      rm -f /tmp/qiniu.txt
    fi
  done
}

DB_S3_BK() {
  for D in `echo ${db_name} | tr ',' ' '`
  do
    ./db_bk.sh ${D}
    DB_GREP="DB_${D}_`date +%Y%m%d`"
    DB_FILE=`ls -lrt ${backup_dir} | grep ${DB_GREP} | tail -1 | awk '{print $NF}'`
    aws s3 sync ${backup_dir}/${DB_FILE} s3://${s3_bucket}/`date +%F`/${DB_FILE}
    if [ $? -eq 0 ]; then
      aws s3 rm -r s3://${s3_bucket}/`date +%F --date="${expired_days} days ago"` > /dev/null 2>&1
      [ -z "`echo ${backup_destination} | grep -ow 'local'`" ] && rm -f ${backup_dir}/${DB_FILE}
    fi
  done
}

# DigitalOcean Spaces (S3-compatible, cp mode)
DB_DOSPACE_BK() {
  local PROFILE ENDPOINT BUCKET
  PROFILE="${do_space_profile:-dospace}"
  ENDPOINT="${do_space_endpoint}"
  BUCKET="${do_space_bucket}"
  for D in `echo ${db_name} | tr ',' ' '`
  do
    ./db_bk.sh ${D}
    DB_GREP="DB_${D}_\`date +%Y%m%d\`"
    DB_FILE=\`ls -lrt \${backup_dir} | grep \${DB_GREP} | tail -1 | awk '{print \$NF}'\`
    aws --profile "\${PROFILE}" --endpoint-url "\${ENDPOINT}" s3 cp "\${backup_dir}/\${DB_FILE}" "s3://\${BUCKET}/\`date +%F\`/\${DB_FILE}"
    if [ \$? -eq 0 ]; then
      aws --profile "\${PROFILE}" --endpoint-url "\${ENDPOINT}" s3 rm -r "s3://\${BUCKET}/\`date +%F --date=\"\${expired_days} days ago\"\`" > /dev/null 2>&1
      [ -z "\`echo \${backup_destination} | grep -ow 'local'\`" ] && rm -f "\${backup_dir}/\${DB_FILE}"
    fi
  done
}

DB_DROPBOX_BK() {
  for D in `echo ${db_name} | tr ',' ' '`
  do
    ./db_bk.sh ${D}
    DB_GREP="DB_${D}_`date +%Y%m%d`"
    DB_FILE=`ls -lrt ${backup_dir} | grep ${DB_GREP} | tail -1 | awk '{print $NF}'`
    dbxcli put ${backup_dir}/${DB_FILE} `date +%F`/${DB_FILE}
    if [ $? -eq 0 ]; then
      dbxcli rm -f `date +%F --date="${expired_days} days ago"` > /dev/null 2>&1
      [ -z "`echo ${backup_destination} | grep -ow 'local'`" ] && rm -f ${backup_dir}/${DB_FILE}
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
    ossutil cp -f ${PUSH_FILE} oss://${oss_bucket}/`date +%F`/${PUSH_FILE##*/}
    if [ $? -eq 0 ]; then
      ossutil rm -rf oss://${oss_bucket}/`date +%F --date="${expired_days} days ago"`/
      [ -z "`echo ${backup_destination} | grep -ow 'local'`" ] && rm -f ${PUSH_FILE}
    fi
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
    coscli sync ${PUSH_FILE} cos://${cos_bucket}/`date +%F`/${PUSH_FILE##*/}
    if [ $? -eq 0 ]; then
      coscli rm -rf cos://${cos_bucket}/`date +%F --date="${expired_days} days ago"` > /dev/null 2>&1
      [ -z "`echo ${backup_destination} | grep -ow 'local'`" ] && rm -f ${PUSH_FILE}
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
    upx put ${PUSH_FILE} /`date +%F`/${PUSH_FILE##*/}
    if [ $? -eq 0 ]; then
      upx rm -a `date +%F --date="${expired_days} days ago"` > /dev/null 2>&1
      [ -z "`echo ${backup_destination} | grep -ow 'local'`" ] && rm -f ${PUSH_FILE}
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
    qshell rput ${qiniu_bucket} /`date +%F`/${PUSH_FILE##*/} ${PUSH_FILE}
    if [ $? -eq 0 ]; then
      qshell listbucket ${qiniu_bucket} /`date +%F --date="${expired_days} days ago"` /tmp/qiniu.txt > /dev/null 2>&1
      qshell batchdelete -force ${qiniu_bucket} /tmp/qiniu.txt > /dev/null 2>&1
      [ -z "`echo ${backup_destination} | grep -ow 'local'`" ] && rm -f ${PUSH_FILE}
      rm -f /tmp/qiniu.txt
    fi
  done
}

WEB_S3_BK() {
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
    aws s3 sync ${PUSH_FILE} s3://${s3_bucket}/`date +%F`/${PUSH_FILE##*/}
    if [ $? -eq 0 ]; then
      aws s3 rm -r s3://${s3_bucket}/`date +%F --date="${expired_days} days ago"` > /dev/null 2>&1
      [ -z "`echo ${backup_destination} | grep -ow 'local'`" ] && rm -f ${PUSH_FILE}
    fi
  done
}

WEB_DOSPACE_BK() {
  local PROFILE ENDPOINT BUCKET
  PROFILE="${do_space_profile:-dospace}"
  ENDPOINT="${do_space_endpoint}"
  BUCKET="${do_space_bucket}"
  for W in `echo ${website_name} | tr ',' ' '`
  do
    [ ! -e "${wwwroot_dir}/${WebSite}" ] && { echo "[${wwwroot_dir}/${WebSite}] not exist"; break; }
    [ ! -e "${backup_dir}" ] && mkdir -p "${backup_dir}"
    PUSH_FILE="${backup_dir}/Web_${W}_$(date +%Y%m%d_%H).tgz"
    if [ ! -e "${PUSH_FILE}" ]; then
      pushd "${wwwroot_dir}" > /dev/null
      tar czf "${PUSH_FILE}" ./"$W"
      popd > /dev/null
    fi
    aws --profile "${PROFILE}" --endpoint-url "${ENDPOINT}" s3 cp "${PUSH_FILE}" "s3://${BUCKET}/`date +%F`/${PUSH_FILE##*/}"
    if [ $? -eq 0 ]; then
      aws --profile "${PROFILE}" --endpoint-url "${ENDPOINT}" s3 rm -r "s3://${BUCKET}/`date +%F --date="${expired_days} days ago"`" > /dev/null 2>&1
      [ -z "`echo ${backup_destination} | grep -ow 'local'`" ] && rm -f "${PUSH_FILE}"
    fi
  done
}

WEB_DROPBOX_BK() {
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
    dbxcli put ${PUSH_FILE} `date +%F`/${PUSH_FILE##*/}
    if [ $? -eq 0 ]; then
      dbxcli rm -f `date +%F --date="${expired_days} days ago"` > /dev/null 2>&1
      [ -z "`echo ${backup_destination} | grep -ow 'local'`" ] && rm -f ${PUSH_FILE}
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
  if [ "${DEST}" == 's3' ]; then
    [ -n "`echo ${backup_content} | grep -ow db`" ] && DB_S3_BK
    [ -n "`echo ${backup_content} | grep -ow web`" ] && WEB_S3_BK
  fi
  if [ "${DEST}" == 'dospace' ]; then
    [ -n "`echo ${backup_content} | grep -ow db`" ] && DB_DOSPACE_BK
    [ -n "`echo ${backup_content} | grep -ow web`" ] && WEB_DOSPACE_BK
  fi
  if [ "${DEST}" == 'dropbox' ]; then
    [ -n "`echo ${backup_content} | grep -ow db`" ] && DB_DROPBOX_BK
    [ -n "`echo ${backup_content} | grep -ow web`" ] && WEB_DROPBOX_BK
  fi
done