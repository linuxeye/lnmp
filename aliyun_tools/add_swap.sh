#!/bin/bash
#########################################
#Function:    add a new swap partition
#Usage:       bash add_swap.sh
#Author:      Customer service department
#Company:     Alibaba Cloud Computing
#Version:     2.1
#########################################

check_os_release()
{
  while true
  do
    if cat /proc/version | grep redhat >/dev/null 2>&1
    then
      os_release=redhat
      echo "$os_release"
      break
    fi
    if cat /proc/version | grep centos >/dev/null 2>&1
    then
      os_release=centos
      echo "$os_release"
      break
    fi
    if cat /proc/version | grep ubuntu >/dev/null 2>&1
    then
      os_release=ubuntu
      echo "$os_release"
      break
    fi
    if cat /proc/version | grep -i debian >/dev/null 2>&1
    then
      os_release=debian
      echo "$os_release"
      break
    fi
    break
    done
}

check_memory_and_swap()
{
  mem_count=$(free -m|grep Mem|awk '{print $2}')
  swap_count=$(free -m|grep Swap|awk '{print $2}')
  if [ "$mem_count" -ge 15000 ]  && [ "$mem_count" -le 32768 ]
  then
    if [ "$swap_count" -ge 8000 ]
    then
      echo -e "\033[1;40;31mYour swap is already enough.Do not need to add swap.Script will exit.\n\033[0m"
      rm -rf $LOCKfile
      exit 1
    elif [ "$swap_count" -ne 0 ]
    then
      echo -e "\033[40;32mYour swap is not enough,need to add swap.\n\033[40;37m"
      remove_old_swap
      create_swap 8192
    else
      echo -e "\033[40;32mYour swap is not enough,need to add swap.\n\033[40;37m"
      create_swap 8192
    fi
  elif [ "$mem_count" -ge 3900 ] && [ "$mem_count" -lt 15000 ]
  then
    if [ "$swap_count" -ge 3900 ]
    then
      echo -e "\033[1;40;31mYour swap is already enough.Do not need to add swap.Script will exit.\n\033[0m"
      rm -rf $LOCKfile
      exit 1
    elif [ "$swap_count" -ne 0 ]
    then
      echo -e "\033[40;32mYour swap is not enough,need to add swap.\n\033[40;37m"
      remove_old_swap
      create_swap 4096
    else
      echo -e "\033[40;32mYour swap is not enough,need to add swap.\n\033[40;37m"
      create_swap 4096
    fi
  else
    if [ "$swap_count" -ge 2000 ]
    then
      echo -e "\033[1;40;31mYour swap is already enough.Do not need to add swap.Script will exit.\n\033[0m"
      rm -rf $LOCKfile
      exit 1
    elif [ "$swap_count" -ne 0 ]
    then
      echo -e "\033[40;32mYour swap is not enough,need to add swap.\n\033[40;37m"
      remove_old_swap
      create_swap 2048
    else
      echo -e "\033[40;32mYour swap is not enough,need to add swap.\n\033[40;37m"
      create_swap 2048
    fi
  fi
}

create_swap()
{
  root_disk_size=$(df -m|grep -w "/"|awk '{print $4}')
  if [ "$1" -gt "$((root_disk_size-1024))" ]
  then
    echo -e "\033[1;40;31mThe root disk partition has no space for $1M swap file.Script will exit.\n\033[0m"
    rm -rf $LOCKfile
    exit 1
  fi
  if [ ! -e $swapfile ]
  then
    dd if=/dev/zero of=$swapfile bs=1M count=$1
    /sbin/mkswap $swapfile
    /sbin/swapon $swapfile
    /sbin/swapon -s
    echo -e "\033[40;32mStep 3.Add swap partition successful.\n\033[40;37m"
  else
    echo -e "\033[1;40;31mThe /var/swap_file already exists.Will exit.\n\033[0m"
    rm -rf $LOCKfile
    exit 1
  fi
}

remove_old_swap()
{
  old_swap_file=$(grep swap $fstab|grep -v "#"|awk '{print $1}')
  swapoff $old_swap_file
  cp -f $fstab ${fstab}_bak
  sed -i '/swap/d' $fstab
}

config_rhel_fstab()
{
  if ! grep $swapfile $fstab >/dev/null 2>&1
  then
    echo -e "\033[40;32mBegin to modify $fstab.\n\033[40;37m"
    echo "$swapfile	 swap	 swap defaults 0 0" >>$fstab
  else
    echo -e "\033[1;40;31m/etc/fstab is already configured.\n\033[0m"
    rm -rf $LOCKfile
    exit 1
  fi
}

config_debian_fstab()
{
  if ! grep $swapfile $fstab >/dev/null 2>&1
  then
    echo -e "\033[40;32mBegin to modify $fstab.\n\033[40;37m"
    echo "$swapfile	 none	 swap sw 0 0" >>$fstab
  else
    echo -e "\033[1;40;31m/etc/fstab is already configured.\n\033[0m"
    rm -rf $LOCKfile
    exit 1
  fi
}

##########start######################
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

os_release=$(check_os_release)
if [ "X$os_release" == "X" ]
then
  echo -e "\033[1;40;31mThe OS does not identify,So this script is not executede.\n\033[0m"
  rm -rf $LOCKfile
  exit 0
else
  echo -e "\033[40;32mStep 2.Check this OS type.\n\033[40;37m"
  echo -e "\033[40;32mThis OS is $os_release.\n\033[40;37m"
fi

swapfile=/var/swap_file
fstab=/etc/fstab

echo -e "\033[40;32mStep 3.Check the memory and swap.\n\033[40;37m"
check_memory_and_swap

echo -e "\033[40;32mStep 4.Begin to modify $fstab.\n\033[40;37m"
case "$os_release" in
redhat|centos)
  config_rhel_fstab
  ;;
ubuntu|debian)
  config_debian_fstab
  ;;
esac

free -m
echo -e "\033[40;32mAll the operations were completed.\n\033[40;37m"
rm -rf $LOCKfile