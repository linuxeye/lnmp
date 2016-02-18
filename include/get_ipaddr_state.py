#!/usr/bin/env python
#coding:utf-8
try:
    import sys,urllib2,socket
    socket.setdefaulttimeout(10)
    apiurl = "http://ip.taobao.com/service/getIpInfo.php?ip=%s" % sys.argv[1] 
    content = urllib2.urlopen(apiurl).read()
    data = eval(content)['data']
    code = eval(content)['code']
    if code == 0:
        print data['country']
    else:
        print data
except:
    print "Usage:%s IP" % sys.argv[0]
