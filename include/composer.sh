#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com

Install_composer() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    if [ -e "/usr/local/bin/composer" ]; then
      echo "${CWARNING}PHP Composer already installed! ${CEND}"
    else
      pushd ${current_dir}/src > /dev/null
      if [ "${OUTIP_STATE}"x == "China"x ]; then
        wget --no-check-certificate -c https://mirrors.aliyun.com/composer/composer.phar -O /usr/local/bin/composer > /dev/null 2>&1
        ${php_install_dir}/bin/php /usr/local/bin/composer config -g repo.packagist composer https://packagist.phpcomposer.com
      else
        wget --no-check-certificate -c https://getcomposer.org/composer.phar -O /usr/local/bin/composer > /dev/null 2>&1
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
