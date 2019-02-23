#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 6+ Debian 7+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_ImageMagick() {
  if [ -d "${imagick_install_dir}" ]; then
    echo "${CWARNING}ImageMagick already installed! ${CEND}"
  else
    pushd ${oneinstack_dir}/src > /dev/null
    tar xzf ImageMagick-${imagemagick_ver}.tar.gz
    pushd ImageMagick-${imagemagick_ver} > /dev/null
    ./configure --prefix=${imagick_install_dir} --enable-shared --enable-static
    make -j ${THREAD} && make install
    popd > /dev/null
    rm -rf ImageMagick-${imagemagick_ver}
    popd > /dev/null
  fi
}

Uninstall_ImageMagick() {
  if [ -d "${imagick_install_dir}" ]; then
    rm -rf ${imagick_install_dir} 
    echo; echo "${CMSG}ImageMagick uninstall completed${CEND}"
  fi
}

Install_pecl_imagick() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    phpExtensionDir=`${php_install_dir}/bin/php-config --extension-dir`
    tar xzf imagick-${imagick_ver}.tgz
    pushd imagick-${imagick_ver} > /dev/null
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
    ${php_install_dir}/bin/phpize
    ./configure --with-php-config=${php_install_dir}/bin/php-config --with-imagick=${imagick_install_dir}
    make -j ${THREAD} && make install
    popd > /dev/null
    if [ -f "${phpExtensionDir}/imagick.so" ]; then
      echo 'extension=imagick.so' > ${php_install_dir}/etc/php.d/03-imagick.ini
      echo "${CSUCCESS}PHP imagick module installed successfully! ${CEND}"
      rm -rf imagick-${imagick_ver}
    else
      echo "${CFAILURE}PHP imagick module install failed, Please contact the author! ${CEND}"
    fi
    popd > /dev/null
  fi
}

Uninstall_pecl_imagick() {
  if [ -e "${php_install_dir}/etc/php.d/03-imagick.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/03-imagick.ini
    echo; echo "${CMSG}PHP imagick module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP imagick module does not exist! ${CEND}"
  fi
}
