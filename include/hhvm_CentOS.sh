#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://blog.linuxeye.cn
#
# Notes: OneinStack for CentOS/RadHat 6+ Debian 6+ and Ubuntu 12+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/lj2007331/oneinstack

Install_hhvm_CentOS() {

  id -u ${run_user} >/dev/null 2>&1
  [ $? -ne 0 ] && useradd -M -s /sbin/nologin ${run_user}

  if [ "${CentOS_ver}" == '7' ]; then
    [ ! -e /etc/yum.repos.d/epel.repo ] && cat > /etc/yum.repos.d/epel.repo << EOF
[epel]
name=Extra Packages for Enterprise Linux 7 - \$basearch
#baseurl=http://download.fedoraproject.org/pub/epel/7/\$basearch
mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=\$basearch
failovermethod=priority
enabled=1
gpgcheck=0
EOF
    cat > /etc/yum.repos.d/hhvm.repo << EOF
[hhvm]
name=gleez hhvm-repo
baseurl=http://mirrors.linuxeye.com/hhvm-repo/7/\$basearch/
enabled=1
gpgcheck=0
EOF
    yum -y install hhvm
    [ ! -e "/usr/bin/hhvm" -a "/usr/local/bin/hhvm" ] && ln -s /usr/local/bin/hhvm /usr/bin/hhvm
  fi

  if [ "${CentOS_ver}" == '6' ]; then
    [ ! -e /etc/yum.repos.d/epel.repo ] && cat > /etc/yum.repos.d/epel.repo << EOF
[epel]
name=Extra Packages for Enterprise Linux 6 - \$basearch
#baseurl=http://download.fedoraproject.org/pub/epel/6/\$basearch
mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=\$basearch
failovermethod=priority
enabled=1
gpgcheck=0
EOF
    # Install needed packages
    pkgList="libmcrypt-devel glog-devel jemalloc-devel tbb-devel libdwarf-devel libxml2-devel libicu-devel pcre-devel gd-devel boost-devel sqlite-devel pam-devel bzip2-devel oniguruma-devel openldap-devel readline-devel libc-client-devel libcap-devel libevent-devel libcurl-devel libmemcached-devel lcms2 inotify-tools"
    for Package in ${pkgList}; do
      yum -y install ${Package}
    done
    # Uninstall the conflicting packages
    yum -y remove libwebp boost-system boost-filesystem

    cat > /etc/yum.repos.d/hhvm.repo << EOF
[hhvm]
name=gleez hhvm-repo
baseurl=http://mirrors.linuxeye.com/hhvm-repo/6/\$basearch/
enabled=1
gpgcheck=0
EOF
    yum --disablerepo=epel -y install mysql mysql-devel mysql-libs
    yum --disablerepo=epel -y install hhvm
  fi

  userdel -r nginx;userdel -r saslauth
  rm -rf /var/log/hhvm
  mkdir /var/log/hhvm
  chown -R ${run_user}.${run_user} /var/log/hhvm
  cat > /etc/hhvm/config.hdf << EOF
ResourceLimit {
  CoreFileSize = 0          # in bytes
  MaxSocket = 10000         # must be not 0, otherwise HHVM will not start
  SocketDefaultTimeout = 5  # in seconds
  MaxRSS = 0
  MaxRSSPollingCycle = 0    # in seconds, how often to check max memory
  DropCacheCycle = 0        # in seconds, how often to drop disk cache
}

Log {
  Level = Info
  AlwaysLogUnhandledExceptions = true
  RuntimeErrorReportingLevel = 8191
  UseLogFile = true
  UseSyslog = false
  File = /var/log/hhvm/error.log
  Access {
    * {
      File = /var/log/hhvm/access.log
      Format = %h %l %u % t \"%r\" %>s %b
    }
  }
}

MySQL {
  ReadOnly = false
  ConnectTimeout = 1000      # in ms
  ReadTimeout = 1000         # in ms
  SlowQueryThreshold = 1000  # in ms, log slow queries as errors
  KillOnTimeout = false
}

Mail {
  SendmailPath = /usr/sbin/sendmail -t -i
  ForceExtraParameters =
}
EOF

  cat > /etc/hhvm/server.ini << EOF
; php options
pid = /var/log/hhvm/pid

; hhvm specific
;hhvm.server.port = 9001
hhvm.server.file_socket = /var/log/hhvm/sock
hhvm.server.type = fastcgi
hhvm.server.default_document = index.php
hhvm.log.use_log_file = true
hhvm.log.file = /var/log/hhvm/error.log
hhvm.repo.central.path = /var/log/hhvm/hhvm.hhbc
EOF

  cat > /etc/hhvm/php.ini << EOF
hhvm.mysql.socket = /tmp/mysql.sock
expose_php = 0
memory_limit = 400000000
post_max_size = 50000000
EOF

  if [ -e "${web_install_dir}/sbin/nginx" -a -e "/usr/bin/hhvm" -a ! -e "${php_install_dir}" ]; then
    sed -i 's@/dev/shm/php-cgi.sock@/var/log/hhvm/sock@' ${web_install_dir}/conf/nginx.conf
    [ -z "$(grep 'fastcgi_param SCRIPT_FILENAME' ${web_install_dir}/conf/nginx.conf)" ] && sed -i "s@fastcgi_index index.php;@&\n\t\tfastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;@" ${web_install_dir}/conf/nginx.conf
    sed -i 's@include fastcgi.conf;@include fastcgi_params;@' ${web_install_dir}/conf/nginx.conf
    service nginx reload
  fi

  rm -rf /etc/ld.so.conf.d/*_64.conf
  ldconfig
  # Supervisor
  yum -y install python-setuptools
  ping pypi.python.org -c 4 >/dev/null 2>&1
  easy_install supervisor
  echo_supervisord_conf > /etc/supervisord.conf
  sed -i 's@pidfile=/tmp/supervisord.pid@pidfile=/var/run/supervisord.pid@' /etc/supervisord.conf
  [ -z "$(grep 'program:hhvm' /etc/supervisord.conf)" ] && cat >> /etc/supervisord.conf << EOF
[program:hhvm]
command=/usr/bin/hhvm --mode server --user ${run_user} --config /etc/hhvm/server.ini --config /etc/hhvm/php.ini --config /etc/hhvm/config.hdf
numprocs=1 ; number of processes copies to start (def 1)
directory=/tmp ; directory to cwd to before exec (def no cwd)
autostart=true ; start at supervisord start (default: true)
autorestart=unexpected ; whether/when to restart (default: unexpected)
stopwaitsecs=10 ; max num secs to wait b4 SIGKILL (default 10)
EOF
  /bin/cp ${oneinstack_dir}/init.d/Supervisor-init-CentOS /etc/init.d/supervisord
  chmod +x /etc/init.d/supervisord
  chkconfig supervisord on
  service supervisord start
}
