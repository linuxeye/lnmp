   This script is free collection of shell scripts for rapid deployment of lnmp stacks (`Linux`, `Nginx`, `MySQL`/`MariaDB` and `PHP`) for CentOS/Redhat and Ubuntu.

   Script features: 
- Constant updates 
- Source compiler installation, most source code is the latest stable version, and downloaded from the official website
- Fixes some security issues 
- You can freely choose to install MySQL database (MySQL-5.5, MySQL-5.6) or MariaDB (MariaDB-5.5) 
- You can freely choose to install PHP version (php-5.5, php-5.4, php-5.3)
- According to their needs can choose to install Pureftpd, phpMyAdmin
- According to their needs can choose to install memcached, redis
- According to their needs can choose to install ngx_pagespeed
- According to their needs can choose to install eAccelerator (php-5.4, php-5.3) 
- Add a virtual host script provided 

## How to use 

```bash
   yum -y install wget screen # for CentOS/Redhat
   #apt-get -y install wget screen # for Ubuntu 
   wget http://blog.linuxeye.com/wp-content/uploads/lnmp.tar.gz
   #or wget http://blog.linuxeye.com/wp-content/uploads/lnmp-full.tar.gz # include source packages
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
   # Does not have ngx_pagespeed function add a virtual host ,You need to run
   ./vhost.sh
   # Add a virtual host with ngx_pagespeed functionality ,you need to run (must be installed ngx_pagespeed)
   ./vhost_ngx_pagespeed.sh
```

   For feedback, questions, and to follow the progress of the project (Chinese): <br />
   [lnmp最新源码一键安装脚本](http://blog.linuxeye.com/31.html)
   [nightgod](http://odvps.ml)
