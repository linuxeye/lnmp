#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
clear
printf "
#######################################################################
#       OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+      #
#       For more information please visit https://oneinstack.com      #
#######################################################################
"
# Check if user is root
[ $(id -u) != '0' ] && { echo "${CFAILURE}Error: You must be root to run this script${CEND}"; exit 1; }

oneinstack_dir=$(dirname "`readlink -f $0`")
pushd ${oneinstack_dir} > /dev/null
. ./options.conf
. ./include/color.sh
. ./include/check_dir.sh
. ./include/check_os.sh
. ./include/get_char.sh

Show_Help() {
  echo
  echo "Usage: $0  command ...[parameters]....
  --help, -h                  Show this help message
  --quiet, -q                 quiet operation
  --list, -l                  List Virtualhost
  --mphp_ver [53~80]          Use another PHP version (PATH: /usr/local/php${mphp_ver})
  --proxy                     Use proxy
  --add                       Add Virtualhost
  --delete, --del             Delete Virtualhost
  --httponly                  Use HTTP Only
  --selfsigned                Use your own SSL Certificate and Key
  --letsencrypt               Use Let's Encrypt to Create SSL Certificate and Key
  --dnsapi                    Use dns API to automatically issue Let's Encrypt Cert
  "
}

ARG_NUM=$#
TEMP=`getopt -o hql --long help,quiet,list,proxy,mphp_ver:,add,delete,del,httponly,selfsigned,letsencrypt,dnsapi -- "$@" 2>/dev/null`
[ $? != 0 ] && echo "${CWARNING}ERROR: unknown argument! ${CEND}" && Show_Help && exit 1
eval set -- "${TEMP}"
while :; do
  [ -z "$1" ] && break;
  case "$1" in
    -h|--help)
      Show_Help; exit 0
      ;;
    -q|--quiet)
      quiet_flag=y; shift 1
      ;;
    -l|--list)
      list_flag=y; shift 1
      ;;
    --mphp_ver)
      mphp_ver=$2; mphp_flag=y; shift 2
      [[ ! "${mphp_ver}" =~ ^5[3-6]$|^7[0-4]$|^80$ ]] && { echo "${CWARNING}mphp_ver input error! Please only input number 53~80${CEND}"; unset mphp_ver mphp_flag; }
      ;;
    --proxy)
      proxy_flag=y; shift 1
      ;;
    --add)
      add_flag=y; shift 1
      ;;
    --delete|--del)
      delete_flag=y; shift 1
      ;;
    --httponly)
      sslquiet_flag=y
      httponly_flag=y
      Domian_Mode=1
      shift 1
      ;;
    --selfsigned)
      sslquiet_flag=y
      selfsigned_flag=y
      Domian_Mode=2
      shift 1
      ;;
    --letsencrypt)
      sslquiet_flag=y
      letsencrypt_flag=y
      Domian_Mode=3
      shift 1
      ;;
    --dnsapi)
      sslquiet_flag=y
      dnsapi_flag=y
      letsencrypt_flag=y
      shift 1
      ;;
    --)
      shift
      ;;
    *)
      echo "${CWARNING}ERROR: unknown argument! ${CEND}" && Show_Help && exit 1
      ;;
  esac
done

Choose_ENV() {
  if [ -e "${apache_install_dir}/bin/apachectl" ];then
    [ "$(${apache_install_dir}/bin/apachectl -v | awk -F'.' /version/'{print $2}')" == '4' ] && { Apache_main_ver=24; Apache_grant='Require all granted'; }
    [ "$(${apache_install_dir}/bin/apachectl -v | awk -F'.' /version/'{print $2}')" == '2' ] && Apache_main_ver=22
  fi
  if [ -e "${php_install_dir}/bin/phpize" -a -e "${tomcat_install_dir}/conf/server.xml" ]; then
    Number=11
    while :; do echo
      echo "Please choose to use environment:"
      echo -e "\t${CMSG}1${CEND}. Use php"
      echo -e "\t${CMSG}2${CEND}. Use java"
      read -e -p "Please input a number:(Default 1 press Enter) " ENV_FLAG
      ENV_FLAG=${ENV_FLAG:-1}
      if [[ ! ${ENV_FLAG} =~ ^[1-2]$ ]]; then
        echo "${CWARNING}input error! Please only input number 1~2${CEND}"
      else
        break
      fi
    done
    case "${ENV_FLAG}" in
      1)
        NGX_FLAG=php
        ;;
      2)
        NGX_FLAG=java
        ;;
    esac
  elif [ -e "${php_install_dir}/bin/phpize" -a ! -e "${tomcat_install_dir}/conf/server.xml" ]; then
    Number=10
    NGX_FLAG=php
  elif [ ! -e "${php_install_dir}/bin/phpize" -a -e "${tomcat_install_dir}/conf/server.xml" ]; then
    Number=01
    NGX_FLAG=java
  else
    Number=00
    NGX_FLAG=php
  fi
}

