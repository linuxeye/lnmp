#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com

Install_OpenJDK8() {
  if [ "${Family}" == 'rhel' ]; then
    yum -y install java-1.8.0-openjdk-devel
    JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk
  elif [ "${Family}" == 'debian' ]; then
    if [[ "${Debian_ver}" =~ ^10$|^11$ ]]; then
      #wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add -
      cat ${current_dir}/src/adoptium.key | sudo apt-key add -
      apt-add-repository --yes https://mirrors.tuna.tsinghua.edu.cn/Adoptium/deb
      apt -y update
      apt-get --no-install-recommends -y install temurin-8-jdk
      JAVA_HOME=/usr/lib/jvm/temurin-8-jdk-${SYS_ARCH}
    elif [[ "${Debian_ver}" =~ ^9$ ]]; then
      apt-get --no-install-recommends -y install openjdk-8-jdk
      JAVA_HOME=/usr/lib/jvm/java-8-openjdk-${SYS_ARCH}
    fi
  elif [ "${Family}" == 'ubuntu' ]; then
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
    echo "${CFAILURE}OpenJDK8 install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
    kill -9 $$; exit 1;
  fi
}
