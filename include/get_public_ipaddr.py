#!/usr/bin/env python
import sys,re,socket

if sys.version_info[0] == 2:
  import urllib2 as request
else:
  import urllib.request as request

class Get_public_ip:
  socket.setdefaulttimeout(5)
  def getip(self):
    try:
      myip = self.visit("http://ipv4.icanhazip.com/")
    except:
      try:
        myip = self.visit("http://pv.sohu.com/cityjson?ie=utf-8")
      except:
        myip = "So sorry!!!"
    return myip
  def visit(self,url):
    opener = request.urlopen(url)
    if url == opener.geturl():
      str = opener.read().decode('utf-8')
    return re.search('\d+\.\d+\.\d+\.\d+',str).group(0)

if __name__ == "__main__":
  getmyip = Get_public_ip()
  print(getmyip.getip())