Create_SSL() {
  if [ "${Domian_Mode}" == '2' ]; then
    printf "
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
"
    echo
    read -e -p "Country Name (2 letter code) [CN]: " SELFSIGNEDSSL_C
    SELFSIGNEDSSL_C=${SELFSIGNEDSSL_C:-CN}
    # shellcheck disable=SC2104
    [ ${#SELFSIGNEDSSL_C} != 2 ] && { echo "${CWARNING}input error, You must input 2 letter code country name${CEND}"; continue; }
    echo
    read -e -p "State or Province Name (full name) [Shanghai]: " SELFSIGNEDSSL_ST
    SELFSIGNEDSSL_ST=${SELFSIGNEDSSL_ST:-Shanghai}
    echo
    read -e -p "Locality Name (eg, city) [Shanghai]: " SELFSIGNEDSSL_L
    SELFSIGNEDSSL_L=${SELFSIGNEDSSL_L:-Shanghai}
    echo
    read -e -p "Organization Name (eg, company) [Example Inc.]: " SELFSIGNEDSSL_O
    SELFSIGNEDSSL_O=${SELFSIGNEDSSL_O:-"Example Inc."}
    echo
    read -e -p "Organizational Unit Name (eg, section) [IT Dept.]: " SELFSIGNEDSSL_OU
    SELFSIGNEDSSL_OU=${SELFSIGNEDSSL_OU:-"IT Dept."}

    openssl req -utf8 -new -newkey rsa:2048 -sha256 -nodes -out ${PATH_SSL}/${domain}.csr -keyout ${PATH_SSL}/${domain}.key -subj "/C=${SELFSIGNEDSSL_C}/ST=${SELFSIGNEDSSL_ST}/L=${SELFSIGNEDSSL_L}/O=${SELFSIGNEDSSL_O}/OU=${SELFSIGNEDSSL_OU}/CN=${domain}" > /dev/null 2>&1
    openssl x509 -req -days 36500 -sha256 -in ${PATH_SSL}/${domain}.csr -signkey ${PATH_SSL}/${domain}.key -out ${PATH_SSL}/${domain}.crt > /dev/null 2>&1
  elif [ "${Domian_Mode}" == '3' -o "${dnsapi_flag}" == 'y' ]; then
    if [ "${moredomain}" == "*.${domain}" -o "${dnsapi_flag}" == 'y' ]; then
      while :; do echo
        echo 'Please select DNS provider:'
        echo "${CMSG}dp${CEND},${CMSG}cx${CEND},${CMSG}ali${CEND},${CMSG}cf${CEND},${CMSG}aws${CEND},${CMSG}linode${CEND},${CMSG}he${CEND},${CMSG}namesilo${CEND},${CMSG}dgon${CEND},${CMSG}freedns${CEND},${CMSG}gd${CEND},${CMSG}namecom${CEND} and so on."
        echo "${CMSG}More: https://oneinstack.com/faq/letsencrypt${CEND}"
        read -e -p "Please enter your DNS provider: " DNS_PRO
        if [ -e ~/.acme.sh/dnsapi/dns_${DNS_PRO}.sh ]; then
          break
        else
          echo "${CWARNING}You DNS api mode is not supported${CEND}"
        fi
      done
      while :; do echo
        echo "Syntax: export Key1=Value1 ; export Key2=Value1"
        read -e -p "Please enter your dnsapi parameters: " DNS_PAR
        echo
        eval ${DNS_PAR}
        if [ $? == 0 ]; then
          break
        else
          echo "${CWARNING}Syntax error! PS: export Ali_Key=LTq ; export Ali_Secret=0q5E${CEND}"
        fi
      done
      [ "${moredomainame_flag}" == 'y' ] && moredomainame_D="$(for D in ${moredomainame}; do echo -d ${D}; done)"
      ~/.acme.sh/acme.sh --force --listen-v4 --issue --dns dns_${DNS_PRO} -d ${domain} ${moredomainame_D}
    else
      if [ "${nginx_ssl_flag}" == 'y' ]; then
        [ ! -d ${web_install_dir}/conf/vhost ] && mkdir ${web_install_dir}/conf/vhost
        echo "server {  server_name ${domain}${moredomainame};  root ${vhostdir};  access_log off; }" > ${web_install_dir}/conf/vhost/${domain}.conf
        ${web_install_dir}/sbin/nginx -s reload
      fi
      if [ "${apache_ssl_flag}" == 'y' ]; then
        [ ! -d ${apache_install_dir}/conf/vhost ] && mkdir ${apache_install_dir}/conf/vhost
        cat > ${apache_install_dir}/conf/vhost/${domain}.conf << EOF
<VirtualHost *:80>
  ServerAdmin admin@example.com
  DocumentRoot "${vhostdir}"
  ServerName ${domain}
  ${Apache_Domain_alias}
<Directory "${vhostdir}">
  SetOutputFilter DEFLATE
  Options FollowSymLinks ExecCGI
  ${Apache_grant}
  AllowOverride All
  Order allow,deny
  Allow from all
  DirectoryIndex index.html index.php
</Directory>
</VirtualHost>
EOF
        ${apache_install_dir}/bin/apachectl -k graceful
      fi
      auth_file="`< /dev/urandom tr -dc A-Za-z0-9 | head -c8`".html
      auth_str='oneinstack'; echo ${auth_str} > ${vhostdir}/${auth_file}
      for D in ${domain} ${moredomainame}
      do
        curl_str=`curl --connect-timeout 30 -4 -s $D/${auth_file} 2>&1`
        [ "${curl_str}" != "${auth_str}" ] && { echo; echo "${CFAILURE}Let's Encrypt Verify error! DNS problem: NXDOMAIN looking up A for ${D}${CEND}"; }
      done
      rm -f ${vhostdir}/${auth_file}
      [ "${moredomainame_flag}" == 'y' ] && moredomainame_D="$(for D in ${moredomainame}; do echo -d ${D}; done)"
      ~/.acme.sh/acme.sh --force --listen-v4 --issue -d ${domain} ${moredomainame_D} -w ${vhostdir}
    fi
    if [ -s ~/.acme.sh/${domain}/fullchain.cer ]; then
      [ -e "${PATH_SSL}/${domain}.crt" ] && rm -f ${PATH_SSL}/${domain}.{crt,key}
      [ -e /bin/systemctl -a -e /lib/systemd/system/nginx.service ] && Nginx_cmd='/bin/systemctl restart nginx' || Nginx_cmd='/etc/init.d/nginx force-reload'
      Apache_cmd="${apache_install_dir}/bin/apachectl -k graceful"
      if [ -e "${web_install_dir}/sbin/nginx" -a -e "${apache_install_dir}/bin/httpd" ]; then
        Command="${Nginx_cmd};${Apache_cmd}"
      elif [ -e "${web_install_dir}/sbin/nginx" -a ! -e "${apache_install_dir}/bin/httpd" ]; then
        Command="${Nginx_cmd}"
      elif [ ! -e "${web_install_dir}/sbin/nginx" -a -e "${apache_install_dir}/bin/httpd" ]; then
        Command="${Apache_cmd}"
      fi
      ~/.acme.sh/acme.sh --force --install-cert -d ${domain} --fullchain-file ${PATH_SSL}/${domain}.crt --key-file ${PATH_SSL}/${domain}.key --reloadcmd "${Command}" > /dev/null
    else
      echo "${CFAILURE}Error: Create Let's Encrypt SSL Certificate failed! ${CEND}"
      [ -e "${web_install_dir}/conf/vhost/${domain}.conf" ] && rm -f ${web_install_dir}/conf/vhost/${domain}.conf
      [ -e "${apache_install_dir}/conf/vhost/${domain}.conf" ] && rm -f ${apache_install_dir}/conf/vhost/${domain}.conf
      exit 1
    fi
  fi
}

Print_SSL() {
  if [ "${Domian_Mode}" == '2' ]; then
    echo "$(printf "%-30s" "Self-signed SSL Certificate:")${CMSG}${PATH_SSL}/${domain}.crt${CEND}"
    echo "$(printf "%-30s" "SSL Private Key:")${CMSG}${PATH_SSL}/${domain}.key${CEND}"
    echo "$(printf "%-30s" "SSL CSR File:")${CMSG}${PATH_SSL}/${domain}.csr${CEND}"
  elif [ "${Domian_Mode}" == '3' -o "${dnsapi_flag}" == 'y' ]; then
    echo "$(printf "%-30s" "Let's Encrypt SSL Certificate:")${CMSG}${PATH_SSL}/${domain}.crt${CEND}"
    echo "$(printf "%-30s" "SSL Private Key:")${CMSG}${PATH_SSL}/${domain}.key${CEND}"
  fi
}

Input_Add_proxy() {
  while :; do echo
    read -e -p "Please input the correct proxy_pass: " Proxy_Pass
    if [ -z "$(echo $Proxy_Pass | grep -E '^http://|https://')" ]; then
      echo "${CFAILURE}input error! Please only input example http://192.168.1.1:8080${CEND}"
    else
      echo "proxy_pass=${Proxy_Pass}"
      break
    fi
  done
}

Input_Add_domain() {
  if [ "${sslquiet_flag}" != 'y' ]; then
    while :;do
      printf "
What Are You Doing?
\t${CMSG}1${CEND}. Use HTTP Only
\t${CMSG}2${CEND}. Use your own SSL Certificate and Key
\t${CMSG}3${CEND}. Use Let's Encrypt to Create SSL Certificate and Key
\t${CMSG}q${CEND}. Exit
"
      read -e -p "Please input the correct option: " Domian_Mode
      if [[ ! "${Domian_Mode}" =~ ^[1-3,q]$ ]]; then
        echo "${CFAILURE}input error! Please only input 1~3 and q${CEND}"
      else
        break
      fi
    done
  fi

  #Multiple_PHP
  if [ $(ls /dev/shm/php*-cgi.sock 2> /dev/null | wc -l) -ge 2 ]; then
    if [ "${mphp_flag}" != 'y' ]; then
      PHP_detail_ver=`${php_install_dir}/bin/php-config --version`
      PHP_main_ver=${PHP_detail_ver%.*}
      while :; do echo
        echo 'Please select a version of the PHP:'
        echo -e "\t${CMSG} 0${CEND}. PHP ${PHP_main_ver} (default)"
        [ -e "/dev/shm/php53-cgi.sock" ] && echo -e "\t${CMSG} 1${CEND}. PHP 5.3"
        [ -e "/dev/shm/php54-cgi.sock" ] && echo -e "\t${CMSG} 2${CEND}. PHP 5.4"
        [ -e "/dev/shm/php55-cgi.sock" ] && echo -e "\t${CMSG} 3${CEND}. PHP 5.5"
        [ -e "/dev/shm/php56-cgi.sock" ] && echo -e "\t${CMSG} 4${CEND}. PHP 5.6"
        [ -e "/dev/shm/php70-cgi.sock" ] && echo -e "\t${CMSG} 5${CEND}. PHP 7.0"
        [ -e "/dev/shm/php71-cgi.sock" ] && echo -e "\t${CMSG} 6${CEND}. PHP 7.1"
        [ -e "/dev/shm/php72-cgi.sock" ] && echo -e "\t${CMSG} 7${CEND}. PHP 7.2"
        [ -e "/dev/shm/php73-cgi.sock" ] && echo -e "\t${CMSG} 8${CEND}. PHP 7.3"
        [ -e "/dev/shm/php74-cgi.sock" ] && echo -e "\t${CMSG} 9${CEND}. PHP 7.4"
        [ -e "/dev/shm/php80-cgi.sock" ] && echo -e "\t${CMSG}10${CEND}. PHP 8.0"
        read -e -p "Please input a number:(Default 0 press Enter) " php_option
        php_option=${php_option:-0}
        if [[ ! ${php_option} =~ ^[0-9]$|^10$ ]]; then
          echo "${CWARNING}input error! Please only input number 0~10${CEND}"
        else
          break
        fi
      done
    fi
    [ "${php_option}" == '1' ] && mphp_ver=53
    [ "${php_option}" == '2' ] && mphp_ver=54
    [ "${php_option}" == '3' ] && mphp_ver=55
    [ "${php_option}" == '4' ] && mphp_ver=56
    [ "${php_option}" == '5' ] && mphp_ver=70
    [ "${php_option}" == '6' ] && mphp_ver=71
    [ "${php_option}" == '7' ] && mphp_ver=72
    [ "${php_option}" == '8' ] && mphp_ver=73
    [ "${php_option}" == '9' ] && mphp_ver=74
    [ "${php_option}" == '10' ] && mphp_ver=80
    [ ! -e "/dev/shm/php${mphp_ver}-cgi.sock" ] && unset mphp_ver
  fi

  case "${NGX_FLAG}" in
    "php")
      NGX_CONF=$(echo -e "location ~ [^/]\.php(/|$) {\n    #fastcgi_pass remote_php_ip:9000;\n    fastcgi_pass unix:/dev/shm/php${mphp_ver}-cgi.sock;\n    fastcgi_index index.php;\n    include fastcgi.conf;\n  }")
      ;;
    "java")
      NGX_CONF=$(echo -e "location ~ {\n    proxy_pass http://127.0.0.1:8080;\n    include proxy.conf;\n  }")
      ;;
  esac

  if [ "${Domian_Mode}" == '3' -o "${dnsapi_flag}" == 'y' ] && [ ! -e ~/.acme.sh/acme.sh ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    [ ! -e acme.sh-master.tar.gz ] && wget -qc http://mirrors.linuxeye.com/oneinstack/src/acme.sh-master.tar.gz
    tar xzf acme.sh-master.tar.gz
    pushd acme.sh-master > /dev/null
    ./acme.sh --install > /dev/null 2>&1
    popd > /dev/null
    popd > /dev/null
  fi
  [ -e ~/.acme.sh/account.conf ] && sed -i '/^CERT_HOME=/d' ~/.acme.sh/account.conf
  if [[ "${Domian_Mode}" =~ ^[2-3]$ ]] || [ "${dnsapi_flag}" == 'y' ]; then
    if [ -e "${web_install_dir}/sbin/nginx" ]; then
      nginx_ssl_flag=y
      PATH_SSL=${web_install_dir}/conf/ssl
      [ ! -d "${PATH_SSL}" ] && mkdir ${PATH_SSL}
    elif [ ! -e "${web_install_dir}/sbin/nginx" -a -e "${apache_install_dir}/bin/httpd" ]; then
      apache_ssl_flag=y
      PATH_SSL=${apache_install_dir}/conf/ssl
      [ ! -d "${PATH_SSL}" ] && mkdir ${PATH_SSL}
    fi
  elif [ "${Domian_Mode}" == 'q' ]; then
    exit 1
  fi

  while :; do echo
    read -e -p "Please input domain(example: www.example.com): " domain
    if [ -z "$(echo ${domain} | grep '.*\..*')" ]; then
      echo "${CWARNING}Your ${domain} is invalid! ${CEND}"
    else
      break
    fi
  done

  if [ -e "${web_install_dir}/conf/vhost/${domain}.conf" -o -e "${apache_install_dir}/conf/vhost/${domain}.conf" -o -e "${tomcat_install_dir}/conf/vhost/${domain}.xml" ]; then
    [ -e "${web_install_dir}/conf/vhost/${domain}.conf" ] && echo -e "${domain} in the Nginx/Tengine/OpenResty already exist! \nYou can delete ${CMSG}${web_install_dir}/conf/vhost/${domain}.conf${CEND} and re-create"
    [ -e "${apache_install_dir}/conf/vhost/${domain}.conf" ] && echo -e "${domain} in the Apache already exist! \nYou can delete ${CMSG}${apache_install_dir}/conf/vhost/${domain}.conf${CEND} and re-create"
    [ -e "${tomcat_install_dir}/conf/vhost/${domain}.xml" ] && echo -e "${domain} in the Tomcat already exist! \nYou can delete ${CMSG}${tomcat_install_dir}/conf/vhost/${domain}.xml${CEND} and re-create"
    exit
  else
    echo "domain=${domain}"
  fi
  if [[ -z ${proxy_flag} || "${proxy_flag}" != 'y' ]]; then
    while :; do echo
      echo "Please input the directory for the domain:${domain} :"
      read -e -p "(Default directory: ${wwwroot_dir}/${domain}): " vhostdir
      if [ -n "${vhostdir}" -a -z "$(echo ${vhostdir} | grep '^/')" ]; then
        echo "${CWARNING}input error! Press Enter to continue...${CEND}"
      else
        if [ -z "${vhostdir}" ]; then
          vhostdir="${wwwroot_dir}/${domain}"
          echo "Virtual Host Directory=${CMSG}${vhostdir}${CEND}"
        fi
        echo
        echo "Create Virtul Host directory......"
        mkdir -p ${vhostdir}
        echo "set permissions of Virtual Host directory......"
        chown -R ${run_user}:${run_group} ${vhostdir}
        break
      fi
    done
  fi

  while :; do echo
    read -e -p "Do you want to add more domain name? [y/n]: " moredomainame_flag
    if [[ ! ${moredomainame_flag} =~ ^[y,n]$ ]]; then
      echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
      break
    fi
  done

  if [ "${moredomainame_flag}" == 'y' ]; then
    while :; do echo
      read -e -p "Type domainname or IP(example: example.com other.example.com): " moredomain
      if [ -z "$(echo ${moredomain} | grep '.*\..*')" ]; then
        echo "${CWARNING}Your ${domain} is invalid! ${CEND}"
      else
        [ "${moredomain}" == "${domain}" ] && echo "${CWARNING}Domain name already exists! ${CND}" && continue
        echo domain list="$moredomain"
        moredomainame=" $moredomain"
        break
      fi
    done
    Apache_Domain_alias=ServerAlias${moredomainame}
    Tomcat_Domain_alias=$(for D in $(echo ${moredomainame}); do echo "<Alias>${D}</Alias>"; done)

    if [ -e "${web_install_dir}/sbin/nginx" ]; then
      while :; do echo
        read -e -p "Do you want to redirect from ${moredomain} to ${domain}? [y/n]: " redirect_flag
        if [[ ! ${redirect_flag} =~ ^[y,n]$ ]]; then
          echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
        else
          break
        fi
      done
      [ "${redirect_flag}" == 'y' ] && Nginx_redirect="if (\$host != ${domain}) {  return 301 \$scheme://${domain}\$request_uri;  }"
    fi
  fi

  if [ "${nginx_ssl_flag}" == 'y' ]; then
    while :; do echo
      read -e -p "Do you want to redirect all HTTP requests to HTTPS? [y/n]: " https_flag
      if [[ ! ${https_flag} =~ ^[y,n]$ ]]; then
        echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
      else
        break
      fi
    done

    if [[ "$(${web_install_dir}/sbin/nginx -V 2>&1 | grep -Eo 'with-http_v2_module')" = 'with-http_v2_module' ]]; then
      LISTENOPT="443 ssl http2"
    else
      LISTENOPT="443 ssl spdy"
    fi
    Create_SSL
    if [ -n "`ifconfig | grep inet6`" ]; then
      Nginx_conf=$(echo -e "listen 80;\n  listen [::]:80;\n  listen ${LISTENOPT};\n  listen [::]:${LISTENOPT};\n  ssl_certificate ${PATH_SSL}/${domain}.crt;\n  ssl_certificate_key ${PATH_SSL}/${domain}.key;\n  ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;\n  ssl_ciphers TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:TLS13-AES-128-CCM-8-SHA256:TLS13-AES-128-CCM-SHA256:EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;\n  ssl_prefer_server_ciphers on;\n  ssl_session_timeout 10m;\n  ssl_session_cache builtin:1000 shared:SSL:10m;\n  ssl_buffer_size 1400;\n  add_header Strict-Transport-Security max-age=15768000;\n  ssl_stapling on;\n  ssl_stapling_verify on;\n")
    else
      Nginx_conf=$(echo -e "listen 80;\n  listen ${LISTENOPT};\n  ssl_certificate ${PATH_SSL}/${domain}.crt;\n  ssl_certificate_key ${PATH_SSL}/${domain}.key;\n  ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;\n  ssl_ciphers TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:TLS13-AES-128-CCM-8-SHA256:TLS13-AES-128-CCM-SHA256:EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;\n  ssl_prefer_server_ciphers on;\n  ssl_session_timeout 10m;\n  ssl_session_cache builtin:1000 shared:SSL:10m;\n  ssl_buffer_size 1400;\n  add_header Strict-Transport-Security max-age=15768000;\n  ssl_stapling on;\n  ssl_stapling_verify on;\n")
    fi
    Apache_SSL=$(echo -e "SSLEngine on\n  SSLCertificateFile \"${PATH_SSL}/${domain}.crt\"\n  SSLCertificateKeyFile \"${PATH_SSL}/${domain}.key\"")
  elif [ "$apache_ssl_flag" == 'y' ]; then
    Create_SSL
    Apache_SSL=$(echo -e "SSLEngine on\n  SSLCertificateFile \"${PATH_SSL}/${domain}.crt\"\n  SSLCertificateKeyFile \"${PATH_SSL}/${domain}.key\"")
    [ -z "$(grep 'Listen 443' ${apache_install_dir}/conf/httpd.conf)" ] && sed -i "s@Listen 80@&\nListen 443@" ${apache_install_dir}/conf/httpd.conf
    [ -z "$(grep 'ServerName 0.0.0.0:443' ${apache_install_dir}/conf/httpd.conf)" ] && sed -i "s@ServerName 0.0.0.0:80@&\nServerName 0.0.0.0:443@" ${apache_install_dir}/conf/httpd.conf
  else
    if [ -n "`ifconfig | grep inet6`" ]; then
      Nginx_conf=$(echo -e "listen 80;\n  listen [::]:80;")
    else
      Nginx_conf=$(echo -e "listen 80;")
    fi
  fi
}

Nginx_anti_hotlinking() {
  while :; do echo
    read -e -p "Do you want to add hotlink protection? [y/n]: " anti_hotlinking_flag
    if [[ ! ${anti_hotlinking_flag} =~ ^[y,n]$ ]]; then
      echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
      break
    fi
  done

  if [ -n "$(echo ${domain} | grep '.*\..*\..*')" ]; then
    domain_allow="*.${domain#*.} ${domain}"
  else
    domain_allow="*.${domain} ${domain}"
  fi

  if [ "${anti_hotlinking_flag}" == 'y' ]; then
    if [ "${moredomainame_flag}" == 'y' -a "${moredomain}" != "*.${domain}" ]; then
      domain_allow_all=${domain_allow}${moredomainame}
    else
      domain_allow_all=${domain_allow}
    fi
    domain_allow_all=`echo ${domain_allow_all} | tr ' ' '\n' | awk '!a[$1]++' | xargs`
    anti_hotlinking=$(echo -e "location ~ .*\.(wma|wmv|asf|mp3|mmf|zip|rar|jpg|gif|png|swf|flv|mp4)$ {\n    valid_referers none blocked ${domain_allow_all};\n    if (\$invalid_referer) {\n        return 403;\n    }\n  }")
  fi
}

Nginx_rewrite() {
  [ ! -d "${web_install_dir}/conf/rewrite" ] && mkdir ${web_install_dir}/conf/rewrite
  while :; do echo
    read -e -p "Allow Rewrite rule? [y/n]: " rewrite_flag
    if [[ ! "${rewrite_flag}" =~ ^[y,n]$ ]]; then
      echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
      break
    fi
  done
  if [ "${rewrite_flag}" == 'n' ]; then
    rewrite="none"
    touch "${web_install_dir}/conf/rewrite/${rewrite}.conf"
  else
    echo
    echo "Please input the rewrite of programme :"
    echo "${CMSG}wordpress${CEND},${CMSG}opencart${CEND},${CMSG}magento2${CEND},${CMSG}drupal${CEND},${CMSG}joomla${CEND},${CMSG}codeigniter${CEND},${CMSG}laravel${CEND}"
    echo "${CMSG}thinkphp${CEND},${CMSG}pathinfo${CEND},${CMSG}discuz${CEND},${CMSG}typecho${CEND},${CMSG}ecshop${CEND},${CMSG}nextcloud${CEND},${CMSG}zblog${CEND},${CMSG}whmcs${CEND} rewrite was exist."
    read -e -p "(Default rewrite: other): " rewrite
    if [ "${rewrite}" == "" ]; then
      rewrite="other"
    fi
    echo "You choose rewrite=${CMSG}$rewrite${CEND}"
    [ "${NGX_FLAG}" == 'php' -a "${rewrite}" == "joomla" ] && NGX_CONF=$(echo -e "location ~ \\.php\$ {\n    #fastcgi_pass remote_php_ip:9000;\n    fastcgi_pass unix:/dev/shm/php${mphp_ver}-cgi.sock;\n    fastcgi_index index.php;\n    include fastcgi.conf;\n  }")
    [ "${NGX_FLAG}" == 'php' ] && [[ "${rewrite}" =~ ^codeigniter$|^thinkphp$|^pathinfo$ ]] && NGX_CONF=$(echo -e "location ~ [^/]\.php(/|\$) {\n    #fastcgi_pass remote_php_ip:9000;\n    fastcgi_pass unix:/dev/shm/php${mphp_ver}-cgi.sock;\n    fastcgi_index index.php;\n    include fastcgi.conf;\n    fastcgi_split_path_info ^(.+?\.php)(/.*)\$;\n    set \$path_info \$fastcgi_path_info;\n    fastcgi_param PATH_INFO \$path_info;\n    try_files \$fastcgi_script_name =404;    \n  }")
    [ "${NGX_FLAG}" == 'php' -a "${rewrite}" == "typecho" ] && NGX_CONF=$(echo -e "location ~ .*\.php(\/.*)*\$ {\n    #fastcgi_pass remote_php_ip:9000;\n    fastcgi_pass unix:/dev/shm/php${mphp_ver}-cgi.sock;\n    fastcgi_index index.php;\n    include fastcgi.conf;\n    set \$path_info \"\";\n    set \$real_script_name \$fastcgi_script_name;\n    if (\$fastcgi_script_name ~ \"^(.+?\.php)(/.+)\$\") {\n      set \$real_script_name \$1;\n      set \$path_info \$2;\n    }\n    fastcgi_param SCRIPT_FILENAME \$document_root\$real_script_name;\n    fastcgi_param SCRIPT_NAME \$real_script_name;\n    fastcgi_param PATH_INFO \$path_info;\n  }")
    if [[ ! "${rewrite}" =~ ^magento2$|^pathinfo$ ]]; then
      if [ -e "config/${rewrite}.conf" ]; then
        /bin/cp config/${rewrite}.conf ${web_install_dir}/conf/rewrite/${rewrite}.conf
      else
        touch "${web_install_dir}/conf/rewrite/${rewrite}.conf"
      fi
    fi
  fi
}

Nginx_log() {
  while :; do echo
    read -e -p "Allow Nginx/Tengine/OpenResty access_log? [y/n]: " access_flag
    if [[ ! "${access_flag}" =~ ^[y,n]$ ]]; then
      echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
      break
    fi
  done
  if [ "${access_flag}" == 'n' ]; then
    Nginx_log="access_log off;"
  else
    Nginx_log="access_log ${wwwlogs_dir}/${domain}_nginx.log combined;"
    echo "You access log file=${CMSG}${wwwlogs_dir}/${domain}_nginx.log${CEND}"
  fi
}

Create_nginx_tomcat_conf() {
  [ ! -d ${web_install_dir}/conf/vhost ] && mkdir ${web_install_dir}/conf/vhost
  cat > ${web_install_dir}/conf/vhost/${domain}.conf << EOF
server {
  ${Nginx_conf}
  server_name ${domain}${moredomainame};
  ${Nginx_log}
  index index.html index.htm index.jsp;
  root ${vhostdir};
  ${Nginx_redirect}
  #error_page 404 /404.html;
  #error_page 502 /502.html;
  ${anti_hotlinking}
  location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|flv|mp4|ico)$ {
    expires 30d;
    access_log off;
  }
  location ~ .*\.(js|css)?$ {
    expires 7d;
    access_log off;
  }
  location ~ /(\.user\.ini|\.ht|\.git|\.svn|\.project|LICENSE|README\.md) {
    deny all;
  }
  ${NGX_CONF}
}
EOF

  [ "${https_flag}" == 'y' ] && sed -i "s@^root.*;@&\nif (\$ssl_protocol = \"\") { return 301 https://\$host\$request_uri; }@" ${web_install_dir}/conf/vhost/${domain}.conf

  cat > ${tomcat_install_dir}/conf/vhost/${domain}.xml << EOF
<Host name="${domain}" appBase="${vhostdir}" unpackWARs="true" autoDeploy="true"> ${Tomcat_Domain_alias}
  <Context path="" docBase="${vhostdir}" reloadable="false" crossContext="true"/>
  <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
    prefix="${domain}_access_log" suffix=".txt" pattern="%h %l %u %t &quot;%r&quot; %s %b" />
  <Valve className="org.apache.catalina.valves.RemoteIpValve" remoteIpHeader="X-Forwarded-For"
    protocolHeader="X-Forwarded-Proto" protocolHeaderHttpsValue="https"/>
</Host>
EOF
  [ -z "$(grep -o "vhost-${domain} SYSTEM" ${tomcat_install_dir}/conf/server.xml)" ] && sed -i "/vhost-localhost SYSTEM/a<\!ENTITY vhost-${domain} SYSTEM \"file://${tomcat_install_dir}/conf/vhost/${domain}.xml\">" ${tomcat_install_dir}/conf/server.xml
  [ -z "$(grep -o "vhost-${domain};" ${tomcat_install_dir}/conf/server.xml)" ] && sed -i "s@vhost-localhost;@&\n      \&vhost-${domain};@" ${tomcat_install_dir}/conf/server.xml

  echo
  ${web_install_dir}/sbin/nginx -t
  if [ $? == 0 ]; then
    echo "Reload Nginx......"
    ${web_install_dir}/sbin/nginx -s reload
    service tomcat restart
  else
    rm -f ${web_install_dir}/conf/vhost/${domain}.conf
    echo "Create virtualhost ... [${CFAILURE}FAILED${CEND}]"
    exit 1
  fi

  printf "
#######################################################################
#       OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+      #
#       For more information please visit https://oneinstack.com      #
#######################################################################
"
  echo "$(printf "%-30s" "Your domain:")${CMSG}${domain}${CEND}"
  echo "$(printf "%-30s" "Nginx Virtualhost conf:")${CMSG}${web_install_dir}/conf/vhost/${domain}.conf${CEND}"
  echo "$(printf "%-30s" "Tomcat Virtualhost conf:")${CMSG}${tomcat_install_dir}/conf/vhost/${domain}.xml${CEND}"
  echo "$(printf "%-30s" "Directory of:")${CMSG}${vhostdir}${CEND}"
  Print_SSL
}

