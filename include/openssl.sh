#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com

if openssl version | grep -Eqi 'OpenSSL 1.0.2*'; then
  php5_with_openssl="--with-openssl"
  php70_with_openssl="--with-openssl"
  php71_with_openssl="--with-openssl"
  php72_with_openssl="--with-openssl"
  php73_with_openssl="--with-openssl"
  php74_with_openssl="--with-openssl"
  php80_with_openssl="--with-openssl"
  php81_with_openssl="--with-openssl"
  php82_with_openssl="--with-openssl"
  php83_with_openssl="--with-openssl"
  php84_with_openssl="--with-openssl"

  php5_with_ssl="--with-ssl"
  php70_with_ssl="--with-ssl"
  php71_with_ssl="--with-ssl"
  php72_with_ssl="--with-ssl"
  php73_with_ssl="--with-ssl"
  php74_with_ssl="--with-ssl"
  php80_with_ssl="--with-ssl"
  php81_with_ssl="--with-ssl"
  php82_with_ssl="--with-ssl"
  php83_with_ssl="--with-ssl"
  php84_with_ssl="--with-ssl"

  php5_with_curl="--with-curl"
  php70_with_curl="--with-curl"
  php71_with_curl="--with-curl"
  php72_with_curl="--with-curl"
  php73_with_curl="--with-curl"
  php74_with_curl="--with-curl"
  php80_with_curl="--with-curl"
  php81_with_curl="--with-curl"
  php82_with_curl="--with-curl"
  php83_with_curl="--with-curl"
  php84_with_curl="--with-curl"
elif openssl version | grep -Eqi 'OpenSSL 1.1.*'; then
  php5_with_openssl="--with-openssl=${openssl_install_dir}"
  php70_with_openssl="--with-openssl"
  php71_with_openssl="--with-openssl"
  php72_with_openssl="--with-openssl"
  php73_with_openssl="--with-openssl"
  php74_with_openssl="--with-openssl"
  php80_with_openssl="--with-openssl"
  php81_with_openssl="--with-openssl"
  php82_with_openssl="--with-openssl"
  php83_with_openssl="--with-openssl"
  php84_with_openssl="--with-openssl"

  php5_with_ssl="--with-ssl=${openssl_install_dir}"
  php70_with_ssl="--with-ssl"
  php71_with_ssl="--with-ssl"
  php72_with_ssl="--with-ssl"
  php73_with_ssl="--with-ssl"
  php74_with_ssl="--with-ssl"
  php80_with_ssl="--with-ssl"
  php81_with_ssl="--with-ssl"
  php82_with_ssl="--with-ssl"
  php83_with_ssl="--with-ssl"
  php84_with_ssl="--with-ssl"

  php5_with_curl="--with-curl=${curl_install_dir}"
  php70_with_curl="--with-curl"
  php71_with_curl="--with-curl"
  php72_with_curl="--with-curl"
  php73_with_curl="--with-curl"
  php74_with_curl="--with-curl"
  php80_with_curl="--with-curl"
  php81_with_curl="--with-curl"
  php82_with_curl="--with-curl"
  php83_with_curl="--with-curl"
  php84_with_curl="--with-curl"
  [[ ${php_option} =~ ^[1-4]$ ]] || [[ "${mphp_ver}" =~ ^5[3-6]$ ]] && with_old_openssl_flag=y
elif openssl version | grep -Eqi 'OpenSSL 3.*'; then
  php5_with_openssl="--with-openssl=${openssl_install_dir}"
  php70_with_openssl="--with-openssl=${openssl_install_dir}"
  php71_with_openssl="--with-openssl"
  php72_with_openssl="--with-openssl"
  php73_with_openssl="--with-openssl"
  php74_with_openssl="--with-openssl"
  php80_with_openssl="--with-openssl"
  php81_with_openssl="--with-openssl"
  php82_with_openssl="--with-openssl"
  php83_with_openssl="--with-openssl"
  php84_with_openssl="--with-openssl"

  php5_with_ssl="--with-ssl=${openssl_install_dir}"
  php70_with_ssl="--with-ssl=${openssl_install_dir}"
  php71_with_ssl="--with-ssl"
  php72_with_ssl="--with-ssl"
  php73_with_ssl="--with-ssl"
  php74_with_ssl="--with-ssl"
  php80_with_ssl="--with-ssl"
  php81_with_ssl="--with-ssl"
  php82_with_ssl="--with-ssl"
  php83_with_ssl="--with-ssl"
  php84_with_ssl="--with-ssl"

  php5_with_curl="--with-curl=${curl_install_dir}"
  php70_with_curl="--with-curl=${curl_install_dir}"
  php71_with_curl="--with-curl"
  php72_with_curl="--with-curl"
  php73_with_curl="--with-curl"
  php74_with_curl="--with-curl"
  php80_with_curl="--with-curl"
  php81_with_curl="--with-curl"
  php82_with_curl="--with-curl"
  php83_with_curl="--with-curl"
  php84_with_curl="--with-curl"
  [[ ${php_option} =~ ^[1-5]$ ]] || [[ "${mphp_ver}" =~ ^5[3-6]$|^70$ ]] && with_old_openssl_flag=y
