#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.com
#
# Notes: OneinStack for CentOS/RadHat 5+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_htop() {
    if [ "$OS" == 'CentOS' ]; then
      sudo yum install htop
    elif [[ $OS =~ ^Ubuntu$|^Debian$ ]]; then
      sudo apt-get install htop -yf
    fi
}
