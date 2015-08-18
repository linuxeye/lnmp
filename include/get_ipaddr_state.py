#!/usr/bin/env python
#coding:utf-8
try:
    import sys,urllib2
    apiurl = "http://int.dpool.sina.com.cn/iplookup/iplookup.php?format=json&ip=%s" % sys.argv[1]
    content = urllib2.urlopen(apiurl).read()
    content=eval(content)
    ret = content['ret']
    country = content['country']
    if ret == 1:
        #print country.decode('unicode_escape')
        print country
except:
    print "Usage:%s IP" % sys.argv[0]
