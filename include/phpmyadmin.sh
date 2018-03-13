#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_phpMyAdmin() {
  pushd ${oneinstack_dir}/src > /dev/null
  tar xzf phpMyAdmin-${phpmyadmin_ver}-all-languages.tar.gz
  /bin/mv phpMyAdmin-${phpmyadmin_ver}-all-languages ${wwwroot_dir}/default/phpMyAdmin
  /bin/cp ${wwwroot_dir}/default/phpMyAdmin/{config.sample.inc.php,config.inc.php}
  mkdir ${wwwroot_dir}/default/phpMyAdmin/{upload,save}
  sed -i "s@UploadDir.*@UploadDir'\] = 'upload';@" ${wwwroot_dir}/default/phpMyAdmin/config.inc.php
  sed -i "s@SaveDir.*@SaveDir'\] = 'save';@" ${wwwroot_dir}/default/phpMyAdmin/config.inc.php
  sed -i "s@blowfish_secret.*;@blowfish_secret\'\] = \'$(cat /dev/urandom | head -1 | base64 | head -c 45)\';@" ${wwwroot_dir}/default/phpMyAdmin/config.inc.php
  chown -R ${run_user}.${run_user} ${wwwroot_dir}/default/phpMyAdmin
  popd
}