Create_tomcat_conf() {
  cat > ${tomcat_install_dir}/conf/vhost/${domain}.xml << EOF
<Host name="${domain}" appBase="webapps" unpackWARs="true" autoDeploy="true"> ${Tomcat_Domain_alias}
  <Context path="" docBase="${vhostdir}" reloadable="false" crossContext="true"/>
  <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
    prefix="${domain}_access_log" suffix=".txt" pattern="%h %l %u %t &quot;%r&quot; %s %b" />
</Host>
EOF
  [ -z "$(grep -o "vhost-${domain} SYSTEM" ${tomcat_install_dir}/conf/server.xml)" ] && sed -i "/vhost-localhost SYSTEM/a<\!ENTITY vhost-${domain} SYSTEM \"file://${tomcat_install_dir}/conf/vhost/${domain}.xml\">" ${tomcat_install_dir}/conf/server.xml
  [ -z "$(grep -o "vhost-${domain};" ${tomcat_install_dir}/conf/server.xml)" ] && sed -i "s@vhost-localhost;@&\n      \&vhost-${domain};@" ${tomcat_install_dir}/conf/server.xml

  echo
  service tomcat restart

  printf "
#######################################################################
#       OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+      #
#       For more information please visit https://oneinstack.com      #
#######################################################################
"
  echo "$(printf "%-30s" "Your domain:")${CMSG}${domain}${CEND}"
  echo "$(printf "%-30s" "Tomcat Virtualhost conf:")${CMSG}${tomcat_install_dir}/conf/vhost/${domain}.xml${CEND}"
  echo "$(printf "%-30s" "Directory of:")${CMSG}${vhostdir}${CEND}"
  echo "$(printf "%-30s" "index url:")${CMSG}http://${domain}:8080/${CEND}"
}

