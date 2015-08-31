#!/bin/bash
#
# supervisord   This scripts turns supervisord on
#
# Author:       Mike McGrath <mmcgrath@redhat.com> (based off yumupdatesd)
#               Jason Koppe <jkoppe@indeed.com> adjusted to read sysconfig,
#                   use supervisord tools to start/stop, conditionally wait
#                   for child processes to shutdown, and startup later
#               Mikhail Mingalev <mingalevme@gmail.com> Merged
#                   redhat-init-jkoppe and redhat-sysconfig-jkoppe, and
#                   made the script "simple customizable".
#               Brendan Maguire <maguire.brendan@gmail.com> Added OPTIONS to
#                   SUPERVISORCTL status call
#
# chkconfig:    345 83 04
#
# description:  supervisor is a process control utility.  It has a web based
#               xmlrpc interface as well as a few other nifty features.
#               Script was originally written by Jason Koppe <jkoppe@indeed.com>.
#

# source function library
. /etc/rc.d/init.d/functions

set -a

PREFIX=/usr

SUPERVISORD=$PREFIX/bin/supervisord
SUPERVISORCTL=$PREFIX/bin/supervisorctl

PIDFILE=/var/run/supervisord.pid
LOCKFILE=/var/lock/subsys/supervisord

OPTIONS="-c /etc/supervisord.conf"

# unset this variable if you don't care to wait for child processes to shutdown before removing the $LOCKFILE-lock
WAIT_FOR_SUBPROCESSES=yes

# remove this if you manage number of open files in some other fashion
ulimit -n 96000

RETVAL=0


running_pid()
{
    # Check if a given process pid's cmdline matches a given name
    pid=$1
    name=$2
    [ -z "$pid" ] && return 1
    [ ! -d /proc/$pid ] && return 1
    (cat /proc/$pid/cmdline | tr "\000" "\n"|grep -q $name) || return 1
    return 0
}

running()
{
# Check if the process is running looking at /proc
# (works for all users)

    # No pidfile, probably no daemon present
    [ ! -f "$PIDFILE" ] && return 1
    # Obtain the pid and check it against the binary name
    pid=`cat $PIDFILE`
    running_pid $pid $SUPERVISORD || return 1
    return 0
}

start() {
        echo "Starting supervisord: "
	
        if [ -e $PIDFILE ]; then 
		echo "ALREADY STARTED"
		return 1
	fi

	# start supervisord with options from sysconfig (stuff like -c)
        $SUPERVISORD $OPTIONS
	
	# show initial startup status
	$SUPERVISORCTL $OPTIONS status
	
	# only create the subsyslock if we created the PIDFILE
        [ -e $PIDFILE ] && touch $LOCKFILE
}

stop() {
        echo -n "Stopping supervisord: "
        $SUPERVISORCTL $OPTIONS shutdown
	if [ -n "$WAIT_FOR_SUBPROCESSES" ]; then 
            echo "Waiting roughly 60 seconds for $PIDFILE to be removed after child processes exit"
            for sleep in  2 2 2 2 4 4 4 4 8 8 8 8 last; do
                if [ ! -e $PIDFILE ] ; then
                    echo "Supervisord exited as expected in under $total_sleep seconds"
                    break
                else
                    if [[ $sleep -eq "last" ]] ; then
                        echo "Supervisord still working on shutting down. We've waited roughly 60 seconds, we'll let it do its thing from here"
                        return 1
                    else
                        sleep $sleep
                        total_sleep=$(( $total_sleep + $sleep ))
                    fi

                fi
            done
        fi

        # always remove the subsys. We might have waited a while, but just remove it at this point.
        rm -f $LOCKFILE
}

restart() {
        stop
        start
}

case "$1" in
    start)
        start
        RETVAL=$?
        ;;
    stop)
        stop
        RETVAL=$?
        ;;
    restart|force-reload)
        restart
        RETVAL=$?
        ;;
    reload)
        $SUPERVISORCTL $OPTIONS reload
        RETVAL=$?
        ;;
    condrestart)
        [ -f $LOCKFILE ] && restart
        RETVAL=$?
        ;;
    status)
        $SUPERVISORCTL $OPTIONS status
        if running ; then
            RETVAL=0
        else
            RETVAL=1
        fi
        ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|reload|force-reload|condrestart}"
        exit 1
esac

exit $RETVAL
