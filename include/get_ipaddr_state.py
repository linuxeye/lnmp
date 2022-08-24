#!/usr/bin/env python
#coding:utf-8
import sys,socket,json

if sys.version_info[0] == 2:
  import urllib2 as request
else:
  import urllib.request as request

try:
  socket.setdefaulttimeout(5)
  if len(sys.argv) == 1:
      apiurl = "http://ip-api.com/json"
  elif len(sys.argv) == 2:
      apiurl = "http://ip-api.com/json/%s" % sys.argv[1]
  content = request.urlopen(apiurl).read().decode('utf-8')
  content = json.JSONDecoder().decode(content)
  #print(content)
  if content['status'] == 'success':
    if content['country'] == 'China':
      print("CN")
    else:
      print(content['country'])
except:
  print("Usage:%s IP" % sys.argv[0])