Create_nginx_phpfpm_conf() {
  [ ! -d ${web_install_dir}/conf/vhost ] && mkdir ${web_install_dir}/conf/vhost
  cat > ${web_install_dir}/conf/vhost/${domain}.conf << EOF
server {
  ${Nginx_conf}
  server_name ${domain}${moredomainame};
  ${Nginx_log}
  index index.html index.htm index.php;
  root ${vhostdir};
  ${Nginx_redirect}
  include ${web_install_dir}/conf/rewrite/${rewrite}.conf;
  #error_page 404 /404.html;
  #error_page 502 /502.html;
  ${anti_hotlinking}
  ${NGX_CONF}

  location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|flv|mp4|ico)$ {
    expires 30d;
    access_log off;
  }
  location ~ .*\.(js|css)?$ {
    expires 7d;
    access_log off;
  }
  location ~ /(\.user\.ini|\.ht|\.git|\.svn|\.project|LICENSE|README\.md) {
    deny all;
  }
}
EOF

  [ "${rewrite}" == 'pathinfo' ] && sed -i '/pathinfo.conf;$/d' ${web_install_dir}/conf/vhost/${domain}.conf
  if [ "${rewrite}" == 'magento2' -a -e "config/${rewrite}.conf" ]; then
    /bin/cp config/${rewrite}.conf ${web_install_dir}/conf/vhost/${domain}.conf
    sed -i "s@/dev/shm/php-cgi.sock@/dev/shm/php${mphp_ver}-cgi.sock@g" ${web_install_dir}/conf/vhost/${domain}.conf
    sed -i "s@^  set \$MAGE_ROOT.*;@  set \$MAGE_ROOT ${vhostdir};@" ${web_install_dir}/conf/vhost/${domain}.conf
    sed -i "s@^  server_name.*;@  server_name ${domain}${moredomainame};@" ${web_install_dir}/conf/vhost/${domain}.conf
    sed -i "s@^  server_name.*;@&\n  ${Nginx_log}@" ${web_install_dir}/conf/vhost/${domain}.conf
    if [ "${anti_hotlinking_flag}" == 'y' ]; then
      sed -i "s@^  root.*;@&\n  }@" ${web_install_dir}/conf/vhost/${domain}.conf
      sed -i "s@^  root.*;@&\n    }@" ${web_install_dir}/conf/vhost/${domain}.conf
      sed -i "s@^  root.*;@&\n      return 403;@" ${web_install_dir}/conf/vhost/${domain}.conf
      sed -i "s@^  root.*;@&\n      rewrite ^/ http://www.linuxeye.com/403.html;@" ${web_install_dir}/conf/vhost/${domain}.conf
      sed -i "s@^  root.*;@&\n    if (\$invalid_referer) {@" ${web_install_dir}/conf/vhost/${domain}.conf
      sed -i "s@^  root.*;@&\n    valid_referers none blocked ${domain_allow_all};@" ${web_install_dir}/conf/vhost/${domain}.conf
      sed -i "s@^  root.*;@&\n  location ~ .*\.(wma|wmv|asf|mp3|mmf|zip|rar|jpg|gif|png|swf|flv|mp4)\$ {@" ${web_install_dir}/conf/vhost/${domain}.conf
    fi

    [ "${redirect_flag}" == 'y' ] && sed -i "s@^  root.*;@&\n  if (\$host != ${domain}) {  return 301 \$scheme://${domain}\$request_uri;  }@" ${web_install_dir}/conf/vhost/${domain}.conf

    if [ "${nginx_ssl_flag}" == 'y' ]; then
      sed -i "s@^  listen 80;@&\n  listen ${LISTENOPT};@" ${web_install_dir}/conf/vhost/${domain}.conf
      sed -i "s@^  server_name.*;@&\n  ssl_stapling_verify on;@" ${web_install_dir}/conf/vhost/${domain}.conf
      sed -i "s@^  server_name.*;@&\n  ssl_stapling on;@" ${web_install_dir}/conf/vhost/${domain}.conf
      sed -i "s@^  server_name.*;@&\n  add_header Strict-Transport-Security max-age=15768000;@" ${web_install_dir}/conf/vhost/${domain}.conf
      sed -i "s@^  server_name.*;@&\n  ssl_buffer_size 1400;@" ${web_install_dir}/conf/vhost/${domain}.conf
      sed -i "s@^  server_name.*;@&\n  ssl_session_cache builtin:1000 shared:SSL:10m;@" ${web_install_dir}/conf/vhost/${domain}.conf
      sed -i "s@^  server_name.*;@&\n  ssl_session_timeout 10m;@" ${web_install_dir}/conf/vhost/${domain}.conf
      sed -i "s@^  server_name.*;@&\n  ssl_prefer_server_ciphers on;@" ${web_install_dir}/conf/vhost/${domain}.conf
      sed -i "s@^  server_name.*;@&\n  ssl_ciphers TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:TLS13-AES-128-CCM-8-SHA256:TLS13-AES-128-CCM-SHA256:EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:\!MD5;@" ${web_install_dir}/conf/vhost/${domain}.conf
      sed -i "s@^  server_name.*;@&\n  ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;@" ${web_install_dir}/conf/vhost/${domain}.conf
      sed -i "s@^  server_name.*;@&\n  ssl_certificate_key ${PATH_SSL}/${domain}.key;@" ${web_install_dir}/conf/vhost/${domain}.conf
      sed -i "s@^  server_name.*;@&\n  ssl_certificate ${PATH_SSL}/${domain}.crt;@" ${web_install_dir}/conf/vhost/${domain}.conf
    fi
  fi

  [ "${https_flag}" == 'y' ] && sed -i "s@^  root.*;@&\n  if (\$ssl_protocol = \"\") { return 301 https://\$host\$request_uri; }@" ${web_install_dir}/conf/vhost/${domain}.conf

  echo
  ${web_install_dir}/sbin/nginx -t
  if [ $? == 0 ]; then
    echo "Reload Nginx......"
    ${web_install_dir}/sbin/nginx -s reload
  else
    rm -f ${web_install_dir}/conf/vhost/${domain}.conf
    echo "Create virtualhost ... [${CFAILURE}FAILED${CEND}]"
    exit 1
  fi

  printf "
