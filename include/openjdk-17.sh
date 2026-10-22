#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com

Install_OpenJDK17() {
  if [ "${Family}" == 'rhel' ]; then
    if [[ "${RHEL_ver}" =~ ^7$ ]]; then
      cat > /etc/yum.repos.d/adoptium.repo << EOF
[Adoptium]
name=Adoptium
baseurl=https://mirrors.tuna.tsinghua.edu.cn/Adoptium/rpm/rhel\$releasever-\$basearch/
enabled=1
gpgcheck=0
EOF
      yum -y install temurin-17-jdk
      JAVA_HOME=/usr/lib/jvm/temurin-17-jdk
    elif [[ "${Platform}" =~ ^hce$ ]]; then
      cat > /etc/yum.repos.d/adoptium.repo << EOF
      [Adoptium]
name=Adoptium
baseurl=https://mirrors.tuna.tsinghua.edu.cn/Adoptium/rpm/rhel8-\$basearch/
enabled=1
gpgcheck=0
EOF
      yum -y install temurin-17-jdk
      JAVA_HOME=/usr/lib/jvm/temurin-17-jdk
    else
      yum -y install java-17-openjdk-devel
      JAVA_HOME=/usr/lib/jvm/java-17-openjdk
    fi
  elif [ "${Family}" == 'debian' ]; then
    if [[ "${Debian_ver}" =~ ^9$|^10$ ]]; then
      #wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add -
      cat ${current_dir}/src/adoptium.key | sudo apt-key add -
      apt-add-repository --yes https://mirrors.tuna.tsinghua.edu.cn/Adoptium/deb
      apt -y update
      apt-get --no-install-recommends -y install temurin-17-jdk
      JAVA_HOME=/usr/lib/jvm/temurin-17-jdk-${SYS_ARCH}
    else
      apt-get --no-install-recommends -y install openjdk-17-jdk
      JAVA_HOME=/usr/lib/jvm/java-17-openjdk-${SYS_ARCH}
    fi
  elif [ "${Family}" == 'ubuntu' ]; then
    if [[ "${Ubuntu_ver}" =~ ^16$ ]]; then
      cat ${current_dir}/src/adoptium.key | sudo apt-key add -
      apt-add-repository --yes https://mirrors.tuna.tsinghua.edu.cn/Adoptium/deb
      apt -y update
      apt-get --no-install-recommends -y install temurin-17-jdk
      JAVA_HOME=/usr/lib/jvm/temurin-17-jdk-${SYS_ARCH}
    else
      apt-get --no-install-recommends -y install openjdk-17-jdk
      JAVA_HOME=/usr/lib/jvm/java-17-openjdk-${SYS_ARCH}
    fi
  fi
  if [ -e "${JAVA_HOME}/bin/java" ]; then
    cat > /etc/profile.d/openjdk.sh << EOF
export JAVA_HOME=${JAVA_HOME}
export CLASSPATH=\$JAVA_HOME/lib/tools.jar:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib
EOF
    . /etc/profile.d/openjdk.sh
    echo "${CSUCCESS}OpenJDK17 installed successfully! ${CEND}"
  else
    echo "${CFAILURE}OpenJDK17 install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
    kill -9 $$; exit 1;
  fi
}
