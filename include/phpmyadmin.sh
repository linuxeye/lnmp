#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com

Install_phpMyAdmin() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${current_dir}/src > /dev/null
    PHP_detail_ver=`${php_install_dir}/bin/php-config --version`
    PHP_main_ver=${PHP_detail_ver%.*}
    if [[ "${PHP_main_ver}" =~ ^5.[3-6]$|^7.[0-1]$ ]]; then
      tar xzf phpMyAdmin-4.4.15.10-all-languages.tar.gz
      /bin/mv phpMyAdmin-4.4.15.10-all-languages ${wwwroot_dir}/default/phpMyAdmin
    else
      tar xzf phpMyAdmin-${phpmyadmin_ver}-all-languages.tar.gz
      /bin/mv phpMyAdmin-${phpmyadmin_ver}-all-languages ${wwwroot_dir}/default/phpMyAdmin
    fi
    /bin/cp ${wwwroot_dir}/default/phpMyAdmin/{config.sample.inc.php,config.inc.php}
    mkdir ${wwwroot_dir}/default/phpMyAdmin/{upload,save}
    sed -i "s@UploadDir.*@UploadDir'\] = 'upload';@" ${wwwroot_dir}/default/phpMyAdmin/config.inc.php
    sed -i "s@SaveDir.*@SaveDir'\] = 'save';@" ${wwwroot_dir}/default/phpMyAdmin/config.inc.php
    sed -i "s@host'\].*@host'\] = '127.0.0.1';@" ${wwwroot_dir}/default/phpMyAdmin/config.inc.php
    sed -i "s@blowfish_secret.*;@blowfish_secret\'\] = \'$(cat /dev/urandom | head -1 | base64 | head -c 32)\';@" ${wwwroot_dir}/default/phpMyAdmin/config.inc.php
    chown -R ${run_user}:${run_group} ${wwwroot_dir}/default/phpMyAdmin
    popd > /dev/null
  fi
}
