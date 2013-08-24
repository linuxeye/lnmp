#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# Blog:  http://blog.linuxeye.com

IP=`ifconfig | grep 'inet addr:' | cut -d: -f2 | grep -v ^10\. | grep -v ^192\.168 | grep -v ^172\. | grep -v ^127\. | awk '{print  $1}' | awk '{print;exit}'`
[ ! -n "$IP" ] && IP=`ifconfig | grep 'inet addr:' | cut -d: -f2 | grep -v ^127\. | awk '{print  $1}' | awk '{print;exit}'`
