#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 8+ and Ubuntu 14+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_JDK16() {
  pushd ${oneinstack_dir}/src > /dev/null
  JDK_FILE="jdk-`echo ${jdk16_ver} | awk -F. '{print $2}'`u`echo ${jdk16_ver} | awk -F_ '{print $NF}'`-linux-${SYS_BIT_j}.bin"
  JAVA_dir=/usr/java
  JDK_NAME="jdk${jdk16_ver}"
  JDK_PATH=${JAVA_dir}/${JDK_NAME}
  [ "${PM}" == 'yum' ] && [ -n "`rpm -qa | grep jdk`" ] && rpm -e `rpm -qa | grep jdk`
  chmod +x ${JDK_FILE}
  ./${JDK_FILE}
  [ ! -e ${JAVA_dir} ] && mkdir -p ${JAVA_dir}
  /bin/cp -R ${JDK_NAME} ${JAVA_dir}
  if [ -d "${JDK_PATH}" ]; then
    chown -R ${run_user}.${run_user} ${JDK_PATH}
    [ -z "`grep ^'export JAVA_HOME=' /etc/profile`" ] && { [ -z "`grep ^'export PATH=' /etc/profile`" ] && echo  "export JAVA_HOME=${JDK_PATH}" >> /etc/profile || sed -i "s@^export PATH=@export JAVA_HOME=${JDK_PATH}\nexport PATH=@" /etc/profile; } || sed -i "s@^export JAVA_HOME=.*@export JAVA_HOME=${JDK_PATH}@" /etc/profile
    [ -z "`grep ^'export CLASSPATH=' /etc/profile`" ] && sed -i "s@export JAVA_HOME=\(.*\)@export JAVA_HOME=\1\nexport CLASSPATH=\$JAVA_HOME/lib/tools.jar:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib@" /etc/profile
    [ -n "`grep ^'export PATH=' /etc/profile`" -a -z "`grep '$JAVA_HOME/bin' /etc/profile`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=\$JAVA_HOME/bin:\1@" /etc/profile
    [ -z "`grep ^'export PATH=' /etc/profile | grep '$JAVA_HOME/bin'`" ] && echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/profile
    . /etc/profile
    rm -rf ${JDK_NAME}
    echo "${CSUCCESS}$JDK_NAME installed successfully! ${CEND}"
  else
    echo "${CFAILURE}JDK install failed, Please contact the author! ${CEND}" && lsb_release -a
    kill -9 $$
  fi
  popd
}
