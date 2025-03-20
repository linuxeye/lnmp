#!/bin/bash
### BEGIN INIT INFO
# Provides:          tomcat
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: tomcat-server daemon
# Description:       tomcat-server daemon
### END INIT INFO
#
# chkconfig: - 95 15
# description: Tomcat start/stop/status script

#Location of JAVA_HOME (bin files)
export JAVA_HOME=

#Add Java binary files to PATH
export PATH=$JAVA_HOME/bin:$PATH

#CATALINA_HOME is the location of the configuration files of this instance of Tomcat
CATALINA_HOME=/usr/local/tomcat

#TOMCAT_USER is the default user of tomcat
TOMCAT_USER=www

#TOMCAT_USAGE is the message if this script is called without any options
TOMCAT_USAGE="Usage: $0 {\e[00;32mstart\e[00m|\e[00;31mstop\e[00m|\e[00;32mstatus\e[00m|\e[00;31mrestart\e[00m}"

#SHUTDOWN_WAIT is wait time in seconds for java proccess to stop
SHUTDOWN_WAIT=20

tomcat_pid() {
  echo `ps -ef | grep java | grep $CATALINA_HOME/ | grep -v grep | tr -s " "|cut -d" " -f2`
}

start() {
  pid=$(tomcat_pid)
  if [ -n "$pid" ]; then
    echo -e "\e[00;31mTomcat is already running (pid: $pid)\e[00m"
  else
    echo -e "\e[00;32mStarting tomcat\e[00m"
    if [ `user_exists $TOMCAT_USER` = "1" ]; then
      su $TOMCAT_USER -c $CATALINA_HOME/bin/startup.sh
    else
      $CATALINA_HOME/bin/startup.sh
    fi
    status
  fi
  return 0
}

status() {
  pid=$(tomcat_pid)
  if [ -n "$pid" ]; then
    echo -e "\e[00;32mTomcat is running with pid: $pid\e[00m"
  else
    echo -e "\e[00;31mTomcat is not running\e[00m"
  fi
}

stop() {
  pid=$(tomcat_pid)
  if [ -n "$pid" ]; then
    echo -e "\e[00;31mStoping Tomcat\e[00m"
    $CATALINA_HOME/bin/shutdown.sh

    let kwait=$SHUTDOWN_WAIT
    count=0;
    until [ `ps -p $pid | grep -c $pid` = '0' ] || [ $count -gt $kwait ]
    do
      echo -n -e "\e[00;31mwaiting for processes to exit\e[00m\n";
      sleep 1
      let count=$count+1;
    done

    if [ $count -gt $kwait ]; then
      echo -n -e "\n\e[00;31mkilling processes which didn't stop after $SHUTDOWN_WAIT seconds\e[00m"
      kill -9 $pid
    fi
  else
    echo -e "\e[00;31mTomcat is not running\e[00m"
  fi

  return 0
}

user_exists() {
  if id -u $1 >/dev/null 2>&1; then
	islogin=`cat /etc/passwd | grep ^${TOMCAT_USER}: | grep nologin$`
	if [ "${islogin: -7}" = "nologin" ]; then
      echo "0"
    else
      echo "1"	
    fi
  else
    echo "0"
  fi
}

case $1 in
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
    status
    ;;
  *)
    echo -e $TOMCAT_USAGE
    ;;
esac
exit 0
