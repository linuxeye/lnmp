#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 7+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_composer() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    if [ -e "/usr/local/bin/composer" ]; then
      echo "${CWARNING}PHP Composer already installed! ${CEND}"
    else
      pushd ${oneinstack_dir}/src > /dev/null
      # get the IP information
      PUBLIC_IPADDR=$(../include/get_public_ipaddr.py)
      IPADDR_COUNTRY=$(../include/get_ipaddr_state.py ${PUBLIC_IPADDR})
      if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
        wget -c https://dl.laravel-china.org/composer.phar -O /usr/local/bin/composer > /dev/null 2>&1
        ${php_install_dir}/bin/php /usr/local/bin/composer config -g repo.packagist composer https://packagist.phpcomposer.com
      else
        wget -c https://getcomposer.org/composer.phar -O /usr/local/bin/composer > /dev/null 2>&1
      fi
      chmod +x /usr/local/bin/composer
      if [ -e "/usr/local/bin/composer" ]; then
        echo; echo "${CSUCCESS}PHP Composer installed successfully! ${CEND}"
      else
        echo; echo "${CFAILURE}PHP Composer install failed, Please try again! ${CEND}"
      fi
      popd > /dev/null
    fi
  fi
}

Uninstall_composer() {
  if [ -e "/usr/local/bin/composer" ]; then
    rm -f /usr/local/bin/composer
    echo; echo "${CMSG}Composer uninstall completed${CEND}";
  else
    echo; echo "${CWARNING}Composer does not exist! ${CEND}"
  fi
}
