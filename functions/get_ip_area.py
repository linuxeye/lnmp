#!/usr/bin/env python
#coding:utf-8
try:
    import sys,urllib2
#    import sys,urllib2,json
# Python 2.4(CentOS/RHEL 5) does not support 'json' module
    apiurl = "http://ip.taobao.com/service/getIpInfo.php?ip=%s" % sys.argv[1] 
    content = urllib2.urlopen(apiurl).read()
#    data = json.loads(content)['data']
#    code = json.loads(content)['code']
    data = eval(content)['data']
    code = eval(content)['code']
    if code == 0:
        print data['country_id']
    else:
        print data
except:
    print "Usage:%s IP" % sys.argv[0]
