#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_ImageMagick() {
  pushd ${oneinstack_dir}/src > /dev/null
  tar xzf ImageMagick-${imagemagick_ver}.tar.gz
  pushd ImageMagick-${imagemagick_ver}
  ./configure --prefix=${imagick_install_dir} --enable-shared --enable-static
  make -j ${THREAD} && make install
  popd
  rm -rf ImageMagick-${imagemagick_ver}
  popd
}

Install_php-imagick() {
  pushd ${oneinstack_dir}/src > /dev/null
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    phpExtensionDir=`${php_install_dir}/bin/php-config --extension-dir`
    tar xzf imagick-${imagick_ver}.tgz
    pushd imagick-${imagick_ver}
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
    ${php_install_dir}/bin/phpize
    ./configure --with-php-config=${php_install_dir}/bin/php-config --with-imagick=${imagick_install_dir}
    make -j ${THREAD} && make install
    popd
    if [ -f "${phpExtensionDir}/imagick.so" ]; then
      echo 'extension=imagick.so' > ${php_install_dir}/etc/php.d/03-imagick.ini
      echo "${CSUCCESS}PHP imagick module installed successfully! ${CEND}"
      rm -rf imagick-${imagick_ver}
    else
      echo "${CFAILURE}PHP imagick module install failed, Please contact the author! ${CEND}"
    fi
  fi
  popd
}
