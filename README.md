[![PayPal donate button](https://img.shields.io/badge/paypal-donate-green.svg)](https://paypal.me/yeho) [![支付宝捐助按钮](https://img.shields.io/badge/%E6%94%AF%E4%BB%98%E5%AE%9D-%E5%90%91TA%E6%8D%90%E5%8A%A9-green.svg)](https://static.oneinstack.com/images/alipay.png) [![微信捐助按钮](https://img.shields.io/badge/%E5%BE%AE%E4%BF%A1-%E5%90%91TA%E6%8D%90%E5%8A%A9-green.svg)](https://static.oneinstack.com/images/weixin.png)

This script is written using the shell, in order to quickly deploy `LEMP`/`LAMP`/`LNMP`/`LNMPA`/`LTMP`(Linux, Nginx/Tengine/OpenResty, MySQL in a production environment/MariaDB/Percona, PHP, JAVA), applicable to CentOS 6 ~ 7(including redhat), Debian 6 ~ 9, Ubuntu 12 ~ 18, Fedora 27~28 of 32 and 64.

Script properties:
- Continually updated, Provide Shell Interaction and Autoinstall
- Source compiler installation, most stable source is the latest version, and download from the official site
- Some security optimization
- Providing a plurality of database versions (MySQL-8.0, MySQL-5.7, MySQL-5.6, MySQL-5.5, MariaDB-10.3, MariaDB-10.2, MariaDB-10.1, MariaDB-10.0, Percona-8.0, Percona-5.7, Percona-5.6, Percona-5.5, AliSQL-5.6, PostgreSQL, MongoDB)
- Providing multiple PHP versions (PHP-7.3, PHP-7.2, PHP-7.1, PHP-7.0, PHP-5.6, PHP-5.5, PHP-5.4, PHP-5.3)
- Provide Nginx, Tengine, OpenResty and ngx_lua_waf
- Providing a plurality of Apache version (Apache-2.4, Apache-2.2)
- According to their needs to install PHP Cache Accelerator provides ZendOPcache, xcache, apcu, eAccelerator. And php extensions,include ZendGuardLoader,ionCube,SourceGuardian,imagick,gmagick,fileinfo,imap,ldap,phalcon,redis,memcached,memcache,mongodb,swoole,xdebug
- Installation Pureftpd, phpMyAdmin according to their needs
- Install memcached, redis according to their needs
- Jemalloc optimize MySQL, Nginx
- Providing add a virtual host script, include Let's Encrypt SSL certificate
- Provide Nginx/Tengine/OpenResty/Apache, MySQL/MariaDB/Percona, PHP, Redis, Memcached, phpMyAdmin upgrade script
- Provide local,remote(rsync between servers),Aliyun OSS,Qcloud COS,UPYUN,QINIU,Amazon S3,Google Drive and Dropbox backup script
- Provided under HHVM install CentOS 6,7

## How to use

If your server system: CentOS/Redhat (Do not enter "//" and "// subsequent sentence)
```bash
yum -y install wget screen   // For CentOS / Redhat
wget http://mirrors.linuxeye.com/lnmp-full.tar.gz   // Contains the source code
tar xzf lnmp-full.tar.gz
cd lnmp    // If you need to modify the directory (installation, data storage, Nginx logs), modify options.conf file
screen -S lnmp    // if network interruption, you can execute the command `screen -r lnmp` reconnect install window
./install.sh
```
If your server system: Debian/Ubuntu (Do not enter "//" and "// subsequent sentence)
```bash
apt-get -y install wget screen   // For Debian / Ubuntu
wget http://mirrors.linuxeye.com/lnmp-full.tar.gz   // Contains the source code
tar xzf lnmp-full.tar.gz
cd lnmp    // If you need to modify the directory (installation, data storage, Nginx logs), modify options.conf file
screen -S lnmp    // if network interruption, you can execute the command `screen -r lnmp` reconnect install window
./install.sh
```

## How to add Extensions

```bash
~/lnmp/addons.sh
```

## How to add a virtual host

```bash
~/lnmp/vhost.sh
```

## How to delete a virtual host

```bash
~/lnmp/vhost.sh --del
```

## How to add FTP virtual user 

```bash
~/lnmp/pureftpd_vhost.sh
```

## How to backup

```bash
~/lnmp/backup_setup.sh    // Backup parameters 
~/lnmp/backup.sh    // Perform the backup immediately 
crontab -l    // Can be added to scheduled tasks, such as automatic backups every day 1:00 
  0 1 * * * ~/lnmp/backup.sh  > /dev/null 2>&1 &
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
PostgreSQL:
```bash
service postgresql {start|stop|restart|status}
```
MongoDB:
```bash
service mongod {start|stop|status|restart|reload}
```
PHP:
```bash
service php-fpm {start|stop|restart|reload|status}
```
HHVM:
```bash
#centos7
systemctl {start|stop|status|restart} hhvm
#centos6
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
~/lnmp/upgrade.sh
```

## How to uninstall 

```bash
~/lnmp/uninstall.sh
```

## Installation

Follow the instructions in [Wiki Installation page](https://github.com/oneinstack/lnmp/wiki/Installation)<br />

For feedback, questions, and to follow the progress of the project: <br />
[Telegram Group](https://t.me/oneinstack)<br />
[lnmp最新源码一键安装脚本](https://blog.linuxeye.cn/31.html)<br />
