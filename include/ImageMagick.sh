#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com

Install_ImageMagick() {
  if [ -d "${imagick_install_dir}" ]; then
    echo "${CWARNING}ImageMagick already installed! ${CEND}"
  else
    pushd ${current_dir}/src > /dev/null
    tar xzf ImageMagick-${imagemagick_ver}.tar.gz
    #if [ "${PM}" == 'yum' ]; then
    #  yum -y install libwebp-devel
    #elif [ "${PM}" == 'apt-get' ]; then
    #  yum -y install libwebp-dev
    #fi
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
    pushd ${current_dir}/src > /dev/null
    PHP_detail_ver=$(${php_install_dir}/bin/php-config --version)
    PHP_main_ver=${PHP_detail_ver%.*}
    phpExtensionDir=`${php_install_dir}/bin/php-config --extension-dir`
    if [[ "${PHP_main_ver}" =~ ^5.3$ ]]; then
      src_url=https://pecl.php.net/get/imagick-3.4.4.tgz && Download_src
      tar xzf imagick-3.4.4.tgz
      pushd imagick-3.4.4 > /dev/null
    elif [[ "${PHP_main_ver}" =~ ^5.[4-5]$ ]]; then
      src_url=https://pecl.php.net/get/imagick-3.7.0.tgz && Download_src
      tar xzf imagick-3.7.0.tgz
      pushd imagick-3.7.0 > /dev/null
    else
      src_url=https://pecl.php.net/get/imagick-${imagick_ver}.tgz && Download_src
      tar xzf imagick-${imagick_ver}.tgz
      pushd imagick-${imagick_ver} > /dev/null
    fi
    export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
    ${php_install_dir}/bin/phpize
    ./configure --with-php-config=${php_install_dir}/bin/php-config --with-imagick=${imagick_install_dir}
    make -j ${THREAD} && make install
    popd > /dev/null
    if [ -f "${phpExtensionDir}/imagick.so" ]; then
      echo 'extension=imagick.so' > ${php_install_dir}/etc/php.d/03-imagick.ini
      echo "${CSUCCESS}PHP imagick module installed successfully! ${CEND}"
      rm -rf imagick-${imagick_ver} imagick-3.7.0 imagick-3.4.4
    else
      echo "${CFAILURE}PHP imagick module install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
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
