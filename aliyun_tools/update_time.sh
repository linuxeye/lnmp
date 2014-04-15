#!/bin/bash
#########################################
#Function:    update time
#Usage:       bash update_time.sh
#Author:      Customer service department
#Company:     Alibaba Cloud Computing
#Version:     3.0
#########################################

check_os_release()
{
  while true
  do
    os_release=$(grep "Red Hat Enterprise Linux Server release" /etc/issue 2>/dev/null)
    os_release_2=$(grep "Red Hat Enterprise Linux Server release" /etc/redhat-release 2>/dev/null)
    if [ "$os_release" ] && [ "$os_release_2" ]
    then
      if echo "$os_release"|grep "release 5" >/dev/null 2>&1
      then
        os_release=redhat5
	os_type=redhat
        echo "$os_release"
      elif echo "$os_release"|grep "release 6" >/dev/null 2>&1
      then
        os_release=redhat6
	os_type=redhat
        echo "$os_release"
      else
        os_release=""
        echo "$os_release"
      fi
      break
    fi
    os_release=$(grep "Aliyun Linux release" /etc/issue 2>/dev/null)
    os_release_2=$(grep "Aliyun Linux release" /etc/aliyun-release 2>/dev/null)
    if [ "$os_release" ] && [ "$os_release_2" ]
    then
      if echo "$os_release"|grep "release 5" >/dev/null 2>&1
      then
        os_release=aliyun5
	os_type=redhat
        echo "$os_release"
      elif echo "$os_release"|grep "release 6" >/dev/null 2>&1
      then
        os_release=aliyun6
	os_type=redhat
        echo "$os_release"
      else
        os_release=""
        echo "$os_release"
      fi
      break
    fi
    os_release=$(grep "CentOS release" /etc/issue 2>/dev/null)
    os_release_2=$(grep "CentOS release" /etc/*release 2>/dev/null)
    if [ "$os_release" ] && [ "$os_release_2" ]
    then
      if echo "$os_release"|grep "release 5" >/dev/null 2>&1
      then
        os_release=centos5
	os_type=redhat
        echo "$os_release"
      elif echo "$os_release"|grep "release 6" >/dev/null 2>&1
      then
        os_release=centos6
	os_type=redhat
        echo "$os_release"
      else
        os_release=""
        echo "$os_release"
      fi
      break
    fi
    os_release=$(grep -i "ubuntu" /etc/issue 2>/dev/null)
    os_release_2=$(grep -i "ubuntu" /etc/lsb-release 2>/dev/null)
    if [ "$os_release" ] && [ "$os_release_2" ]
    then
      if echo "$os_release"|grep "Ubuntu 10" >/dev/null 2>&1
      then
        os_release=ubuntu10
	os_type=ubuntu
        echo "$os_release"
      elif echo "$os_release"|grep "Ubuntu 12.04" >/dev/null 2>&1
      then
        os_release=ubuntu1204
	os_type=ubuntu
        echo "$os_release"
      elif echo "$os_release"|grep "Ubuntu 12.10" >/dev/null 2>&1
      then
        os_release=ubuntu1210
	os_type=ubuntu
        echo "$os_release"
      else
        os_release=""
        echo "$os_release"
      fi
      break
    fi
    os_release=$(grep -i "debian" /etc/issue 2>/dev/null)
    os_release_2=$(grep -i "debian" /proc/version 2>/dev/null)
    if [ "$os_release" ] && [ "$os_release_2" ]
    then
      if echo "$os_release"|grep "Linux 6" >/dev/null 2>&1
      then
        os_release=debian6
	os_type=debian
        echo "$os_release"
      else
        os_release=""
        echo "$os_release"
      fi
      break
    fi
    break
    done
}

modify_rhel5_yum()
{
  wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyuncs.com/repo/Centos-5.repo
  sed -i 's/aliyun/aliyuncs/g' /etc/yum.repos.d/CentOS-Base.repo
  sed -i 's/\$releasever/5/' /etc/yum.repos.d/CentOS-Base.repo
  yum clean metadata
  yum makecache
  cd ~
}

modify_rhel6_yum()
{
  wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyuncs.com/repo/Centos-6.repo
  sed -i 's/aliyun/aliyuncs/g' /etc/yum.repos.d/CentOS-Base.repo
  sed -i 's/\$releasever/6/' /etc/yum.repos.d/CentOS-Base.repo
  yum clean metadata
  yum makecache
  cd ~
}

update_ubuntu10_apt_source()
{
echo -e "\033[40;32mBackup the original configuration file,new name and path is /etc/apt/sources.list.back.\n\033[40;37m"
cp -fp /etc/apt/sources.list /etc/apt/sources.list.back
cat > /etc/apt/sources.list <<EOF
#ubuntu
deb http://cn.archive.ubuntu.com/ubuntu/ maverick main restricted universe multiverse
deb-src http://cn.archive.ubuntu.com/ubuntu/ maverick main restricted universe multiverse
#163
deb http://mirrors.163.com/ubuntu/ maverick main universe restricted multiverse
deb-src http://mirrors.163.com/ubuntu/ maverick main universe restricted multiverse
deb http://mirrors.163.com/ubuntu/ maverick-updates universe main multiverse restricted
deb-src http://mirrors.163.com/ubuntu/ maverick-updates universe main multiverse restricted
#lupaworld
deb http://mirror.lupaworld.com/ubuntu/ maverick main universe restricted multiverse
deb-src http://mirror.lupaworld.com/ubuntu/ maverick main universe restricted multiverse
deb http://mirror.lupaworld.com/ubuntu/ maverick-security universe main multiverse restricted
deb-src http://mirror.lupaworld.com/ubuntu/ maverick-security universe main multiverse restricted
deb http://mirror.lupaworld.com/ubuntu/ maverick-updates universe main multiverse restricted
deb http://mirror.lupaworld.com/ubuntu/ maverick-proposed universe main multiverse restricted
deb-src http://mirror.lupaworld.com/ubuntu/ maverick-proposed universe main multiverse restricted
deb http://mirror.lupaworld.com/ubuntu/ maverick-backports universe main multiverse restricted
deb-src http://mirror.lupaworld.com/ubuntu/ maverick-backports universe main multiverse restricted
deb-src http://mirror.lupaworld.com/ubuntu/ maverick-updates universe main multiverse restricted
EOF
apt-get update
}

update_ubuntu1204_apt_source()
{
echo -e "\033[40;32mBackup the original configuration file,new name and path is /etc/apt/sources.list.back.\n\033[40;37m"
cp -fp /etc/apt/sources.list /etc/apt/sources.list.back
cat > /etc/apt/sources.list <<EOF
#12.04
deb http://mirrors.aliyuncs.com/ubuntu/ precise main restricted universe multiverse
deb http://mirrors.aliyuncs.com/ubuntu/ precise-security main restricted universe multiverse
deb http://mirrors.aliyuncs.com/ubuntu/ precise-updates main restricted universe multiverse
deb http://mirrors.aliyuncs.com/ubuntu/ precise-proposed main restricted universe multiverse
deb http://mirrors.aliyuncs.com/ubuntu/ precise-backports main restricted universe multiverse
deb-src http://mirrors.aliyuncs.com/ubuntu/ precise main restricted universe multiverse
deb-src http://mirrors.aliyuncs.com/ubuntu/ precise-security main restricted universe multiverse
deb-src http://mirrors.aliyuncs.com/ubuntu/ precise-updates main restricted universe multiverse
deb-src http://mirrors.aliyuncs.com/ubuntu/ precise-proposed main restricted universe multiverse
deb-src http://mirrors.aliyuncs.com/ubuntu/ precise-backports main restricted universe multiverse
EOF
apt-get update
}

update_ubuntu1210_apt_source()
{
echo -e "\033[40;32mBackup the original configuration file,new name and path is /etc/apt/sources.list.back.\n\033[40;37m"
cp -fp /etc/apt/sources.list /etc/apt/sources.list.back
cat > /etc/apt/sources.list <<EOF
#12.10
deb http://mirrors.aliyuncs.com/ubuntu/ quantal main restricted universe multiverse
deb http://mirrors.aliyuncs.com/ubuntu/ quantal-security main restricted universe multiverse
deb http://mirrors.aliyuncs.com/ubuntu/ quantal-updates main restricted universe multiverse
deb http://mirrors.aliyuncs.com/ubuntu/ quantal-proposed main restricted universe multiverse
deb http://mirrors.aliyuncs.com/ubuntu/ quantal-backports main restricted universe multiverse
deb-src http://mirrors.aliyuncs.com/ubuntu/ quantal main restricted universe multiverse
deb-src http://mirrors.aliyuncs.com/ubuntu/ quantal-security main restricted universe multiverse
deb-src http://mirrors.aliyuncs.com/ubuntu/ quantal-updates main restricted universe multiverse
deb-src http://mirrors.aliyuncs.com/ubuntu/ quantal-proposed main restricted universe multiverse
deb-src http://mirrors.aliyuncs.com/ubuntu/ quantal-backports main restricted universe multiverse
EOF
apt-get update
}

config_time_zone()
{
  if [ "$os_type" == "redhat" ]
  then
    if [ -e "/usr/share/zoneinfo/Asia/Shanghai" ]
    then
      echo -e "\033[40;32mStep1:Begin to config time zone.\n\033[40;37m"
      cp -fp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
      echo -e "ZONE=\"Asia/Shanghai\"\nUTC=false\nARC=false">/etc/sysconfig/clock
    fi
  elif [ "$os_type" == "ubuntu" ] || [ "$os_type" == "debian" ]
  then
    echo -e "\033[40;32mStep1:Begin to config time zone.\n\033[40;37m"
    cp -fp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
  fi
}

update_debian_apt_source()
{
cat >> /etc/apt/sources.list <<EOF
#debian6
deb http://mirrors.aliyuncs.com/debian/ squeeze main non-free contrib
deb http://mirrors.aliyuncs.com/debian/ squeeze-proposed-updates main non-free contrib
deb-src http://mirrors.aliyuncs.com/debian/ squeeze main non-free contrib
deb-src http://mirrors.aliyuncs.com/debian/ squeeze-proposed-updates main non-free contrib
EOF
apt-get update
}

install_ntp()
{
  case "$os_release" in
  redhat5|centos5|aliyun5)
    modify_rhel5_yum
    if ! yum install ntp -y
    then
      echo "Can not install ntp.Script will end."
      rm -rf $LOCKfile
      exit 1
    fi
    ;;
  redhat6|centos6|aliyun6)
    modify_rhel6_yum
    if ! yum install ntp -y
    then
      echo "Can not install ntp.Script will end."
      rm -rf $LOCKfile
      exit 1
    fi
    ;;
  ubuntu10)
    update_ubuntu10_apt_source
    if ! apt-get install ntp ntpdate -y
    then
      echo "Can not install ntp.Script will end."
      rm -rf $LOCKfile
      exit 1
    fi
    ;;
 ubuntu1204)
   update_ubuntu1204_apt_source
   if ! apt-get install ntp ntpdate -y
   then
     echo "Can not install ntp.Script will end."
     rm -rf $LOCKfile
     exit 1
   fi
   ;;
 ubuntu1210)
   update_ubuntu1210_apt_source
   if ! apt-get install ntp ntpdate -y
   then
     echo "Can not install ntp.Script will end."
     rm -rf $LOCKfile
     exit 1
   fi
   ;; 
 debian6)
   update_debian_apt_source
   if ! apt-get install ntp ntpdate -y
   then
     echo "Can not install ntp.Script will end."
     rm -rf $LOCKfile
     exit 1
   fi
   ;;
 esac
}

mod_config_file()
{
  if [ "$os_type" == "redhat" ]
  then
     if ! grep "aliyun.com" /etc/ntp/step-tickers >/dev/null 2>&1
     then
       echo -e "ntp1.aliyun.com\nntp1.aliyun.com\nntp1.aliyun.com\n0.asia.pool.ntp.org\n210.72.145.44">>/etc/ntp/step-tickers
     fi
  fi
  if ! grep "aliyun.com" /etc/ntp.conf >/dev/null 2>&1
  then
    echo -e "server ntp1.aliyun.com prefer\nserver ntp2.aliyun.com\nserver ntp3.aliyun.com\nserver 0.asia.pool.ntp.org\nserver 210.72.145.44">>/etc/ntp.conf
  fi
}

install_chkconfig()
{
  if [ "$os_type" == "redhat" ] || [ "$os_type" == "centos" ]
  then
     yum install chkconfig -y
  elif [ "$os_type" == "ubuntu" ] || [ "$os_type" == "debian" ]
  then
     apt-get install rcconf dialog whiptail -y --force-yes --fix-missing
  fi
}

####################Start###################
#check lock file ,one time only let the script run one time 
LOCKfile=/tmp/.$(basename $0)
if [ -f "$LOCKfile" ]
then
  echo -e "\033[1;40;31mThe script is already exist,please next time to run this script.\n\033[0m"
  exit
else
  echo -e "\033[40;32mStep 0.No lock file,begin to create lock file and continue.\n\033[40;37m"
  touch $LOCKfile
fi

#check user
if [ $(id -u) != "0" ]
then
  echo -e "\033[1;40;31mError: You must be root to run this script, please use root to install this script.\n\033[0m"
  rm -rf $LOCKfile
  exit 1
fi
check_os_release
config_time_zone

echo -e "\033[40;32mStep2:Check ntp package and if not to install it.\n\033[40;37m"
install_ntp

echo -e "\033[40;32mStep3:Modify the ntp config file.\n\033[40;37m"
mod_config_file

echo -e "\033[40;32mStep4:Begin to update time...\n\033[40;37m"
ntpdate -u ntp1.aliyun.com
ntpdate -u ntp2.aliyun.com

echo -e "\033[40;32mStep5:Restart ntp service...\n\033[40;37m"
if [ "$os_type" == "redhat" ] || [ "$os_type" == "centos" ]
then
   service ntpd restart
elif [ "$os_type" == "ubuntu" ] || [ "$os_type" == "debian" ]
then
   service ntp restart
fi

install_chkconfig
if [ "$os_type" == "redhat" ] || [ "$os_type" == "centos" ]
then
   chkconfig --level 2345 ntpd on
elif [ "$os_type" == "ubuntu" ] || [ "$os_type" == "debian" ]
then
   rcconf --on ntp
fi
echo -e "\033[40;32mStep6:The NTP service is configured to start automatically at runlevels 2345.\n\033[40;37m"
rm -rf $LOCKfile