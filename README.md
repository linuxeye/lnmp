[![PayPal donate button](https://img.shields.io/badge/paypal-donate-green.svg)](https://paypal.me/yeho)[![支付宝捐助按钮](https://img.shields.io/badge/%E6%94%AF%E4%BB%98%E5%AE%9D-%E5%90%91TA%E6%8D%90%E5%8A%A9-green.svg)](https://static.oneinstack.com/images/alipay.png)[![微信捐助按钮](https://img.shields.io/badge/%E5%BE%AE%E4%BF%A1-%E5%90%91TA%E6%8D%90%E5%8A%A9-green.svg)](https://static.oneinstack.com/images/weixin.png)

This script is written using the shell, in order to quickly deploy `LEMP`/`LAMP`/`LNMP`/`LNMPA`(Linux, Nginx/Tengine/OpenResty, MySQL in a production environment/MariaDB/Percona, PHP), applicable to CentOS 5~7(including redhat), Debian 6~8, Ubuntu 12~16 of 32 and 64. 

Script properties:
- Continually updated
- Source compiler installation, most stable source is the latest version, and download from the official site
- Some security optimization
- Providing a plurality of database versions (MySQL-5.7, MySQL-5.6, MySQL-5.5, MariaDB-10.1, MariaDB-10.0, MariaDB-5.5, Percona-5.7, Percona-5.6, Percona-5.5, AliSQL-5.6)
- Providing multiple PHP versions (PHP-7.1, PHP-7.0, PHP-5.6, PHP-5.5, PHP-5.4, PHP-5.3)
- Provide Nginx, Tengine, OpenResty
- Providing a plurality of Apache version (Apache-2.4, Apache-2.2)
- According to their needs to install PHP Cache Accelerator provides ZendOPcache, xcache, apcu, eAccelerator. And php encryption and decryption tool ionCube, ZendGuardLoader
- Installation Pureftpd, phpMyAdmin according to their needs
- Install memcached, redis according to their needs
- Jemalloc optimize MySQL, Nginx
- Providing add a virtual host script, include Let's Encrypt SSL certificate
- Provide Nginx/Tengine/OpenResty, MySQL/MariaDB/Percona, PHP, Redis, Memcached, phpMyAdmin upgrade script
- Provide local backup and remote backup (rsync between servers) script
- Provided under HHVM install CentOS 6,7

## How to use

If your server system: CentOS/Redhat (Do not enter "//" and "// subsequent sentence)
```bash
yum -y install wget screen python   // For CentOS / Redhat
wget http://mirrors.linuxeye.com/lnmp-full.tar.gz   // Contains the source code
tar xzf lnmp-full.tar.gz
cd lnmp    // If you need to modify the directory (installation, data storage, Nginx logs), modify options.conf file
screen -S lnmp    // if network interruption, you can execute the command `screen -r lnmp` reconnect install window
./install.sh   // Do not sh install.sh or bash install.sh such execution
```
If your server system: Debian/Ubuntu (Do not enter "//" and "// subsequent sentence)
```bash
apt-get -y install wget screen python   // For Debian / Ubuntu
wget http://mirrors.linuxeye.com/lnmp-full.tar.gz   // Contains the source code
tar xzf lnmp-full.tar.gz
cd lnmp    // If you need to modify the directory (installation, data storage, Nginx logs), modify options.conf file
screen -S lnmp    // if network interruption, you can execute the command `screen -r lnmp` reconnect install window
./install.sh   // Do not sh install.sh or bash install.sh such execution
```

## How to add Extensions

```bash
cd ~/lnmp    // Must enter the directory execution under lnmp
./addons.sh    // Do not sh addons.sh or bash addons.sh such execution
```

## How to add a virtual host

```bash
cd ~/lnmp    // Must enter the directory execution under lnmp
./vhost.sh    // Do not sh vhost.sh or bash vhost.sh such execution
```

## How to delete a virtual host

```bash
cd ~/lnmp
./vhost.sh del
```

## How to add FTP virtual user 

```bash
cd ~/lnmp
./pureftpd_vhost.sh
```

## How to backup

```bash
cd ~/lnmp
./backup_setup.sh    // Backup parameters 
./backup.sh    // Perform the backup immediately 
crontab -l    // Can be added to scheduled tasks, such as automatic backups every day 1:00 
  0 1 * * * cd ~/lnmp;./backup.sh  > /dev/null 2>&1 &
```

## How to manage service

Nginx/Tengine/OpenResty:
```bash
service nginx {start|stop|status|restart|reload|configtest}
```
MySQL/MariaDB/Percona:
```bash
service mysqld {start|stop|restart|reload|status}
```
PHP:
```bash
service php-fpm {start|stop|restart|reload|status}
```
HHVM:
```bash
service supervisord {start|stop|status|restart|reload}
```
Apache:
```bash
service httpd {start|restart|stop}
```
Pure-Ftpd:
```bash
service pureftpd {start|stop|restart|status}
```
Redis:
```bash
service redis-server {start|stop|status|restart|reload}
```
Memcached:
```bash
service memcached {start|stop|status|restart|reload}
```

## How to upgrade 

```bash
./upgrade.sh
```

## How to uninstall 

```bash
./uninstall.sh
```

## Installation

Follow the instructions in [Wiki Installation page](https://github.com/lj2007331/lnmp/wiki/Installation)<br />

For feedback, questions, and to follow the progress of the project (Chinese): <br />
[lnmp最新源码一键安装脚本](https://blog.linuxeye.com/31.html)<br />
