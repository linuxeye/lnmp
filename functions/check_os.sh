#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

if [ -f /etc/redhat-release ];then
        OS=CentOS
elif [ ! -z "`cat /etc/issue | grep bian`" ];then
        OS=Debian
elif [ ! -z "`cat /etc/issue | grep Ubuntu`" ];then
        OS=Ubuntu
else
        echo -e "\033[31mDoes not support this OS, Please contact the author! \033[0m"
        kill -9 $$
fi

OS_command()
{
	if [ $OS == 'CentOS' ];then
	        echo -e $OS_CentOS | bash
	elif [ $OS == 'Debian' -o $OS == 'Ubuntu' ];then
		echo -e $OS_Debian_Ubuntu | bash
	else
		echo -e "\033[31mDoes not support this OS, Please contact the author! \033[0m"
		kill -9 $$
	fi
}
