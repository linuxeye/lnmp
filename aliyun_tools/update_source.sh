#!/bin/bash
#########################################
#Function:    update source
#Usage:       bash update_source.sh
#Author:      Customer service department
#Company:     Alibaba Cloud Computing
#Version:     2.0
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
        echo "$os_release"
      elif echo "$os_release"|grep "release 6" >/dev/null 2>&1
      then
        os_release=redhat6
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
        echo "$os_release"
      elif echo "$os_release"|grep "release 6" >/dev/null 2>&1
      then
        os_release=aliyun6
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
        echo "$os_release"
      elif echo "$os_release"|grep "release 6" >/dev/null 2>&1
      then
        os_release=centos6
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
        echo "$os_release"
      elif echo "$os_release"|grep "Ubuntu 12.04" >/dev/null 2>&1
      then
        os_release=ubuntu1204
        echo "$os_release"
      elif echo "$os_release"|grep "Ubuntu 12.10" >/dev/null 2>&1
      then
        os_release=ubuntu1210
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

update_debian_apt_source()
{
echo -e "\033[40;32mBackup the original configuration file,new name and path is /etc/apt/sources.list.back.\n\033[40;37m"
cp -fp /etc/apt/sources.list /etc/apt/sources.list.back
cat > /etc/apt/sources.list <<EOF
#debian6
deb http://mirrors.aliyuncs.com/debian/ squeeze main non-free contrib
deb http://mirrors.aliyuncs.com/debian/ squeeze-proposed-updates main non-free contrib
deb-src http://mirrors.aliyuncs.com/debian/ squeeze main non-free contrib
deb-src http://mirrors.aliyuncs.com/debian/ squeeze-proposed-updates main non-free contrib
#debian7
deb http://mirrors.aliyuncs.com/debian/ wheezy main non-free contrib
deb http://mirrors.aliyuncs.com/debian/ wheezy-proposed-updates main non-free contrib
deb-src http://mirrors.aliyuncs.com/debian/ wheezy main non-free contrib
deb-src http://mirrors.aliyuncs.com/debian/ wheezy-proposed-updates main non-free contrib
#debian8
deb http://mirrors.aliyuncs.com/debian/ jessie main non-free contrib
deb http://mirrors.aliyuncs.com/debian/ jessie-proposed-updates main non-free contrib
deb-src http://mirrors.aliyuncs.com/debian/ jessie main non-free contrib
deb-src http://mirrors.aliyuncs.com/debian/ jessie-proposed-updates main non-free contrib
EOF
apt-get update
}

####################Start###################
#check lock file ,one time only let the script run one time 
LOCKfile=/tmp/.$(basename $0)
if [ -f "$LOCKfile" ]
then
  echo -e "\033[1;40;31mThe script is already exist,please next time to run this script.\n\033[0m"
  exit
else
  echo -e "\033[40;32mStep 1.No lock file,begin to create lock file and continue.\n\033[40;37m"
  touch $LOCKfile
fi

#check user
if [ $(id -u) != "0" ]
then
  echo -e "\033[1;40;31mError: You must be root to run this script, please use root to install this script.\n\033[0m"
  rm -rf $LOCKfile
  exit 1
fi
echo -e "\033[40;32mStep 2.Begen to check the OS issue.\n\033[40;37m"
os_release=$(check_os_release)
if [ "X$os_release" == "X" ]
then
  echo -e "\033[1;40;31mThe OS does not identify,So this script is not executede.\n\033[0m"
  rm -rf $LOCKfile
  exit 0
else
  echo -e "\033[40;32mThis OS is $os_release.\n\033[40;37m"
fi

echo -e "\033[40;32mStep 3.Begen to modify the source configration file and update.\n\033[40;37m"
case "$os_release" in
redhat5|centos5|aliyun5)
  modify_rhel5_yum
  ;;
redhat6|centos6|aliyun6)
  modify_rhel6_yum
  ;;
ubuntu10)
  update_ubuntu10_apt_source
  ;;
ubuntu1204)
  update_ubuntu1204_apt_source
  ;;
ubuntu1210)
  update_ubuntu1210_apt_source
  ;;
debian6)
  update_debian_apt_source
  ;;
esac
echo -e "\033[40;32mSuccess,exit now!\n\033[40;37m"
rm -rf $LOCKfile