#######################################################################
#       OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+      #
#       For more information please visit https://oneinstack.com      #
#######################################################################
"
  echo "$(printf "%-30s" "Your domain:")${CMSG}${domain}${CEND}"
  echo "$(printf "%-30s" "Virtualhost conf:")${CMSG}${web_install_dir}/conf/vhost/${domain}.conf${CEND}"
  echo "$(printf "%-30s" "Directory of:")${CMSG}${vhostdir}${CEND}"
  [ "${rewrite_flag}" == 'y' -a "${rewrite}" != 'magento2' -a "${rewrite}" != 'pathinfo' ] && echo "$(printf "%-30s" "Rewrite rule:")${CMSG}${web_install_dir}/conf/rewrite/${rewrite}.conf${CEND}"
  Print_SSL
}

Create_nginx_proxy_conf() {
  [ ! -d ${web_install_dir}/conf/vhost ] && mkdir ${web_install_dir}/conf/vhost
  cat > ${web_install_dir}/conf/vhost/${domain}.conf << EOF
server {
  ${Nginx_conf}
  server_name ${domain}${moredomainame};
  ${Nginx_log}
  index index.html index.htm index.php;
  ${Nginx_redirect}
  location / {
    proxy_pass ${Proxy_Pass};
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header Host \$http_host;
    proxy_set_header X-NginX-Proxy true;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_max_temp_file_size 0;
  }

  #error_page 404 /404.html;
  #error_page 502 /502.html;
  ${anti_hotlinking}

  location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|flv|mp4|ico)$ {
    expires 30d;
    access_log off;
  }
  location ~ .*\.(js|css)?$ {
    expires 7d;
    access_log off;
  }
  location ~ /(\.user\.ini|\.ht|\.git|\.svn|\.project|LICENSE|README\.md) {
    deny all;
  }
}
EOF

  [ "${redirect_flag}" == 'y' ] && sed -i "s@^  root.*;@&\n  if (\$host != ${domain}) {  return 301 \$scheme://${domain}\$request_uri;  }@" ${web_install_dir}/conf/vhost/${domain}.conf

  if [ "${nginx_ssl_flag}" == 'y' ]; then
    sed -i "s@^  listen 80;@&\n  listen ${LISTENOPT};@" ${web_install_dir}/conf/vhost/${domain}.conf
    sed -i "s@^  server_name.*;@&\n  ssl_stapling_verify on;@" ${web_install_dir}/conf/vhost/${domain}.conf
    sed -i "s@^  server_name.*;@&\n  ssl_stapling on;@" ${web_install_dir}/conf/vhost/${domain}.conf
    sed -i "s@^  server_name.*;@&\n  add_header Strict-Transport-Security max-age=15768000;@" ${web_install_dir}/conf/vhost/${domain}.conf
    sed -i "s@^  server_name.*;@&\n  ssl_buffer_size 1400;@" ${web_install_dir}/conf/vhost/${domain}.conf
    sed -i "s@^  server_name.*;@&\n  ssl_session_cache builtin:1000 shared:SSL:10m;@" ${web_install_dir}/conf/vhost/${domain}.conf
    sed -i "s@^  server_name.*;@&\n  ssl_session_timeout 10m;@" ${web_install_dir}/conf/vhost/${domain}.conf
    sed -i "s@^  server_name.*;@&\n  ssl_prefer_server_ciphers on;@" ${web_install_dir}/conf/vhost/${domain}.conf
    sed -i "s@^  server_name.*;@&\n  ssl_ciphers TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:TLS13-AES-128-CCM-8-SHA256:TLS13-AES-128-CCM-SHA256:EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:\!MD5;@" ${web_install_dir}/conf/vhost/${domain}.conf
    sed -i "s@^  server_name.*;@&\n  ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;@" ${web_install_dir}/conf/vhost/${domain}.conf
    sed -i "s@^  server_name.*;@&\n  ssl_certificate_key ${PATH_SSL}/${domain}.key;@" ${web_install_dir}/conf/vhost/${domain}.conf
    sed -i "s@^  server_name.*;@&\n  ssl_certificate ${PATH_SSL}/${domain}.crt;@" ${web_install_dir}/conf/vhost/${domain}.conf
  fi

  if [ "${anti_hotlinking_flag}" == 'y' ]; then
      sed -i "s@^  root.*;@&\n  }@" ${web_install_dir}/conf/vhost/${domain}.conf
      sed -i "s@^  root.*;@&\n    }@" ${web_install_dir}/conf/vhost/${domain}.conf
      sed -i "s@^  root.*;@&\n      return 403;@" ${web_install_dir}/conf/vhost/${domain}.conf
      sed -i "s@^  root.*;@&\n      rewrite ^/ http://www.linuxeye.com/403.html;@" ${web_install_dir}/conf/vhost/${domain}.conf
      sed -i "s@^  root.*;@&\n    if (\$invalid_referer) {@" ${web_install_dir}/conf/vhost/${domain}.conf
      sed -i "s@^  root.*;@&\n    valid_referers none blocked ${domain_allow_all};@" ${web_install_dir}/conf/vhost/${domain}.conf
      sed -i "s@^  root.*;@&\n  location ~ .*\.(wma|wmv|asf|mp3|mmf|zip|rar|jpg|gif|png|swf|flv|mp4)\$ {@" ${web_install_dir}/conf/vhost/${domain}.conf
    fi

  [ "${https_flag}" == 'y' ] && sed -i "s@^  root.*;@&\n  if (\$ssl_protocol = \"\") { return 301 https://\$host\$request_uri; }@" ${web_install_dir}/conf/vhost/${domain}.conf

  echo
  ${web_install_dir}/sbin/nginx -t
  if [ $? == 0 ]; then
    echo "Reload Nginx......"
    ${web_install_dir}/sbin/nginx -s reload
  else
    rm -f ${web_install_dir}/conf/vhost/${domain}.conf
    echo "Create virtualhost ... [${CFAILURE}FAILED${CEND}]"
    exit 1
  fi

  printf "
