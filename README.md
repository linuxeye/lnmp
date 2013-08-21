## Introduction

   `Linux`+`Nginx`+`MySQL` (Can Choose to install `MariaDB`)+PHP (Can Choose whether to install `Pureftpd`+`User manager for PureFTPd`+`phpMyAdmin`), Can choose to install ngx_pagespeed after installing lnmp, Installing the module execute scripts `/root/lnmp/install_ngx_pagespeed.sh`. Add a virtual host with ngx_pagespeed module, Please use the script `/root/lnmp/vhost_ngx_pagespeed.sh` (Must be installed ngx_pagespeed module). Do not ngx_pagespeed module, can run the script `/root/lnmp/vhost.sh` Add a virtual host. 
    The script is the new software package using stable version, Fixes some security issues, (Before installation will be performed, Initialize security script) For CentOS/RadHat >=5 or Ubuntu >=12 .Features include:

- Constant updates 
- Source compiler, Almost all of source packages is the latest stable version and downloaded from the official website
- Fixes some security issues 
- Choose to install MySQL or MariaDB database 
- Choose whether to install memcache, Pureftpd, phpMyAdmin 
- Support ngx_pagespeed module (after installing lnmp)
- Add a virtual host script provided 

## How to use 

```bash
   # Please ensure that the downloaded script in the root directory.
   cd /root
   wget http://blog.linuxeye.com/wp-content/uploads/lnmp.tar.gz
   tar xzf lnmp.tar.gz
   cd lnmp
   chmod +x lnmp_install.sh
   # Prevent interrupt the installation process. If the network is down, you can execute commands `srceen -r lnmp` network reconnect the installation window.
   yum -y install screen
   screen -S lnmp
   ./lnmp_install.sh
```

## How to install [ngx_pagespeed](https://github.com/pagespeed/ngx_pagespeed) the module 
   If you need to use ngx_pagespeed module (after installing lnmp), you can run script
```bash
   cd /root/lnmp
   ./install_ngx_pagespeed.sh
```

## How to add a virtual host

```bash
   cd /root/lnmp
   # Does not have ngx_pagespeed function add a virtual host ,You need to run
   ./vhost.sh
   # Add a virtual host with ngx_pagespeed functionality ,you need to run (must be installed ngx_pagespeed)
   ./vhost_ngx_pagespeed.sh
```

## Related definitions and explanations

   Web directory, you can customize, Which default directory to default. (Include `Ftp Manager` `phpinfo.php` `phpMyAdmin`, Rename the directory for security)
```bash
   home_dir=/home/wwwroot
```
   Nginx Generate a log storage directory, you can customize.
```bash
   wwwlogs_dir=/home/wwwlogs 
```
   Database data storage directory, you can customize.
```bash
   db_data_dir=/data/mysql
```

## Program Installation directory (not recommended to change)

   PHP install to the specified directory, For example: /data/webserver/php
   Replaced by the following
```bash
   sed -i 's@/usr/local/php@/data/webserver/php@g' /root/lnmp/lnmp_install.sh
```

   Nginx Install to the specified directory, For example: /data/webserver/nginx 
   Replaced by the following
```bash
   sed -i 's@/usr/local/nginx@/data/webserver/nginx@g' /root/lnmp/vhost.sh
   sed -i 's@/usr/local/nginx@/data/webserver/nginx@g' /root/lnmp/lnmp_install.sh
   sed -i 's@/usr/local/nginx@/data/webserver/nginx@g' /root/lnmp/conf/Nginx-init-*
```

   For feedback, questions, and to follow the progress of the project (Chinese):
   [lnmp最新源码一键安装脚本](http://blog.linuxeye.com/31.html)
