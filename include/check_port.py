#!/usr/bin/env python
import sys,os,socket
def IsOpen(ip,port):
  socket.setdefaulttimeout(5)
  s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
  try:
    s.connect((ip,int(port)))
    s.shutdown(2)
    print True
  except:
    print False
if __name__ == '__main__':
  IsOpen(sys.argv[1],int(sys.argv[2]))
