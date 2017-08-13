#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_ImageMagick() {
  pushd ${oneinstack_dir}/src
  tar xzf ImageMagick-${ImageMagick_version}.tar.gz
  pushd ImageMagick-${ImageMagick_version}
  ./configure --prefix=/usr/local/imagemagick --enable-shared --enable-static
  make -j ${THREAD} && make install
  popd
  rm -rf ImageMagick-${ImageMagick_version}
  popd
}

Install_php-imagick() {
  pushd ${oneinstack_dir}/src
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    phpExtensionDir=`${php_install_dir}/bin/php-config --extension-dir`
    tar xzf imagick-${imagick_version}.tgz
    pushd imagick-${imagick_version}
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
    ${php_install_dir}/bin/phpize
    ./configure --with-php-config=${php_install_dir}/bin/php-config --with-imagick=/usr/local/imagemagick
    make -j ${THREAD} && make install
    popd
    if [ -f "${phpExtensionDir}/imagick.so" ]; then
      echo 'extension=imagick.so' > ${php_install_dir}/etc/php.d/ext-imagick.ini
      echo "${CSUCCESS}PHP imagick module installed successfully! ${CEND}"
      rm -rf imagick-${imagick_version}
    else
      echo "${CFAILURE}PHP imagick module install failed, Please contact the author! ${CEND}"
    fi
  fi
  popd
}
