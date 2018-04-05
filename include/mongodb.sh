#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_MongoDB() {
  pushd ${oneinstack_dir}/src > /dev/null
  id -u mongod >/dev/null 2>&1
  [ $? -ne 0 ] && useradd -s /sbin/nologin mongod
  mkdir -p ${mongo_data_dir};chown mongod.mongod -R ${mongo_data_dir}
  tar xzf mongodb-linux-${SYS_BIT_b}-${mongodb_ver}.tgz
  /bin/mv mongodb-linux-${SYS_BIT_b}-${mongodb_ver} ${mongo_install_dir}
  [ "${OS}" == "CentOS" ] && { /bin/cp ../init.d/MongoDB-init-CentOS /etc/init.d/mongod; sed -i "s@/usr/local/mongodb@${mongo_install_dir}@g" /etc/init.d/mongod; chkconfig --add mongod; chkconfig mongod on; }
  [[ "${OS}" =~ ^Ubuntu$|^Debian$ ]] && { /bin/cp ../init.d/MongoDB-init-Ubuntu /etc/init.d/mongod; sed -i "s@/usr/local/mongodb@${mongo_install_dir}@g" /etc/init.d/mongod; update-rc.d mongod defaults; }
  cat > /etc/mongod.conf << EOF
# mongod.conf

# for documentation of all options, see:
#   http://docs.mongodb.org/manual/reference/configuration-options/

# where to write logging data.
systemLog:
  destination: file
  logAppend: true
  path: ${mongo_data_dir}/mongod.log

# Where and how to store data.
storage:
  dbPath: ${mongo_data_dir}
  journal:
    enabled: true
#  engine:
#  mmapv1:
#  wiredTiger:

# how the process runs
processManagement:
  fork: true  # fork and run in background
  pidFilePath: /var/run/mongodb/mongod.pid

# network interfaces
net:
  port: 27017
  bindIp: 0.0.0.0
  unixDomainSocket:
    enabled: false

#security:
#  authorization: enabled

#operationProfiling:
#replication:
#sharding:
EOF
  service mongod start
  echo ${mongo_install_dir}/bin/mongo 127.0.0.1/admin --eval \"db.createUser\(\{user:\'root\',pwd:\'$dbmongopwd\',roles:[\'userAdminAnyDatabase\']\}\)\" | bash
  sed -i 's@^#security:@security:@' /etc/mongod.conf
  sed -i 's@^#  authorization:@  authorization:@' /etc/mongod.conf
  if [ -e "${mongo_install_dir}/bin/mongo" ]; then
    sed -i "s+^dbmongopwd.*+dbmongopwd='$dbmongopwd'+" ../options.conf
    echo "${CSUCCESS}MongoDB installed successfully! ${CEND}"
    rm -rf mongodb-linux-${SYS_BIT_b}-${mongodb_ver}
  else
    rm -rf ${mongo_install_dir} ${mongo_data_dir} mongodb-linux-${SYS_BIT_b}-${mongodb_ver}
    echo "${CFAILURE}MongoDB install failed, Please contact the author! ${CEND}"
    kill -9 $$
  fi
  popd
  [ -z "$(grep ^'export PATH=' /etc/profile)" ] && echo "export PATH=${mongo_install_dir}/bin:\$PATH" >> /etc/profile
  [ -n "$(grep ^'export PATH=' /etc/profile)" -a -z "$(grep ${mongo_install_dir} /etc/profile)" ] && sed -i "s@^export PATH=\(.*\)@export PATH=${mongo_install_dir}/bin:\1@" /etc/profile
  . /etc/profile
}