#######################################################################
#       OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+      #
#       For more information please visit https://oneinstack.com      #
#######################################################################
"
  echo "$(printf "%-30s" "Your domain:")${CMSG}${domain}${CEND}"
  echo "$(printf "%-30s" "Virtualhost conf:")${CMSG}${web_install_dir}/conf/vhost/${domain}.conf${CEND}"
  echo "$(printf "%-30s" "Directory of:")${CMSG}${vhostdir}${CEND}"
  [ "${rewrite_flag}" == 'y' -a "${rewrite}" != 'magento2' -a "${rewrite}" != 'pathinfo' ] && echo "$(printf "%-30s" "Rewrite rule:")${CMSG}${web_install_dir}/conf/rewrite/${rewrite}.conf${CEND}"
  Print_SSL
}

Apache_log() {
  while :; do echo
    read -e -p "Allow Apache access_log? [y/n]: " access_flag
    if [[ ! "${access_flag}" =~ ^[y,n]$ ]]; then
      echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
    else
      break
    fi
  done

  if [ "${access_flag}" == 'n' ]; then
    Apache_log='CustomLog "/dev/null" common'
  else
    Apache_log="CustomLog \"${wwwlogs_dir}/${domain}_apache.log\" common"
    echo "You access log file=${wwwlogs_dir}/${domain}_apache.log"
  fi
}

