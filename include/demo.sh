#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

DEMO() {
  pushd ${oneinstack_dir}/src > /dev/null
  [ "${IPADDR_COUNTRY}"x == "CN"x ] && /bin/cp ${oneinstack_dir}/config/index_cn.html ${wwwroot_dir}/default/index.html || /bin/cp ${oneinstack_dir}/config/index.html ${wwwroot_dir}/default

  if [ -e "${php_install_dir}/bin/php" ]; then
    if [ "${IPADDR_COUNTRY}"x == "CN"x ]; then
      src_url=http://mirrors.linuxeye.com/oneinstack/src/tz.zip && Download_src
      unzip -q tz.zip -d ${wwwroot_dir}/default
    else
      src_url=http://mirrors.linuxeye.com/oneinstack/src/tz_e.zip && Download_src
      unzip -q tz_e.zip -d ${wwwroot_dir}/default;/bin/mv ${wwwroot_dir}/default/{tz_e.php,prober.php}
    fi

    echo "<?php phpinfo() ?>" > ${wwwroot_dir}/default/phpinfo.php
    case "${phpcache_option}" in
      1)
        src_url=http://mirrors.linuxeye.com/oneinstack/src/ocp.php && Download_src
        /bin/cp ocp.php ${wwwroot_dir}/default
        ;;
      2)
        sed -i 's@<a href="/ocp.php" target="_blank" class="links">Opcache</a>@<a href="/xcache" target="_blank" class="links">xcache</a>@' ${wwwroot_dir}/default/index.html
        ;;
      3)
        sed -i 's@<a href="/ocp.php" target="_blank" class="links">Opcache</a>@<a href="/apc.php" target="_blank" class="links">APC</a>@' ${wwwroot_dir}/default/index.html
        ;;
      4)
        /bin/cp eaccelerator-*/control.php ${wwwroot_dir}/default
        sed -i 's@<a href="/ocp.php" target="_blank" class="links">Opcache</a>@<a href="/control.php" target="_blank" class="links">eAccelerator</a>@' ${wwwroot_dir}/default/index.html
        ;;
      *)
        sed -i 's@<a href="/ocp.php" target="_blank" class="links">Opcache</a>@@' ${wwwroot_dir}/default/index.html
        ;;
    esac
  fi
  chown -R ${run_user}.${run_user} ${wwwroot_dir}/default
  [ -e /usr/bin/systemctl ] && systemctl daemon-reload
  popd
}
