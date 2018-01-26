#!/usr/bin/env python
import re,urllib2,socket
class Get_public_ip:
  socket.setdefaulttimeout(5)
  def getip(self):
    try:
      myip = self.visit("http://ip.taobao.com/ipSearch.php")
    except:
      try:
        myip = self.visit("http://ipv4.icanhazip.com/")
      except:
        myip = "So sorry!!!"
    return myip
  def visit(self,url):
    opener = urllib2.urlopen(url)
    if url == opener.geturl():
      str = opener.read()
    return re.search('\d+\.\d+\.\d+\.\d+',str).group(0)

if __name__ == "__main__":
  getmyip = Get_public_ip()
  print getmyip.getip()