Create_apache_conf() {
  if [ "${Apache_main_ver}" == '24' ]; then
    if [ -e "${php_install_dir}/sbin/php-fpm" ] && [ -n "`grep -E ^LoadModule.*mod_proxy_fcgi.so ${apache_install_dir}/conf/httpd.conf`" ]; then
      Apache_fcgi=$(echo -e "<Files ~ (\\.user.ini|\\.htaccess|\\.git|\\.svn|\\.project|LICENSE|README.md)\$>\n    Order allow,deny\n    Deny from all\n  </Files>\n  <FilesMatch \\.php\$>\n    SetHandler \"proxy:unix:/dev/shm/php${mphp_ver}-cgi.sock|fcgi://localhost\"\n  </FilesMatch>")
    fi
  fi
  [ ! -d ${apache_install_dir}/conf/vhost ] && mkdir ${apache_install_dir}/conf/vhost
  cat > ${apache_install_dir}/conf/vhost/${domain}.conf << EOF
<VirtualHost *:80>
  ServerAdmin admin@example.com
  DocumentRoot "${vhostdir}"
  ServerName ${domain}
  ${Apache_Domain_alias}
  ErrorLog "${wwwlogs_dir}/${domain}_error_apache.log"
  ${Apache_log}
  ${Apache_fcgi}
<Directory "${vhostdir}">
  SetOutputFilter DEFLATE
  Options FollowSymLinks ExecCGI
  ${Apache_grant}
  AllowOverride All
  Order allow,deny
  Allow from all
  DirectoryIndex index.html index.php
</Directory>
</VirtualHost>
EOF
  [ "$apache_ssl_flag" == 'y' ] && cat >> ${apache_install_dir}/conf/vhost/${domain}.conf << EOF
<VirtualHost *:443>
  ServerAdmin admin@example.com
  DocumentRoot "${vhostdir}"
  ServerName ${domain}
  ${Apache_Domain_alias}
  ${Apache_SSL}
  ErrorLog "${wwwlogs_dir}/${domain}_error_apache.log"
  ${Apache_log}
  ${Apache_fcgi}
<Directory "${vhostdir}">
  SetOutputFilter DEFLATE
  Options FollowSymLinks ExecCGI
  ${Apache_grant}
  AllowOverride All
  Order allow,deny
  Allow from all
  DirectoryIndex index.html index.php
</Directory>
</VirtualHost>
EOF

  echo
  ${apache_install_dir}/bin/apachectl -t
  if [ $? == 0 ]; then
    echo "Restart Apache......"
    ${apache_install_dir}/bin/apachectl -k graceful
  else
    rm -f ${apache_install_dir}/conf/vhost/${domain}.conf
    echo "Create virtualhost ... [${CFAILURE}FAILED${CEND}]"
    exit 1
  fi

  printf "
#######################################################################
#       OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+      #
#       For more information please visit https://oneinstack.com      #
#######################################################################
"
  echo "$(printf "%-30s" "Your domain:")${CMSG}${domain}${CEND}"
  echo "$(printf "%-30s" "Virtualhost conf:")${CMSG}${apache_install_dir}/conf/vhost/${domain}.conf${CEND}"
  echo "$(printf "%-30s" "Directory of:")${CMSG}${vhostdir}${CEND}"
  Print_SSL
}

Create_nginx_apache_modphp_conf() {
  # Nginx/Tengine/OpenResty
  [ ! -d ${web_install_dir}/conf/vhost ] && mkdir ${web_install_dir}/conf/vhost
  cat > ${web_install_dir}/conf/vhost/${domain}.conf << EOF
server {
  ${Nginx_conf}
  server_name ${domain}${moredomainame};
  ${Nginx_log}
  index index.html index.htm index.php;
  root ${vhostdir};
  ${Nginx_redirect}
  ${anti_hotlinking}
  location / {
    try_files \$uri @apache;
  }
  location @apache {
    proxy_pass http://127.0.0.1:88;
    include proxy.conf;
  }
  location ~ .*\.(php|php5|cgi|pl)?$ {
    proxy_pass http://127.0.0.1:88;
    include proxy.conf;
  }
  location ~ .*\.(gif|jpg|jpeg|png|bmp|swf|flv|mp4|ico)$ {
    expires 30d;
    access_log off;
  }
  location ~ .*\.(js|css)?$ {
    expires 7d;
    access_log off;
  }
  location ~ /(\.user\.ini|\.ht|\.git|\.svn|\.project|LICENSE|README\.md) {
    deny all;
  }
}
EOF

  [ "${https_flag}" == 'y' ] && sed -i "s@^  root.*;@&\n  if (\$ssl_protocol = \"\") { return 301 https://\$host\$request_uri; }@" ${web_install_dir}/conf/vhost/${domain}.conf

  echo
  ${web_install_dir}/sbin/nginx -t
  if [ $? == 0 ]; then
    echo "Reload Nginx......"
    ${web_install_dir}/sbin/nginx -s reload
  else
    rm -f ${web_install_dir}/conf/vhost/${domain}.conf
    echo "Create virtualhost ... [${CFAILURE}FAILED${CEND}]"
  fi

  # Apache
  if [ "${Apache_main_ver}" == '24' ]; then
    if [ -e "${php_install_dir}/sbin/php-fpm" ] && [ -n "`grep -E ^LoadModule.*mod_proxy_fcgi.so ${apache_install_dir}/conf/httpd.conf`" ]; then
      Apache_fcgi=$(echo -e "<Files ~ (\\.user.ini|\\.htaccess|\\.git|\\.svn|\\.project|LICENSE|README.md)\$>\n    Order allow,deny\n    Deny from all\n  </Files>\n  <FilesMatch \\.php\$>\n    SetHandler \"proxy:unix:/dev/shm/php${mphp_ver}-cgi.sock|fcgi://localhost\"\n  </FilesMatch>")
    fi
  fi
  [ ! -d ${apache_install_dir}/conf/vhost ] && mkdir ${apache_install_dir}/conf/vhost
  cat > ${apache_install_dir}/conf/vhost/${domain}.conf << EOF
<VirtualHost *:88>
  ServerAdmin admin@example.com
  DocumentRoot "${vhostdir}"
  ServerName ${domain}
  ${Apache_Domain_alias}
  ${Apache_SSL}
  ErrorLog "${wwwlogs_dir}/${domain}_error_apache.log"
  ${Apache_log}
  ${Apache_fcgi}
<Directory "${vhostdir}">
  SetOutputFilter DEFLATE
  Options FollowSymLinks ExecCGI
  ${Apache_grant}
  AllowOverride All
  Order allow,deny
  Allow from all
  DirectoryIndex index.html index.php
</Directory>
</VirtualHost>
EOF

  echo
  ${apache_install_dir}/bin/apachectl -t
  if [ $? == 0 ]; then
    echo "Restart Apache......"
    ${apache_install_dir}/bin/apachectl -k graceful
  else
    rm -f ${apache_install_dir}/conf/vhost/${domain}.conf
    exit 1
  fi

  printf "
#######################################################################
#       OneinStack for CentOS/RedHat 7+ Debian 8+ and Ubuntu 16+      #
#       For more information please visit https://oneinstack.com      #
#######################################################################
"
  echo "$(printf "%-30s" "Your domain:")${CMSG}${domain}${CEND}"
  echo "$(printf "%-30s" "Nginx Virtualhost conf:")${CMSG}${web_install_dir}/conf/vhost/${domain}.conf${CEND}"
  echo "$(printf "%-30s" "Apache Virtualhost conf:")${CMSG}${apache_install_dir}/conf/vhost/${domain}.conf${CEND}"
  echo "$(printf "%-30s" "Directory of:")${CMSG}${vhostdir}${CEND}"
  Print_SSL
}

Add_Vhost() {
  if [ -e "${web_install_dir}/sbin/nginx" -a ! -e "${apache_install_dir}/bin/httpd" ]; then
    Choose_ENV
    Input_Add_domain
    Nginx_anti_hotlinking
    if [ "${proxy_flag}" == "y" ]; then
        Input_Add_proxy
        Create_nginx_proxy_conf
      else
        Nginx_rewrite
        if [ "${NGX_FLAG}" == "java" ]; then
          Nginx_log
          Create_nginx_tomcat_conf
        else
          Nginx_log
          Create_nginx_phpfpm_conf
        fi
    fi
  elif [ ! -e "${web_install_dir}/sbin/nginx" -a -e "${apache_install_dir}/bin/httpd" ]; then
    Choose_ENV
    Input_Add_domain
    Apache_log
    Create_apache_conf
  elif [ ! -e "${web_install_dir}/sbin/nginx" -a ! -e "${apache_install_dir}/bin/httpd" -a -e "${tomcat_install_dir}/conf/server.xml" ]; then
    Choose_ENV
    Input_Add_domain
    Create_tomcat_conf
  elif [ -e "${web_install_dir}/sbin/nginx" -a -e "${apache_install_dir}/bin/httpd" ]; then
    Choose_ENV
    Input_Add_domain
    Nginx_anti_hotlinking
    if [ "${NGX_FLAG}" == "java" ]; then
      Nginx_rewrite
      Nginx_log
      Create_nginx_tomcat_conf
    elif [ "${NGX_FLAG}" == "php" ]; then
      Nginx_log
      Apache_log
      Create_nginx_apache_modphp_conf
    fi
  else
    echo "Error! ${CFAILURE}Web server${CEND} not found!"
  fi
}

