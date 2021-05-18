[![PayPal donate button](https://img.shields.io/badge/paypal-donate-green.svg)](https://paypal.me/yeho) [![支付宝捐助按钮](https://img.shields.io/badge/%E6%94%AF%E4%BB%98%E5%AE%9D-%E5%90%91TA%E6%8D%90%E5%8A%A9-green.svg)](https://static.oneinstack.com/images/alipay.png) [![微信捐助按钮](https://img.shields.io/badge/%E5%BE%AE%E4%BF%A1-%E5%90%91TA%E6%8D%90%E5%8A%A9-green.svg)](https://static.oneinstack.com/images/weixin.png)

This script is written using the shell, in order to quickly deploy `LEMP`/`LAMP`/`LNMP`/`LNMPA`/`LTMP`(Linux, Nginx/Tengine/OpenResty, MySQL in a production environment/MariaDB/Percona, PHP, JAVA), applicable to CentOS 7 ~ 8(including redhat), Debian 8 ~ 10, Ubuntu 16 ~ 20, Fedora 27+ of 32 and 64.

Script properties:
- Continually updated, Provide Shell Interaction and Autoinstall
- Source compiler installation, most stable source is the latest version, and download from the official site
- Some security optimization
- Providing a plurality of database versions (MySQL-8.0, MySQL-5.7, MySQL-5.6, MySQL-5.5, MariaDB-10.5, MariaDB-10.4, MariaDB-10.3, MariaDB-5.5, Percona-8.0, Percona-5.7, Percona-5.6, Percona-5.5, PostgreSQL, MongoDB)
- Providing multiple PHP versions (PHP-8.0, PHP-7.4, PHP-7.3, PHP-7.2, PHP-7.1, PHP-7.0, PHP-5.6, PHP-5.5, PHP-5.4, PHP-5.3)
- Provide Nginx, Tengine, OpenResty, Apache and ngx_lua_waf
- Providing a plurality of Tomcat version (Tomcat-10, Tomcat-9, Tomcat-8, Tomcat-7)
- Providing a plurality of JDK version (JDK-11.0, JDK-1.8, JDK-1.7, JDK-1.6)
- According to their needs to install PHP Cache Accelerator provides ZendOPcache, xcache, apcu, eAccelerator. And php extensions,include ZendGuardLoader,ionCube,SourceGuardian,imagick,gmagick,fileinfo,imap,ldap,calendar,phalcon,yaf,yar,redis,memcached,memcache,mongodb,swoole,xdebug
- Installation Pureftpd, phpMyAdmin according to their needs
- Install memcached, redis according to their needs
- Jemalloc optimize MySQL, Nginx
- Providing add a virtual host script, include Let's Encrypt SSL certificate
- Provide Nginx/Tengine/OpenResty/Apache/Tomcat, MySQL/MariaDB/Percona, PHP, Redis, Memcached, phpMyAdmin upgrade script
- Provide local,remote(rsync between servers),Aliyun OSS,Qcloud COS,UPYUN,QINIU,Amazon S3,Google Drive and Dropbox backup script

## Installation

Install the dependencies for your distro, download the source and run the installation script.

#### CentOS/Redhat

```bash
yum -y install wget screen
```

#### Debian/Ubuntu

```bash
apt-get -y install wget screen
```

#### Download Source and Install

```bash
wget http://mirrors.linuxeye.com/oneinstack-full.tar.gz
tar xzf oneinstack-full.tar.gz
cd oneinstack 
```

If you disconnect during installation, you can execute the command `screen -r lnmp` to reconnect to the install window
```bash
screen -S oneinstack 
```

If you need to modify the directory (installation, data storage, Nginx logs), modify `options.conf` file before running install.sh
```bash
./install.sh
```

## How to install another PHP version

```bash
~/oneinstack/install.sh --mphp_ver 54

```

## How to add Extensions

```bash
~/oneinstack/addons.sh

```

## How to add a virtual host

```bash
~/oneinstack/vhost.sh
```

## How to delete a virtual host

```bash
~/oneinstack/vhost.sh --del
```

## How to add FTP virtual user

```bash
~/oneinstack/pureftpd_vhost.sh
```

## How to backup

```bash
~/oneinstack/backup_setup.sh    // Backup parameters
~/oneinstack/backup.sh    // Perform the backup immediately
crontab -l    // Can be added to scheduled tasks, such as automatic backups every day 1:00
  0 1 * * * cd ~/oneinstack/backup.sh  > /dev/null 2>&1 &
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
Apache:
```bash
service httpd {start|restart|stop}
```
Tomcat:
```bash
service tomcat {start|stop|status|restart}
```
Pure-FTPd:
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
~/oneinstack/upgrade.sh
```

## How to uninstall

```bash
~/oneinstack/uninstall.sh
```

## Installation

For feedback, questions, and to follow the progress of the project: <br />
[Telegram Group](https://t.me/oneinstack)<br />
[OneinStack](https://oneinstack.com)<br />
