   This script is free collection of shell scripts for rapid deployment of lnmp stacks (`Linux`, `Nginx`, `MySQL`/`MariaDB` and `PHP`) for CentOS/Redhat and Ubuntu.

   Script features: 
- Constant updates 
- Source compiler installation, most source code is the latest stable version, and downloaded from the official website
- Fixes some security issues 
- You can freely choose to install database version (MySQL-5.6, MySQL-5.5, MariaDB-5.5) 
- You can freely choose to install PHP version (php-5.5, php-5.4, php-5.3)
- According to their needs can to install ZendOPcache,eAccelerator (php-5.4, php-5.3) 
- According to their needs can to install Pureftpd, phpMyAdmin
- According to their needs can to install memcached, redis
- According to their needs can to install ngx_pagespeed
- According to their needs can to optimize MySQL and Nginx with tcmalloc or jemalloc 
- Add a virtual host script provided 

## How to use 

```bash
   yum -y install wget screen # for CentOS/Redhat
   #apt-get -y install wget screen # for Ubuntu 
   wget http://blog.linuxeye.com/lnmp.tar.gz
   #or wget http://blog.linuxeye.com/lnmp-full.tar.gz # include source packages
   tar xzf lnmp.tar.gz
   cd lnmp
   chmod +x lnmp_install.sh
   # Prevent interrupt the installation process. If the network is down, you can execute commands `srceen -r lnmp` network reconnect the installation window.
   # Если сеть не работает, вы можете выполнять команды `srceen -r lnmp` сети подключить установку окна.
   # 如果网路出现中断，可以执行命令`srceen -r lnmp`重新连接安装窗口
   screen -S lnmp
   ./lnmp_install.sh
```

## How to add a virtual host

```bash
   ./vhost.sh
```

   For feedback, questions, and to follow the progress of the project (Chinese): <br />
   [lnmp最新源码一键安装脚本](http://blog.linuxeye.com/31.html)<br />
   [odvps](http://odvps.ml)
