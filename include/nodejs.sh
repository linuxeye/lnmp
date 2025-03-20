#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com

Install_Nodejs() {
  pushd ${current_dir}/src > /dev/null
  tar xzf node-v${nodejs_ver}-linux-${SYS_ARCH_n}.tar.gz
  /bin/mv node-v${nodejs_ver}-linux-${SYS_ARCH_n} ${nodejs_install_dir}
  if [ -e "${nodejs_install_dir}/bin/node" ]; then
    cat > /etc/profile.d/nodejs.sh << EOF
export NODE_HOME=${nodejs_install_dir}
export PATH=\$NODE_HOME/bin:\$PATH
EOF
    . /etc/profile
    echo "${CSUCCESS}Nodejs installed successfully! ${CEND}"
  else
    echo "${CFAILURE}Nodejs install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
    kill -9 $$; exit 1;
  fi
  popd > /dev/null
}

Uninstall_Nodejs() {
  if [ -e "${nodejs_install_dir}" ]; then
    rm -rf ${nodejs_install_dir} /etc/profile.d/nodejs.sh
    echo "${CMSG}Nodejs uninstall completed! ${CEND}"
  fi
}

