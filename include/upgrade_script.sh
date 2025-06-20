#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com

Upgrade_Script() {
  pushd ${current_dir} > /dev/null
  latest_md5=$(curl --connect-timeout 3 -m 5 -s ${mirror_link}/md5sum.txt | grep lnmp.tar.gz | awk '{print $1}')
  [ ! -e README.md ] && ois_flag=n
  if [ "${script_md5}" != "${latest_md5}" ]; then
    /bin/mv options.conf /tmp
    sed -i '/current_dir=/d' /tmp/options.conf
    [ -e /tmp/lnmp.tar.gz ] && rm -rf /tmp/lnmp.tar.gz
    wget --no-check-certificate -qc ${mirror_link}/lnmp.tar.gz -O /tmp/lnmp.tar.gz
    tar xzf /tmp/lnmp.tar.gz -C /tmp
    /bin/cp -R /tmp/lnmp/* ${current_dir}/
    /bin/rm -rf /tmp/lnmp
    IFS=$'\n'
    for L in `grep -vE '^#|^$' /tmp/options.conf`
    do
      IFS=$IFS_old
      Key="`echo ${L%%=*}`"
      Value="`echo ${L#*=}`"
      sed -i "s|^${Key}=.*|${Key}=${Value}|" ./options.conf
    done
    rm -rf /tmp/{lnmp.tar.gz,options.conf}
    [ "${ois_flag}" == "n" ] && rm -f ss.sh LICENSE README.md
    sed -i "s@^script_md5=.*@script_md5=${latest_md5}@" ./options.conf
    if [ -e "${php_install_dir}/sbin/php-fpm" ]; then
      [ -n "`grep ^cgi.fix_pathinfo=0 ${php_install_dir}/etc/php.ini`" ] && sed -i 's@^cgi.fix_pathinfo.*@;&@' ${php_install_dir}/etc/php.ini
      [ -e "/usr/local/php53/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php53/etc/php.ini 2>/dev/null
      [ -e "/usr/local/php54/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php54/etc/php.ini 2>/dev/null
      [ -e "/usr/local/php55/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php55/etc/php.ini 2>/dev/null
      [ -e "/usr/local/php56/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php56/etc/php.ini 2>/dev/null
      [ -e "/usr/local/php70/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php70/etc/php.ini 2>/dev/null
      [ -e "/usr/local/php71/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php71/etc/php.ini 2>/dev/null
      [ -e "/usr/local/php72/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php72/etc/php.ini 2>/dev/null
      [ -e "/usr/local/php73/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php73/etc/php.ini 2>/dev/null
      [ -e "/usr/local/php74/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php74/etc/php.ini 2>/dev/null
      [ -e "/usr/local/php80/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php80/etc/php.ini 2>/dev/null
      [ -e "/usr/local/php81/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php81/etc/php.ini 2>/dev/null
      [ -e "/usr/local/php82/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php82/etc/php.ini 2>/dev/null
      [ -e "/usr/local/php83/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php83/etc/php.ini 2>/dev/null
      [ -e "/usr/local/php84/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php84/etc/php.ini 2>/dev/null
    fi
    [ -e "/lib/systemd/system/php-fpm.service" ] && { sed -i 's@^PrivateTmp.*@#&@g' /lib/systemd/system/php-fpm.service; systemctl daemon-reload; }
    echo
    echo "${CSUCCESS}Congratulations! LNMP upgrade successful! ${CEND}"
    echo
  else
    echo "${CWARNING}Your LNMP already has the latest version or does not need to be upgraded! ${CEND}"
  fi
  [ ! -e "${current_dir}/options.conf" ] && [ -e "/tmp/options.conf" ] && /bin/cp /tmp/options.conf ${current_dir}/options.conf
  popd > /dev/null
}
