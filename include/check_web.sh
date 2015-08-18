#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       http://oneinstack.com
#       https://github.com/lj2007331/oneinstack

[ -e "$nginx_install_dir/sbin/nginx" ] && web_install_dir=$nginx_install_dir
[ -e "$tengine_install_dir/sbin/nginx" ] && web_install_dir=$tengine_install_dir
