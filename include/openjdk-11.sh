#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_OpenJDK11() {
  if [ "${LikeOS}" == 'RHEL' ]; then
    yum -y install java-11-openjdk-devel
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk
  elif [ "${LikeOS}" == 'Debian' ]; then
    if [[ "${Debian_ver}" =~ ^8$ ]]; then
      #wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | sudo apt-key add -
      cat ${oneinstack_dir}/src/adoptopenjdk.key | sudo apt-key add -
      apt-add-repository --yes https://mirrors.tuna.tsinghua.edu.cn/AdoptOpenJDK/deb
      apt -y update
      apt-get --no-install-recommends -y install adoptopenjdk-11-hotspot
      JAVA_HOME=/usr/lib/jvm/adoptopenjdk-11-hotspot-${SYS_ARCH}
    else
      apt-get --no-install-recommends -y install openjdk-11-jdk
      JAVA_HOME=/usr/lib/jvm/java-11-openjdk-${SYS_ARCH}
    fi
  elif [ "${LikeOS}" == 'Ubuntu' ]; then
    if [[ "${Ubuntu_ver}" =~ ^16$ ]]; then
      cat ${oneinstack_dir}/src/adoptopenjdk.key | sudo apt-key add -
      apt-add-repository --yes https://mirrors.tuna.tsinghua.edu.cn/AdoptOpenJDK/deb
      apt -y update
      apt-get --no-install-recommends -y install adoptopenjdk-11-hotspot
      JAVA_HOME=/usr/lib/jvm/adoptopenjdk-11-hotspot-${SYS_ARCH}
    else
      apt-get --no-install-recommends -y install openjdk-11-jdk
      JAVA_HOME=/usr/lib/jvm/java-11-openjdk-${SYS_ARCH}
    fi
  fi
  if [ -e "${JAVA_HOME}/bin/java" ]; then
    cat > /etc/profile.d/openjdk.sh << EOF
export JAVA_HOME=${JAVA_HOME}
export CLASSPATH=\$JAVA_HOME/lib/tools.jar:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib
EOF
    . /etc/profile.d/openjdk.sh
    echo "${CSUCCESS}OpenJDK11 installed successfully! ${CEND}"
  else
    echo "${CFAILURE}OpenJDK11 install failed, Please contact the author! ${CEND}" && lsb_release -a
    kill -9 $$; exit 1;
  fi
}
