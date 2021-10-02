#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_JDK17() {
  pushd ${oneinstack_dir}/src > /dev/null
  JDK_FILE="jdk-`echo ${jdk17_ver} | awk -F. '{print $2}'`u`echo ${jdk17_ver} | awk -F_ '{print $NF}'`-linux-${SYS_BIT_j}.tar.gz"
  JAVA_dir=/usr/java
  JDK_NAME="jdk${jdk17_ver}"
  JDK_PATH=${JAVA_dir}/${JDK_NAME}
  [ "${PM}" == 'yum' ] && [ -n "`rpm -qa | grep jdk`" ] && rpm -e `rpm -qa | grep jdk`
  [ ! -e ${JAVA_dir} ] && mkdir -p ${JAVA_dir}
  tar xzf ${JDK_FILE} -C ${JAVA_dir}
  if [ -d "${JDK_PATH}" ]; then
    chown -R ${run_user}:${run_group} ${JDK_PATH}
    /bin/cp ${JDK_PATH}/jre/lib/security/cacerts /etc/ssl/certs/java
    [ -z "`grep ^'export JAVA_HOME=' /etc/profile`" ] && { [ -z "`grep ^'export PATH=' /etc/profile`" ] && echo  "export JAVA_HOME=${JDK_PATH}" >> /etc/profile || sed -i "s@^export PATH=@export JAVA_HOME=${JDK_PATH}\nexport PATH=@" /etc/profile; } || sed -i "s@^export JAVA_HOME=.*@export JAVA_HOME=${JDK_PATH}@" /etc/profile
    [ -z "`grep ^'export CLASSPATH=' /etc/profile`" ] && sed -i "s@export JAVA_HOME=\(.*\)@export JAVA_HOME=\1\nexport CLASSPATH=\$JAVA_HOME/lib/tools.jar:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib@" /etc/profile
    [ -n "`grep ^'export PATH=' /etc/profile`" -a -z "`grep '$JAVA_HOME/bin' /etc/profile`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=\$JAVA_HOME/bin:\1@" /etc/profile
    [ -z "`grep ^'export PATH=' /etc/profile | grep '$JAVA_HOME/bin'`" ] && echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile
    . /etc/profile
    echo "${CSUCCESS}$JDK_NAME installed successfully! ${CEND}"
  else
    rm -rf $JAVA_dir
    echo "${CFAILURE}JDK install failed, Please contact the author! ${CEND}" && lsb_release -a
    kill -9 $$; exit 1;
  fi
  popd
}