else
  php5_with_openssl="--with-openssl=${openssl_install_dir}"
  php70_with_openssl="--with-openssl=${openssl_install_dir}"
  php71_with_openssl="--with-openssl=${openssl_install_dir}"
  php72_with_openssl="--with-openssl=${openssl_install_dir}"
  php73_with_openssl="--with-openssl=${openssl_install_dir}"
  php74_with_openssl="--with-openssl=${openssl_install_dir} --with-openssl-dir=${openssl_install_dir}"
  php80_with_openssl="--with-openssl=${openssl_install_dir} --with-openssl-dir=${openssl_install_dir}"
  php81_with_openssl="--with-openssl=${openssl_install_dir} --with-openssl-dir=${openssl_install_dir}"
  php82_with_openssl="--with-openssl=${openssl_install_dir} --with-openssl-dir=${openssl_install_dir}"
  php83_with_openssl="--with-openssl=${openssl_install_dir} --with-openssl-dir=${openssl_install_dir}"
  php84_with_openssl="--with-openssl=${openssl_install_dir} --with-openssl-dir=${openssl_install_dir}"

  php5_with_ssl="--with-ssl=${openssl_install_dir}"
  php70_with_ssl="--with-ssl=${openssl_install_dir}"
  php71_with_ssl="--with-ssl=${openssl_install_dir}"
  php72_with_ssl="--with-ssl=${openssl_install_dir}"
  php73_with_ssl="--with-ssl=${openssl_install_dir}"
  php74_with_ssl="--with-ssl=${openssl_install_dir}"
  php80_with_ssl="--with-ssl=${openssl_install_dir}"
  php81_with_ssl="--with-ssl=${openssl_install_dir}"
  php82_with_ssl="--with-ssl=${openssl_install_dir}"
  php83_with_ssl="--with-ssl=${openssl_install_dir}"
  php84_with_ssl="--with-ssl=${openssl_install_dir}"

  php5_with_curl="--with-curl=${curl_install_dir}"
  php70_with_curl="--with-curl=${curl_install_dir}"
  php71_with_curl="--with-curl=${curl_install_dir}"
  php72_with_curl="--with-curl=${curl_install_dir}"
  php73_with_curl="--with-curl=${curl_install_dir}"
  php74_with_curl="--with-curl=${curl_install_dir}"
  php80_with_curl="--with-curl=${curl_install_dir}"
  php81_with_curl="--with-curl=${curl_install_dir}"
  php82_with_curl="--with-curl=${curl_install_dir}"
  php83_with_curl="--with-curl=${curl_install_dir}"
  php84_with_curl="--with-curl=${curl_install_dir}"
  with_old_openssl_flag=y
fi

Install_openSSL() {
  if [ "${with_old_openssl_flag}" == 'y' ]; then
    if [ ! -e "${openssl_install_dir}/lib/libssl.a" ]; then
      pushd ${current_dir}/src > /dev/null
      tar xzf openssl-1.0.2u.tar.gz
      pushd openssl-1.0.2u > /dev/null
      make clean
      ./config -Wl,-rpath=${openssl_install_dir}/lib -fPIC --prefix=${openssl_install_dir} --openssldir=${openssl_install_dir}
      make depend
      make -j ${THREAD} && make install
      popd > /dev/null
      if [ -f "${openssl_install_dir}/lib/libcrypto.a" ]; then
        echo "${CSUCCESS}openSSL installed successfully! ${CEND}"
        /bin/cp cacert.pem ${openssl_install_dir}/cert.pem
        rm -rf openssl-1.0.2u
      else
        echo "${CFAILURE}openSSL install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
        kill -9 $$; exit 1;
      fi
      popd > /dev/null
    fi
  fi
}
