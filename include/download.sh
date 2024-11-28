#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: LNMP for CentOS/RedHat 7+ Debian 9+ and Ubuntu 16+
#

Download_src() {
  [ -s "${src_url##*/}" ] && echo "[${CMSG}${src_url##*/}${CEND}] found" || { wget --limit-rate=100M --tries=6 -c --no-check-certificate ${src_url}; sleep 1; }
  if [ ! -e "${src_url##*/}" ]; then
    echo "${CFAILURE}Auto download failed! You can manually download ${src_url} into the oneinstack/src directory.${CEND}"
    kill -9 $$; exit 1;
  fi
}
