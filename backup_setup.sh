#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
clear
printf "
#######################################################################
#       OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+      #
#                     Setup the backup parameters                     #
#       For more information please visit https://oneinstack.com      #
#######################################################################
"
# Check if user is root
[ $(id -u) != "0" ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

oneinstack_dir=$(dirname "`readlink -f $0`")
pushd ${oneinstack_dir} > /dev/null
. ./options.conf
. ./versions.txt
. ./include/color.sh
. ./include/check_os.sh
. ./include/check_dir.sh
. ./include/download.sh
. ./include/python.sh

while :; do echo
  echo 'Please select your backup destination:'
  echo -e "\t${CMSG}1${CEND}. Localhost"
  echo -e "\t${CMSG}2${CEND}. Remote host"
  echo -e "\t${CMSG}3${CEND}. Aliyun OSS"
  echo -e "\t${CMSG}4${CEND}. Qcloud COS"
  echo -e "\t${CMSG}5${CEND}. UPYUN"
  echo -e "\t${CMSG}6${CEND}. QINIU"
  echo -e "\t${CMSG}7${CEND}. Amazon S3"
  echo -e "\t${CMSG}8${CEND}. Dropbox"
  read -e -p "Please input numbers:(Default 1 press Enter) " desc_bk
  desc_bk=${desc_bk:-'1'}
  array_desc=(${desc_bk})
  array_all=(1 2 3 4 5 6 7 8)
  for v in ${array_desc[@]}
  do
    [ -z "`echo ${array_all[@]} | grep -w ${v}`" ] && desc_flag=1
  done
  if [ "${desc_flag}" == '1' ]; then
    unset desc_flag
    echo; echo "${CWARNING}input error! Please only input number 1 3 4 and so on${CEND}"; echo
    continue
  else
    sed -i 's@^backup_destination=.*@backup_destination=@' ./options.conf
    break
  fi
done

[ -n "`echo ${desc_bk} | grep -w 1`" ] && sed -i 's@^backup_destination=.*@backup_destination=local@' ./options.conf
[ -n "`echo ${desc_bk} | grep -w 2`" ] && sed -i 's@^backup_destination=.*@&,remote@' ./options.conf
[ -n "`echo ${desc_bk} | grep -w 3`" ] && sed -i 's@^backup_destination=.*@&,oss@' ./options.conf
[ -n "`echo ${desc_bk} | grep -w 4`" ] && sed -i 's@^backup_destination=.*@&,cos@' ./options.conf
[ -n "`echo ${desc_bk} | grep -w 5`" ] && sed -i 's@^backup_destination=.*@&,upyun@' ./options.conf
[ -n "`echo ${desc_bk} | grep -w 6`" ] && sed -i 's@^backup_destination=.*@&,qiniu@' ./options.conf
[ -n "`echo ${desc_bk} | grep -w 7`" ] && sed -i 's@^backup_destination=.*@&,s3@' ./options.conf
[ -n "`echo ${desc_bk} | grep -w 8`" ] && sed -i 's@^backup_destination=.*@&,dropbox@' ./options.conf
sed -i 's@^backup_destination=,@backup_destination=@' ./options.conf

while :; do echo
  echo 'Please select your backup content:'
  echo -e "\t${CMSG}1${CEND}. Only Database"
  echo -e "\t${CMSG}2${CEND}. Only Website"
  echo -e "\t${CMSG}3${CEND}. Database and Website"
  read -e -p "Please input a number:(Default 1 press Enter) " content_bk
  content_bk=${content_bk:-1}
  if [[ ! ${content_bk} =~ ^[1-3]$ ]]; then
    echo "${CWARNING}input error! Please only input number 1~3${CEND}"
  else
    break
  fi
done

[ "${content_bk}" == '1' ] && sed -i 's@^backup_content=.*@backup_content=db@' ./options.conf
[ "${content_bk}" == '2' ] && sed -i 's@^backup_content=.*@backup_content=web@' ./options.conf
[ "${content_bk}" == '3' ] && sed -i 's@^backup_content=.*@backup_content=db,web@' ./options.conf

if [ -n "`echo ${desc_bk} | grep -Ew '1|2'`" ]; then
  while :; do echo
    echo "Please enter the directory for save the backup file: "
    read -e -p "(Default directory: ${backup_dir}): " new_backup_dir
    new_backup_dir=${new_backup_dir:-${backup_dir}}
    if [ -z "`echo ${new_backup_dir}| grep '^/'`" ]; then
      echo "${CWARNING}input error! ${CEND}"
    else
      break
    fi
  done
  sed -i "s@^backup_dir=.*@backup_dir=${new_backup_dir}@" ./options.conf
fi

while :; do echo
  echo "Please enter a valid backup number of days: "
  read -e -p "(Default days: 5): " expired_days
  expired_days=${expired_days:-5}
  [ -n "`echo ${expired_days} | sed -n "/^[0-9]\+$/p"`" ] && break || echo "${CWARNING}input error! Please only enter numbers! ${CEND}"
done
sed -i "s@^expired_days=.*@expired_days=${expired_days}@" ./options.conf

if [ "${content_bk}" != '2' ]; then
  databases=`${db_install_dir}/bin/mysql -uroot -p$dbrootpwd -e "show databases\G" | grep Database | awk '{print $2}' | grep -Evw "(performance_schema|information_schema|mysql|sys)"`
  while :; do echo
    echo "Please enter one or more name for database, separate multiple database names with commas: "
    read -e -p "(Default database: `echo $databases | tr ' ' ','`) " db_name
    db_name=`echo ${db_name} | tr -d ' '`
    [ -z "${db_name}" ] && db_name="`echo $databases | tr ' ' ','`"
    D_tmp=0
    for D in `echo ${db_name} | tr ',' ' '`
    do
      [ -z "`echo $databases | grep -w $D`" ] && { echo "${CWARNING}$D was not exist! ${CEND}" ; D_tmp=1; }
    done
    [ "$D_tmp" != '1' ] && break
  done
  sed -i "s@^db_name=.*@db_name=${db_name}@" ./options.conf
fi

if [ "${content_bk}" != '1' ]; then
  websites=`ls ${wwwroot_dir}`
  while :; do echo
    echo "Please enter one or more name for website, separate multiple website names with commas: "
    read -e -p "(Default website: `echo $websites | tr ' ' ','`) " website_name
    website_name=`echo ${website_name} | tr -d ' '`
    [ -z "${website_name}" ] && website_name="`echo $websites | tr ' ' ','`"
    W_tmp=0
    for W in `echo ${website_name} | tr ',' ' '`
    do
      [ ! -e "${wwwroot_dir}/$W" ] && { echo "${CWARNING}${wwwroot_dir}/$W not exist! ${CEND}" ; W_tmp=1; }
    done
    [ "$W_tmp" != '1' ] && break
  done
  sed -i "s@^website_name=.*@website_name=${website_name}@" ./options.conf
fi

echo
echo "You have to backup the content:"
[ "${content_bk}" != '2' ] && echo "Database: ${CMSG}${db_name}${CEND}"
[ "${content_bk}" != '1' ] && echo "Website: ${CMSG}${website_name}${CEND}"

if [ -n "`echo ${desc_bk} | grep -w 2`" ]; then
  > tools/iplist.txt
  while :; do echo
    read -e -p "Please enter the remote host address: " remote_address
    [ -z "${remote_address}" -o "${remote_address}" == '127.0.0.1' ] && continue
    echo
    read -e -p "Please enter the remote host port(Default: 22) : " remote_port
    remote_port=${remote_port:-22}
    echo
    read -e -p "Please enter the remote host user(Default: root) : " remote_user
    remote_user=${remote_user:-root}
    echo
    read -e -p "Please enter the remote host password: " remote_password
    IPcode=$(echo "ibase=16;$(echo "${remote_address}" | xxd -ps -u)"|bc|tr -d '\\'|tr -d '\n')
    Portcode=$(echo "ibase=16;$(echo "${remote_port}" | xxd -ps -u)"|bc|tr -d '\\'|tr -d '\n')
    PWcode=$(echo "ibase=16;$(echo "$remote_password" | xxd -ps -u)"|bc|tr -d '\\'|tr -d '\n')
    [ -e "~/.ssh/known_hosts" ] && grep ${remote_address} ~/.ssh/known_hosts | sed -i "/${remote_address}/d" ~/.ssh/known_hosts
    ./tools/mssh.exp ${IPcode}P ${remote_user} ${PWcode}P ${Portcode}P true 10
    if [ $? -eq 0 ]; then
      [ -z "`grep ${remote_address} tools/iplist.txt`" ] && echo "${remote_address} ${remote_port} ${remote_user} $remote_password" >> tools/iplist.txt || echo "${CWARNING}${remote_address} has been added! ${CEND}"
      while :; do
        read -e -p "Do you want to add more host ? [y/n]: " morehost_flag
        if [[ ! ${morehost_flag} =~ ^[y,n]$ ]]; then
          echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
        else
          break
        fi
      done
      [ "${morehost_flag}" == 'n' ] && break
    fi
  done
fi

if [ -n "`echo ${desc_bk} | grep -w 3`" ]; then
  if [ ! -e "/usr/local/bin/ossutil" ]; then
    if [ "${armplatform}" == 'y' ]; then
      wget -qc https://gosspublic.alicdn.com/ossutil/1.7.10/ossutilarm64 -O /usr/local/bin/ossutil
    else
      wget -qc https://gosspublic.alicdn.com/ossutil/1.7.10/ossutil64 -O /usr/local/bin/ossutil
    fi
    chmod +x /usr/local/bin/ossutil
  fi
  while :; do echo
    echo 'Please select your backup aliyun datacenter:'
    echo -e "\t ${CMSG}1${CEND}. cn-hangzhou-华东1 (杭州)          ${CMSG}2${CEND}. cn-shanghai-华东2 (上海)"
    echo -e "\t ${CMSG}3${CEND}. cn-qingdao-华北1 (青岛)           ${CMSG}4${CEND}. cn-beijing-华北2 (北京)"
    echo -e "\t ${CMSG}5${CEND}. cn-zhangjiakou-华北3 (张家口)     ${CMSG}6${CEND}. cn-huhehaote-华北5(呼和浩特)"
    echo -e "\t ${CMSG}7${CEND}. cn-wulanchabu-华北6（乌兰察布）   ${CMSG}8${CEND}. cn-shenzhen-华南1（深圳）"
    echo -e "\t ${CMSG}9${CEND}. cn-heyuan-华南2（河源）	  ${CMSG}10${CEND}. cn-guangzhou-华南3（广州）"
    echo -e "\t${CMSG}11${CEND}. cn-chengdu-西南1（成都）         ${CMSG}12${CEND}. cn-hongkong-香港"
    echo -e "\t${CMSG}13${CEND}. us-west-1-美国（硅谷）           ${CMSG}14${CEND}. us-east-1-美国（弗吉尼亚）"
    echo -e "\t${CMSG}15${CEND}. ap-southeast-1-新加坡            ${CMSG}16${CEND}. ap-southeast-2-澳大利亚（悉尼）"
    echo -e "\t${CMSG}17${CEND}. ap-southeast-3-马来西亚（吉隆坡）${CMSG}18${CEND}. ap-southeast-5-印度尼西亚（雅加达）"
    echo -e "\t${CMSG}19${CEND}. ap-northeast-1-日本（东京）      ${CMSG}20${CEND}. ap-south-1-印度（孟买）"
    echo -e "\t${CMSG}21${CEND}. eu-central-1-德国（法兰克福）    ${CMSG}22${CEND}. eu-west-1-英国（伦敦）"
    echo -e "\t${CMSG}23${CEND}. me-east-1-中东东部 (迪拜)        ${CMSG}24${CEND}. ap-southeast-6-菲律宾（马尼拉）"
    read -e -p "Please input a number:(Default 1 press Enter) " Location
    Location=${Location:-1}
    if [[ "${Location}" =~ ^[1-9]$|^1[0-9]$|^24$ ]]; then
      break
    else
      echo "${CWARNING}input error! Please only input number 1~24${CEND}"
    fi
  done
  [ "${Location}" == '1' ] && Host=oss-cn-hangzhou-internal.aliyuncs.com
  [ "${Location}" == '2' ] && Host=oss-cn-shanghai-internal.aliyuncs.com
  [ "${Location}" == '3' ] && Host=oss-cn-qingdao-internal.aliyuncs.com
  [ "${Location}" == '4' ] && Host=oss-cn-beijing-internal.aliyuncs.com
  [ "${Location}" == '5' ] && Host=oss-cn-zhangjiakou-internal.aliyuncs.com
  [ "${Location}" == '6' ] && Host=oss-cn-huhehaote-internal.aliyuncs.com
  [ "${Location}" == '7' ] && Host=oss-cn-wulanchabu-internal.aliyuncs.com
  [ "${Location}" == '8' ] && Host=oss-cn-shenzhen-internal.aliyuncs.com
  [ "${Location}" == '9' ] && Host=oss-cn-heyuan-internal.aliyuncs.com
  [ "${Location}" == '10' ] && Host=oss-cn-guangzhou-internal.aliyuncs.com
  [ "${Location}" == '11' ] && Host=oss-cn-chengdu-internal.aliyuncs.com
  [ "${Location}" == '12' ] && Host=oss-cn-hongkong-internal.aliyuncs.com
  [ "${Location}" == '13' ] && Host=oss-us-west-1-internal.aliyuncs.com
  [ "${Location}" == '14' ] && Host=oss-us-east-1-internal.aliyuncs.com
  [ "${Location}" == '15' ] && Host=oss-ap-southeast-1-internal.aliyuncs.com
  [ "${Location}" == '16' ] && Host=oss-ap-southeast-2-internal.aliyuncs.com
  [ "${Location}" == '17' ] && Host=oss-ap-southeast-3-internal.aliyuncs.com
  [ "${Location}" == '18' ] && Host=oss-ap-southeast-5-internal.aliyuncs.com
  [ "${Location}" == '19' ] && Host=oss-ap-northeast-1-internal.aliyuncs.com
  [ "${Location}" == '20' ] && Host=oss-ap-south-1-internal.aliyuncs.com
  [ "${Location}" == '21' ] && Host=oss-eu-central-1-internal.aliyuncs.com
  [ "${Location}" == '22' ] && Host=oss-eu-west-1-internal.aliyuncs.com
  [ "${Location}" == '23' ] && Host=oss-me-east-1-internal.aliyuncs.com
  [ "${Location}" == '24' ] && Host=oss-ap-southeast-6-internal.aliyuncs.com
  [ "$(./include/check_port.py ${Host} 80)" == "False" ] && Host=`echo ${Host} | sed 's@-internal@@g'`
  [ -e "/root/.ossutilconfig" ] && rm -f /root/.ossutilconfig
  while :; do echo
    read -e -p "Please enter the aliyun oss Access Key ID: " KeyID
    [ -z "${KeyID}" ] && continue
    echo
    read -e -p "Please enter the aliyun oss Access Key Secret: " KeySecret
    [ -z "${KeySecret}" ] && continue
    /usr/local/bin/ossutil ls -e ${Host} -i ${KeyID} -k ${KeySecret} > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      /usr/local/bin/ossutil config -e ${Host} -i ${KeyID} -k ${KeySecret} > /dev/null 2>&1
      while :; do echo
        read -e -p "Please enter the aliyun oss bucket: " OSS_BUCKET
        /usr/local/bin/ossutil mb oss://${OSS_BUCKET} > /dev/null 2>&1
        if [ $? -eq 0 ]; then
          echo "${CMSG}Bucket oss://${OSS_BUCKET}/ created${CEND}"
          sed -i "s@^oss_bucket=.*@oss_bucket=${OSS_BUCKET}@" ./options.conf
          break
        else
          echo "${CWARNING}[${OSS_BUCKET}] already exists, You need to use the OSS Console to create a bucket for storing.${CEND}"
        fi
      done
      break
    fi
  done
fi

if [ -n "`echo ${desc_bk} | grep -w 4`" ]; then
  Install_Python
  [ ! -e "${python_install_dir}/bin/coscmd" ] && ${python_install_dir}/bin/pip install coscmd > /dev/null 2>&1
  while :; do echo
    echo 'Please select your backup qcloud datacenter:'
    echo -e "\t ${CMSG} 1${CEND}. ap-beijing-1-北京一区(华北)  ${CMSG}2${CEND}. ap-beijing-北京"
    echo -e "\t ${CMSG} 3${CEND}. ap-nanjing-南京              ${CMSG}4${CEND}. ap-shanghai-上海"
    echo -e "\t ${CMSG} 5${CEND}. ap-guangzhou-广州            ${CMSG}6${CEND}. ap-chengdu-成都"
    echo -e "\t ${CMSG} 7${CEND}. ap-chongqing-重庆            ${CMSG}8${CEND}. ap-shenzhen-fsi-深圳金融"
    echo -e "\t ${CMSG} 9${CEND}. ap-shanghai-fsi-上海金融    ${CMSG}10${CEND}. ap-beijing-fsi-北京金融"
    echo -e "\t ${CMSG}11${CEND}. ap-hongkong-香港            ${CMSG}11${CEND}. ap-singapore-新加坡"
    echo -e "\t ${CMSG}13${CEND}. ap-mumbai-孟买              ${CMSG}14${CEND}. ap-jakarta-雅加达"
    echo -e "\t ${CMSG}15${CEND}. ap-seoul-首尔               ${CMSG}16${CEND}. ap-bangkok-曼谷"
    echo -e "\t ${CMSG}17${CEND}. ap-tokyo-东京               ${CMSG}18${CEND}. na-siliconvalley-硅谷（美西）"
    echo -e "\t ${CMSG}19${CEND}. na-ashburn-弗吉尼亚（美东） ${CMSG}20${CEND}. na-toronto-多伦多"
    echo -e "\t ${CMSG}21${CEND}. sa-saopaulo-圣保罗	      ${CMSG}22${CEND}. eu-frankfurt-法兰克福"
    echo -e "\t ${CMSG}23${CEND}. eu-moscow-莫斯科"
    read -e -p "Please input a number:(Default 1 press Enter) " Location
    Location=${Location:-1}
    if [[ "${Location}" =~ ^[1-9]$|^1[0-9]$|^2[0-3]$ ]]; then
      break
    else
      echo "${CWARNING}input error! Please only input number 1~23${CEND}"
    fi
  done
  [ "${Location}" == '1' ] && REGION='ap-beijing-1'
  [ "${Location}" == '2' ] && REGION='ap-beijing'
  [ "${Location}" == '3' ] && REGION='ap-nanjing'
  [ "${Location}" == '4' ] && REGION='ap-shanghai'
  [ "${Location}" == '5' ] && REGION='ap-guangzhou'
  [ "${Location}" == '6' ] && REGION='ap-chengdu'
  [ "${Location}" == '7' ] && REGION='ap-chongqing'
  [ "${Location}" == '8' ] && REGION='ap-shenzhen-fsi'
  [ "${Location}" == '9' ] && REGION='ap-shanghai-fsi'
  [ "${Location}" == '10' ] && REGION='ap-beijing-fsi'
  [ "${Location}" == '11' ] && REGION='ap-hongkong'
  [ "${Location}" == '12' ] && REGION='ap-singapore'
  [ "${Location}" == '13' ] && REGION='ap-mumbai'
  [ "${Location}" == '14' ] && REGION='ap-jakarta'
  [ "${Location}" == '15' ] && REGION='ap-seoul'
  [ "${Location}" == '16' ] && REGION='ap-bangkok'
  [ "${Location}" == '17' ] && REGION='ap-tokyo'
  [ "${Location}" == '18' ] && REGION='na-siliconvalley'
  [ "${Location}" == '19' ] && REGION='na-ashburn'
  [ "${Location}" == '20' ] && REGION='na-toronto'
  [ "${Location}" == '21' ] && REGION='sa-saopaulo'
  [ "${Location}" == '22' ] && REGION='eu-frankfurt'
  [ "${Location}" == '23' ] && REGION='eu-moscow'
  while :; do echo
    read -e -p "Please enter the Qcloud COS APPID: " APPID
    [[ ! "${APPID}" =~ ^[0-9]+$ ]] && { echo "${CWARNING}input error, must be a number${CEND}"; continue; }
    echo
    read -e -p "Please enter the Qcloud COS SECRET_ID: " SECRET_ID
    [ -z "${SECRET_ID}" ] && continue
    echo
    read -e -p "Please enter the Qcloud COS SECRET_KEY: " SECRET_KEY
    [ -z "${SECRET_KEY}" ] && continue
    echo
    read -e -p "Please enter the Qcloud COS BUCKET: " COS_BUCKET
    if [[ ${COS_BUCKET} =~ "-${APPID}"$ ]]; then
      COS_BUCKET=${COS_BUCKET}
    else
      [ -z "${COS_BUCKET}" ] && continue
      echo
      COS_BUCKET=${COS_BUCKET}-${APPID}
    fi
    ${python_install_dir}/bin/coscmd config -u ${APPID} -a ${SECRET_ID} -s ${SECRET_KEY} -r ${REGION} -b ${COS_BUCKET} > /dev/null 2>&1
    ${python_install_dir}/bin/coscmd list > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      echo "${CMSG}APPID/SECRET_ID/SECRET_KEY/REGION/BUCKET OK${CEND}"
      echo
      break
    else
      ${python_install_dir}/bin/coscmd -b ${COS_BUCKET} createbucket > /dev/null 2>&1
      if [ $? -eq 0 ]; then
        echo "${CMSG}Bucket ${COS_BUCKET} created${CEND}"
        echo
        break
      else
        echo "${CWARNING}input error! APPID/SECRET_ID/SECRET_KEY/REGION/BUCKET invalid${CEND}"
        continue
      fi
    fi
  done
fi

if [ -n "`echo ${desc_bk} | grep -w 5`" ]; then
  if [ ! -e "/usr/local/bin/upx" ]; then
    if [ "${armplatform}" == 'y' ]; then
      wget -qc http://collection.b0.upaiyun.com/softwares/upx/upx_0.3.6_linux_arm64.tar.gz -O /tmp/upx_0.3.6_linux_arm64.tar.gz
      tar xzf /tmp/upx_0.3.6_linux_arm64.tar.gz -C /tmp/
    else
      wget -qc http://collection.b0.upaiyun.com/softwares/upx/upx_0.3.6_linux_x86_64.tar.gz -O /tmp/upx_0.3.6_linux_x86_64.tar.gz
      tar xzf /tmp/upx_0.3.6_linux_x86_64.tar.gz -C /tmp/
    fi
    /bin/mv /tmp/upx /usr/local/bin/upx
    chmod +x /usr/local/bin/upx
    rm -f /tmp/upx_* /tmp/LICENSE /tmp/README.md
  fi
  while :; do echo
    read -e -p "Please enter the upyun ServiceName: " ServiceName
    [ -z "${ServiceName}" ] && continue
    echo
    read -e -p "Please enter the upyun Operator: " Operator
    [ -z "${Operator}" ] && continue
    echo
    read -e -p "Please enter the upyun Password: " Password
    [ -z "${Password}" ] && continue
    echo
    /usr/local/bin/upx login ${ServiceName} ${Operator} ${Password} > /dev/null 2>&1
    if [ $? = 0 ]; then
      echo "${CMSG}ServiceName/Operator/Password OK${CEND}"
      echo
      break
    else
      echo "${CWARNING}input error! ServiceName/Operator/Password invalid${CEND}"
    fi
  done
fi

if [ -n "`echo ${desc_bk} | grep -w 6`" ]; then
  if [ ! -e "/usr/local/bin/qshell" ]; then
    if [ "${armplatform}" == 'y' ]; then
      wget -qc https://devtools.qiniu.com/qshell-v2.6.2-linux-arm64.tar.gz -O /tmp/qshell-v2.6.2-linux-arm64.tar.gz
      tar xzf /tmp/qshell-v2.6.2-linux-arm64.tar.gz -C /usr/local/bin/
    else
      wget -qc https://devtools.qiniu.com/qshell-v2.6.2-linux-amd64.tar.gz -O /tmp/qshell-v2.6.2-linux-amd64.tar.gz
      tar xzf /tmp/qshell-v2.6.2-linux-amd64.tar.gz -C /usr/local/bin/
    fi
    chmod +x /usr/local/bin/qshell
    rm -f /tmp/qshell*
  fi
  while :; do echo
    echo 'Please select your backup qiniu datacenter:'
    echo -e "\t ${CMSG} 1${CEND}. 华东            ${CMSG}2${CEND}. 华北"
    echo -e "\t ${CMSG} 3${CEND}. 华南            ${CMSG}4${CEND}. 北美"
    echo -e "\t ${CMSG} 5${CEND}. 东南亚          ${CMSG}6${CEND}. 华东-浙江2"
    read -e -p "Please input a number:(Default 1 press Enter) " Location
    Location=${Location:-1}
    if [[ "${Location}" =~ ^[1-6]$ ]]; then
      break
    else
      echo "${CWARNING}input error! Please only input number 1~6${CEND}"
    fi
  done
  [ "${Location}" == '1' ] && zone='z0'
  [ "${Location}" == '2' ] && zone='z1'
  [ "${Location}" == '3' ] && zone='z2'
  [ "${Location}" == '4' ] && zone='na0'
  [ "${Location}" == '5' ] && zone='as0'
  [ "${Location}" == '6' ] && zone='cn-east-2'
  while :; do echo
    read -e -p "Please enter the qiniu AccessKey: " AccessKey
    [ -z "${AccessKey}" ] && continue
    echo
    read -e -p "Please enter the qiniu SecretKey: " SecretKey
    [ -z "${SecretKey}" ] && continue
    echo
    read -e -p "Please enter the qiniu bucket: " QINIU_BUCKET
    [ -z "${QINIU_BUCKET}" ] && continue
    echo
    /usr/local/bin/qshell account ${AccessKey} ${SecretKey} backup
    if /usr/local/bin/qshell buckets | grep -w ${QINIU_BUCKET} > /dev/null 2>&1; then
      sed -i "s@^qiniu_bucket=.*@qiniu_bucket=${QINIU_BUCKET}@" ./options.conf
      echo "${CMSG}AccessKey/SecretKey/Bucket OK${CEND}"
      echo
      break
    else
      echo "${CWARNING}input error! AccessKey/SecretKey/Bucket invalid${CEND}"
    fi
  done
fi

if [ -n "`echo ${desc_bk} | grep -w 7`" ]; then
  Install_Python
  [ ! -e "${python_install_dir}/bin/s3cmd" ] && ${python_install_dir}/bin/pip install s3cmd > /dev/null 2>&1
  while :; do echo
    echo 'Please select your backup amazon datacenter:'
    echo -e "\t ${CMSG} 1${CEND}. us-east-2                    ${CMSG} 2${CEND}. us-east-1"
    echo -e "\t ${CMSG} 3${CEND}. us-west-1                    ${CMSG} 4${CEND}. us-west-2"
    echo -e "\t ${CMSG} 5${CEND}. ap-south-1                   ${CMSG} 6${CEND}. ap-northeast-3"
    echo -e "\t ${CMSG} 7${CEND}. ap-northeast-2               ${CMSG} 8${CEND}. ap-southeast-1"
    echo -e "\t ${CMSG} 9${CEND}. ap-southeast-2               ${CMSG}10${CEND}. ap-northeast-1"
    echo -e "\t ${CMSG}11${CEND}. ca-central-1                 ${CMSG}12${CEND}. cn-north-1"
    echo -e "\t ${CMSG}13${CEND}. cn-northwest-1               ${CMSG}14${CEND}. eu-central-1"
    echo -e "\t ${CMSG}15${CEND}. eu-west-1                    ${CMSG}16${CEND}. eu-west-2"
    echo -e "\t ${CMSG}17${CEND}. eu-west-3                    ${CMSG}18${CEND}. eu-north-1"
    echo -e "\t ${CMSG}19${CEND}. sa-east-1                    ${CMSG}20${CEND}. us-gov-east-1"
    echo -e "\t ${CMSG}21${CEND}. us-gov-west-1"
    read -e -p "Please input a number:(Default 1 press Enter) " Location
    Location=${Location:-1}
    if [[ "${Location}" =~ ^[1-9]$|^1[0-9]$|^2[0-1]$ ]]; then
      break
    else
      echo "${CWARNING}input error! Please only input number 1~21${CEND}"
    fi
  done
  [ "${Location}" == '1' ] && REGION='us-east-2'
  [ "${Location}" == '2' ] && REGION='us-east-1'
  [ "${Location}" == '3' ] && REGION='us-west-1'
  [ "${Location}" == '4' ] && REGION='us-west-2'
  [ "${Location}" == '5' ] && REGION='ap-south-1'
  [ "${Location}" == '6' ] && REGION='ap-northeast-3'
  [ "${Location}" == '7' ] && REGION='ap-northeast-2'
  [ "${Location}" == '8' ] && REGION='ap-southeast-1'
  [ "${Location}" == '9' ] && REGION='ap-southeast-2'
  [ "${Location}" == '10' ] && REGION='ap-northeast-1'
  [ "${Location}" == '11' ] && REGION='ca-central-1'
  [ "${Location}" == '12' ] && REGION='cn-north-1'
  [ "${Location}" == '13' ] && REGION='cn-northwest-1'
  [ "${Location}" == '14' ] && REGION='eu-central-1'
  [ "${Location}" == '15' ] && REGION='eu-west-1'
  [ "${Location}" == '16' ] && REGION='eu-west-2'
  [ "${Location}" == '17' ] && REGION='eu-west-3'
  [ "${Location}" == '18' ] && REGION='eu-north-1'
  [ "${Location}" == '19' ] && REGION='sa-east-1'
  [ "${Location}" == '20' ] && REGION='us-gov-east-1'
  [ "${Location}" == '21' ] && REGION='us-gov-west-1'
  while :; do echo
    read -e -p "Please enter the AWS Access Key: " ACCESS_KEY
    [ -z "${ACCESS_KEY}" ] && continue
    echo
    read -e -p "Please enter the AWS Access Key: " SECRET_KEY
    [ -z "${SECRET_KEY}" ] && continue
    ${python_install_dir}/bin/s3cmd --access_key=${ACCESS_KEY} --secret_key=${SECRET_KEY} --region=${REGION} la > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      ${python_install_dir}/bin/s3cmd --configure --access_key=${ACCESS_KEY} --secret_key=${SECRET_KEY} --region=${REGION} --dump-config > ~/.s3cfg
      echo "${CMSG}ACCESS_KEY/SECRET_KEY OK${CEND}"
      while :; do echo
        read -e -p "Please enter the Amazon S3 bucket: " S3_BUCKET
        [ -z "${S3_BUCKET}" ] && continue
        ${python_install_dir}/bin/s3cmd ls s3://${S3_BUCKET} > /dev/null 2>&1
        if [ $? -eq 0 ]; then
          echo "${CMSG}Bucket s3://${S3_BUCKET}/ existed${CEND}"
          sed -i "s@^s3_bucket=.*@s3_bucket=${S3_BUCKET}@" ./options.conf
          break
        else
          ${python_install_dir}/bin/s3cmd mb s3://${S3_BUCKET} > /dev/null 2>&1
          if [ $? -eq 0 ]; then
            echo "${CMSG}Bucket s3://${S3_BUCKET}/ created${CEND}"
            sed -i "s@^s3_bucket=.*@s3_bucket=${S3_BUCKET}@" ./options.conf
            break
          else
            echo "${CWARNING}The requested bucket name is not available. The bucket namespace is shared by all users of the system. Please select a different name and try again.${CEND}"
            continue
          fi
        fi
      done
      break
    else
      echo "${CWARNING}input error! ACCESS_KEY/SECRET_KEY invalid${CEND}"
      continue
    fi
  done
fi

if [ -n "`echo ${desc_bk} | grep -w 8`" ]; then
  if [ ! -e "/usr/local/bin/dbxcli" ]; then
    if [ "${armplatform}" == 'y' ]; then
      wget -qc http://mirrors.linuxeye.com/oneinstack/src/dbxcli-linux-arm -O /usr/local/bin/dbxcli
    else
      wget -qc http://mirrors.linuxeye.com/oneinstack/src/dbxcli-linux-amd64 -O /usr/local/bin/dbxcli
    fi
    chmod +x /usr/local/bin/dbxcli
  fi
  while :; do echo
    if dbxcli account; then
      break
    fi
  done
fi
