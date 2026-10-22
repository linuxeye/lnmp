#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com

DEMO() {
  pushd ${current_dir}/src > /dev/null
  if [ ! -e ${wwwroot_dir}/default/index.html ]; then 
    /bin/cp ${current_dir}/config/index.html ${wwwroot_dir}/default/
  fi

  if [ -e "${php_install_dir}/bin/php" ]; then
    src_url=${mirror_link}/src/xprober.php && Download_src
    /bin/cp xprober.php ${wwwroot_dir}/default

    echo "<?php phpinfo() ?>" > ${wwwroot_dir}/default/phpinfo.php
    case "${phpcache_option}" in
      1)
        src_url=${mirror_link}/src/ocp.php && Download_src
        /bin/cp ocp.php ${wwwroot_dir}/default
        ;;
      4)
        /bin/cp eaccelerator-*/control.php ${wwwroot_dir}/default
        ;;
    esac
  fi
  chown -R ${run_user}:${run_group} ${wwwroot_dir}/default
  [ -e /bin/systemctl ] && systemctl daemon-reload
  popd > /dev/null
}
