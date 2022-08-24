#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_OpenJDK8() {
  if [ "${Family}" == 'RHEL' ]; then
    yum -y install java-1.8.0-openjdk-devel
    JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
  elif [ "${Family}" == 'Debian' ]; then
    if [[ "${Debian_ver}" =~ ^8$|^10$|^11$ ]]; then
      #wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add -
      cat ${oneinstack_dir}/src/adoptium.key | sudo apt-key add -
      apt-add-repository --yes https://mirrors.tuna.tsinghua.edu.cn/Adoptium/deb
      apt -y update
      apt-get --no-install-recommends -y install temurin-8-jdk
      JAVA_HOME=/usr/lib/jvm/temurin-8-jdk-${SYS_ARCH}
    elif [[ "${Debian_ver}" =~ ^9$ ]]; then
      apt-get --no-install-recommends -y install openjdk-8-jdk
      JAVA_HOME=/usr/lib/jvm/java-8-openjdk-${SYS_ARCH}
    fi
  elif [ "${Family}" == 'Ubuntu' ]; then
    apt-get --no-install-recommends -y install openjdk-8-jdk
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-${SYS_ARCH}
  fi
  if [ -e "${JAVA_HOME}/bin/java" ]; then
    cat > /etc/profile.d/openjdk.sh << EOF
export JAVA_HOME=${JAVA_HOME}
export CLASSPATH=\$JAVA_HOME/lib/tools.jar:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib
EOF
    . /etc/profile.d/openjdk.sh
    echo "${CSUCCESS}OpenJDK8 installed successfully! ${CEND}"
  else
    echo "${CFAILURE}OpenJDK8 install failed, Please contact the author! ${CEND}" && lsb_release -a
    kill -9 $$; exit 1;
  fi
}