Del_NGX_Vhost() {
  if [ -e "${web_install_dir}/sbin/nginx" ]; then
    [ -d "${web_install_dir}/conf/vhost" ] && Domain_List=$(ls ${web_install_dir}/conf/vhost | sed "s@.conf@@g")
    if [ -n "${Domain_List}" ]; then
      echo
      echo "Virtualhost list:"
      echo ${CMSG}${Domain_List}${CEND}
        while :; do echo
          read -e -p "Please input a domain you want to delete: " domain
          if [ -z "$(echo ${domain} | grep '.*\..*')" ]; then
            echo "${CWARNING}Your ${domain} is invalid! ${CEND}"
          else
            if [ -e "${web_install_dir}/conf/vhost/${domain}.conf" ]; then
              Directory=$(grep '^  root' ${web_install_dir}/conf/vhost/${domain}.conf | head -1 | awk -F'[ ;]' '{print $(NF-1)}')
              rm -f ${web_install_dir}/conf/vhost/${domain}.conf
              [ -e "${web_install_dir}/conf/ssl/${domain}.crt" ] && rm -f ${web_install_dir}/conf/ssl/${domain}.{crt,key}
              ${web_install_dir}/sbin/nginx -s reload
              while :; do echo
                read -e -p "Do you want to delete Virtul Host directory? [y/n]: " Del_Vhost_wwwroot_flag
                if [[ ! ${Del_Vhost_wwwroot_flag} =~ ^[y,n]$ ]]; then
                  echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
                else
                  break
                fi
              done
              if [ "${Del_Vhost_wwwroot_flag}" == 'y' ]; then
		if [ "${quiet_flag}" != 'y' ]; then
                  echo "Press Ctrl+c to cancel or Press any key to continue..."
                  char=$(get_char)
		fi
                rm -rf ${Directory}
              fi
              echo
              [ -d ~/.acme.sh/${domain} ] && ~/.acme.sh/acme.sh --force --remove -d ${domain} > /dev/null 2>&1
              echo "${CMSG}Domain: ${domain} has been deleted.${CEND}"
              echo
            else
              echo "${CWARNING}Virtualhost: ${domain} was not exist! ${CEND}"
            fi
            break
          fi
        done
    else
      echo "${CWARNING}Virtualhost was not exist! ${CEND}"
    fi
  fi
}

Del_Apache_Vhost() {
  if [ -e "${apache_install_dir}/bin/httpd" ]; then
    if [ -e "${web_install_dir}/sbin/nginx" ]; then
      rm -f ${apache_install_dir}/conf/vhost/${domain}.conf
      ${apache_install_dir}/bin/apachectl -k graceful
    else
      Domain_List=$(ls ${apache_install_dir}/conf/vhost | grep -v '0.conf' | sed "s@.conf@@g")
      if [ -n "${Domain_List}" ]; then
        echo
        echo "Virtualhost list:"
        echo ${CMSG}${Domain_List}${CEND}
        while :; do echo
          read -e -p "Please input a domain you want to delete: " domain
          if [ -z "$(echo ${domain} | grep '.*\..*')" ]; then
            echo "${CWARNING}Your ${domain} is invalid! ${CEND}"
          else
            if [ -e "${apache_install_dir}/conf/vhost/${domain}.conf" ]; then
              Directory=$(grep '^<Directory ' ${apache_install_dir}/conf/vhost/${domain}.conf | head -1 | awk -F'"' '{print $2}')
              rm -f ${apache_install_dir}/conf/vhost/${domain}.conf
              [ -e "${apache_install_dir}/conf/ssl/${domain}.crt" ] && rm -f ${apache_install_dir}/conf/ssl/${domain}.{crt,key}
              ${apache_install_dir}/bin/apachectl -k graceful
              while :; do echo
                read -e -p "Do you want to delete Virtul Host directory? [y/n]: " Del_Vhost_wwwroot_flag
                if [[ ! ${Del_Vhost_wwwroot_flag} =~ ^[y,n]$ ]]; then
                  echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
                else
                  break
                fi
              done

              if [ "${Del_Vhost_wwwroot_flag}" == 'y' ]; then
		if [ "${quiet_flag}" != 'y' ]; then
                  echo "Press Ctrl+c to cancel or Press any key to continue..."
                  char=$(get_char)
		fi
                rm -rf ${Directory}
              fi
              [ -d ~/.acme.sh/${domain} ] && ~/.acme.sh/acme.sh --force --remove -d ${domain} > /dev/null 2>&1
              echo "${CSUCCESS}Domain: ${domain} has been deleted.${CEND}"
            else
              echo "${CWARNING}Virtualhost: ${domain} was not exist! ${CEND}"
            fi
            break
          fi
        done

      else
        echo "${CWARNING}Virtualhost was not exist! ${CEND}"
      fi
    fi
  fi
}

Del_Tomcat_Vhost() {
  if [ -e "${tomcat_install_dir}/conf/server.xml" ]; then
    if [ -e "${web_install_dir}/sbin/nginx" ]; then
      if [ -n "$(echo ${domain} | grep '.*\..*')" ] && [ -n "$(grep vhost-${domain} ${tomcat_install_dir}/conf/server.xml)" ]; then
        sed -i /vhost-${domain}/d ${tomcat_install_dir}/conf/server.xml
        rm -f ${tomcat_install_dir}/conf/vhost/${domain}.xml
        service tomcat restart
      fi
    else
      Domain_List=$(ls ${tomcat_install_dir}/conf/vhost | grep -v 'localhost.xml' | sed "s@.xml@@g")
      if [ -n "${Domain_List}" ]; then
        echo
        echo "Virtualhost list:"
        echo ${CMSG}${Domain_List}${CEND}
        while :; do echo
          read -e -p "Please input a domain you want to delete: " domain
          if [ -z "$(echo ${domain} | grep '.*\..*')" ]; then
            echo "${CWARNING}Your ${domain} is invalid! ${CEND}"
          else
            if [ -n "$(grep vhost-${domain} ${tomcat_install_dir}/conf/server.xml)" ]; then
              sed -i /vhost-${domain}/d ${tomcat_install_dir}/conf/server.xml
              rm -f ${tomcat_install_dir}/conf/vhost/${domain}.xml
              service tomcat restart
              while :; do echo
                read -e -p "Do you want to delete Virtul Host directory? [y/n]: " Del_Vhost_wwwroot_flag
                if [[ ! ${Del_Vhost_wwwroot_flag} =~ ^[y,n]$ ]]; then
                  echo "${CWARNING}input error! Please only input 'y' or 'n'${CEND}"
                else
                  break
                fi
              done

              if [ "${Del_Vhost_wwwroot_flag}" == 'y' ]; then
		if [ "${quiet_flag}" != 'y' ]; then
                  echo "Press Ctrl+c to cancel or Press any key to continue..."
                  char=$(get_char)
		fi
                rm -rf ${Directory}
              fi
              echo "${CSUCCESS}Domain: ${domain} has been deleted.${CEND}"
            else
              echo "${CWARNING}Virtualhost: ${domain} was not exist! ${CEND}"
            fi
            break
          fi
        done

      else
        echo "${CWARNING}Virtualhost was not exist! ${CEND}"
      fi
    fi
  fi
}

List_Vhost() {
  [ -e "${tomcat_install_dir}/conf/server.xml" -a ! -d "${web_install_dir}/sbin/nginx" ] && Domain_List=$(ls ${tomcat_install_dir}/conf/vhost | grep -v 'localhost.xml' | sed "s@.xml@@g")
  [ -d "${web_install_dir}/conf/vhost" ] && Domain_List=$(ls ${web_install_dir}/conf/vhost | sed "s@.conf@@g")
  [ -e "${apache_install_dir}/bin/httpd" -a ! -d "${web_install_dir}/conf/vhost" ] && Domain_List=$(ls ${apache_install_dir}/conf/vhost | grep -v '0.conf' | sed "s@.conf@@g")
  if [ -n "${Domain_List}" ]; then
    echo
    echo "Virtualhost list:"
    for D in ${Domain_List}; do echo ${CMSG}${D}${CEND}; done
  else
    echo "${CWARNING}Virtualhost was not exist! ${CEND}"
  fi
}

if [ ${ARG_NUM} == 0 ]; then
  Add_Vhost
else
  [ "${add_flag}" == 'y' -o "${proxy_flag}" == 'y' -o "${sslquiet_flag}" == 'y' ] && Add_Vhost
  [ "${list_flag}" == 'y' ] && List_Vhost
  [ "${delete_flag}" == 'y' ] && { Del_NGX_Vhost; Del_Apache_Vhost; Del_Tomcat_Vhost; }
fi
