#!/bin/bash
#
# Startup script for the PHP-FPM server.
#
# chkconfig: 345 85 15
# description: PHP is an HTML-embedded scripting language
# processname: php-fpm
# config: /usr/local/php/lib/php.ini
 
# Source function library.
. /etc/rc.d/init.d/functions
 
PHP_PATH=/usr/local
DESC="php-fpm daemon"
NAME=php-fpm
# php-fpm path
DAEMON=$PHP_PATH/php/sbin/$NAME
# configuration file 
CONFIGFILE=$PHP_PATH/php/etc/php-fpm.conf
# PID file
PIDFILE=$PHP_PATH/php/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME
 
# Gracefully exit if the package has been removed.
test -x $DAEMON || exit 0
 
rh_start() {
  $DAEMON -y $CONFIGFILE || echo -n " already running"
}
 
rh_stop() {
  kill -QUIT `cat $PIDFILE` || echo -n " not running"
}
 
rh_reload() {
  kill -HUP `cat $PIDFILE` || echo -n " can't reload"
}
 
case "$1" in
  start)
        echo -n "Starting $DESC: $NAME"
        rh_start
        echo "."
        ;;
  stop)
        echo -n "Stopping $DESC: $NAME"
        rh_stop
        echo "."
        ;;
  reload)
        echo -n "Reloading $DESC configuration..."
        rh_reload
        echo "reloaded."
  ;;
  restart)
        echo -n "Restarting $DESC: $NAME"
        rh_stop
        sleep 1
        rh_start
        echo "."
        ;;
  *)
         echo "Usage: $SCRIPTNAME {start|stop|restart|reload}" >&2
         exit 3
        ;;
esac
exit 0
