#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_MPHP() {
  if [ -e "${php_install_dir}/sbin/php-fpm" ]; then
    if [ -e "${php_install_dir}${mphp_ver}/bin/phpize" ]; then
      echo "${CWARNING}PHP${mphp_ver} already installed! ${CEND}"
    else
      [ -e "/lib/systemd/system/php-fpm.service" ] && /bin/mv /lib/systemd/system/php-fpm.service{,_bk}
      php_install_dir=${php_install_dir}${mphp_ver}
      case "${mphp_ver}" in
        53)
          . include/php-5.3.sh
          Install_PHP53 2>&1 | tee -a ${oneinstack_dir}/install.log
          ;;
        54)
          . include/php-5.4.sh
          Install_PHP54 2>&1 | tee -a ${oneinstack_dir}/install.log
          ;;
        55)
          . include/php-5.5.sh
          Install_PHP55 2>&1 | tee -a ${oneinstack_dir}/install.log
          ;;
        56)
          . include/php-5.6.sh
          Install_PHP56 2>&1 | tee -a ${oneinstack_dir}/install.log
          ;;
        70)
          . include/php-7.0.sh
          Install_PHP70 2>&1 | tee -a ${oneinstack_dir}/install.log
          ;;
        71)
          . include/php-7.1.sh
          Install_PHP71 2>&1 | tee -a ${oneinstack_dir}/install.log
          ;;
        72)
          . include/php-7.2.sh
          Install_PHP72 2>&1 | tee -a ${oneinstack_dir}/install.log
          ;;
        73)
          . include/php-7.3.sh
          Install_PHP73 2>&1 | tee -a ${oneinstack_dir}/install.log
          ;;
        74)
          . include/php-7.4.sh
          Install_PHP74 2>&1 | tee -a ${oneinstack_dir}/install.log
          ;;
        80)
          . include/php-8.0.sh
          Install_PHP80 2>&1 | tee -a ${oneinstack_dir}/install.log
          ;;
        81)
          . include/php-8.1.sh
          Install_PHP81 2>&1 | tee -a ${oneinstack_dir}/install.log
          ;;
      esac
      if [ -e "${php_install_dir}/sbin/php-fpm" ]; then
        systemctl stop php-fpm
        sed -i "s@/dev/shm/php-cgi.sock@/dev/shm/php${mphp_ver}-cgi.sock@" ${php_install_dir}/etc/php-fpm.conf
        [ -e "/lib/systemd/system/php-fpm.service" ] && /bin/mv /lib/systemd/system/php-fpm.service /lib/systemd/system/php${mphp_ver}-fpm.service
        [ -e "/lib/systemd/system/php-fpm.service_bk" ] && /bin/mv /lib/systemd/system/php-fpm.service{_bk,}
        systemctl enable php${mphp_ver}-fpm
        systemctl enable php-fpm
        systemctl start php-fpm
        systemctl start php${mphp_ver}-fpm
        sed -i "s@${php_install_dir}/bin:@@" /etc/profile
      fi
    fi
  else
    echo "${CWARNING}To use the multiple PHP versions, You need to use PHP-FPM! ${CEND}"
  fi
}
