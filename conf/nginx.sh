#!/bin/bash
# Nginnx Startup script for the Nginx HTTP Server
# chkconfig: - 60 50
# description: Nginx is a high-performance web and proxy server.
# processname: nginx
# pidfile: /usr/local/nginx/logs/nginx.pid
# config: /usr/local/nginx/conf/nginx.conf
nginxd=/usr/local/nginx/sbin/nginx
nginx_config=/usr/local/nginx/conf/nginx.conf
nginx_pid=/usr/local/nginx/logs/nginx.pid
RETVAL=0
prog="nginx"
# Source function library.
. /etc/rc.d/init.d/functions
# Source networking configuration.
. /etc/sysconfig/network
# Check that networking is up.
[ ${NETWORKING} = "no" ] && exit 0
[ -x $nginxd ] || exit 0
# Start nginx daemons functions.
start() {
if [ -e $nginx_pid ];then
        echo "nginx already running...."
        exit 1
fi
        echo -n $"Starting $prog: "
        daemon $nginxd -c ${nginx_config}
        RETVAL=$?
        echo
        [ $RETVAL = 0 ] && touch /var/lock/subsys/nginx
        return $RETVAL
        }
# Stop nginx daemons functions.
stop() {
        echo -n $"Stopping $prog: "
        killproc $nginxd
        RETVAL=$?
        echo
        [ $RETVAL = 0 ] && rm -f /var/lock/subsys/nginx $nginx_pid 
        }
# reload nginx service functions.
reload() {
        echo -n $"Reloading $prog: "
        kill -HUP `cat ${nginx_pid}`
        RETVAL=$?
        echo
        }
# See how we were called.
case "$1" in
start)
        start
        ;;
stop)
        stop
        ;;
reload)
        reload
        ;;
restart)
        stop
        start
        ;;
status)
        status $prog
        RETVAL=$?
        ;;
*)
        echo $"Usage: $prog {start|stop|restart|reload|status|help}"
        exit 1
        ;;
esac
exit $RETVAL
