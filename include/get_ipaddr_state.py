#!/usr/bin/env python
#coding:utf-8
import sys,urllib2,socket
try:
  socket.setdefaulttimeout(5)
  apiurl = "http://ip.taobao.com/service/getIpInfo.php?ip=%s" % sys.argv[1]
  content = urllib2.urlopen(apiurl).read()
  data = eval(content)['data']
  code = eval(content)['code']
  if code == 0:
    print data['country_id'],data['isp_id']
  else:
    print data
except:
  print "Usage:%s IP" % sys.argv[0]
