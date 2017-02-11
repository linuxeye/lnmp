#!/bin/bash
### BEGIN INIT INFO
# Provides:          pureftpd
# Required-Start:    $local_fs $remote_fs $network $syslog
# Required-Stop:     $local_fs $remote_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Startup script for the pure-ftpd FTP Server
# Description:       pureftpd daemon
### END INIT INFO
# Startup script for the pure-ftpd FTP Server  $Revision: 1.3 $
#
# chkconfig: 2345 85 15
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# description: Pure-FTPd is an FTP server daemon based upon Troll-FTPd
# processname: pure-ftpd
# pidfile: /var/run/pure-ftpd.pid
# config: /usr/local/pureftpd/etc/pure-ftpd.conf

# Source function library.
. /etc/rc.d/init.d/functions

RETVAL=0

# Path to the pure-ftp binaries.
prog=pure-ftpd
fullpath=/usr/local/pureftpd/sbin/$prog
pure_config=/usr/local/pureftpd/etc/pure-ftpd.conf

start() {
  echo -n $"Starting $prog: "
  $fullpath $pure_config
  RETVAL=$?
  [ $RETVAL = 0 ] && touch /var/lock/subsys/$prog
  echo
}
stop() {
  echo -n $"Stopping $prog: "
  kill $(cat /var/run/pure-ftpd.pid)
  RETVAL=$?
  [ $RETVAL = 0 ] && rm -f /var/lock/subsys/$prog
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
  restart)
    stop
    start
    ;;
  status)
    status $prog
    ;;
  *)
    echo $"Usage: $prog {start|stop|restart|status}"
    RETVAL=1
esac
exit $RETVAL
