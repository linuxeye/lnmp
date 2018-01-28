#!/usr/bin/env python
import socket
def Get_local_ip():
  """
  Returns the actual ip of the local machine.
  This code figures out what source address would be used if some traffic
  were to be sent out to some well known address on the Internet. In this
  case, a Google DNS server is used, but the specific address does not
  matter much.  No traffic is actually sent.
  """
  try:
    socket.setdefaulttimeout(5)
    csock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    csock.connect(('8.8.8.8', 80))
    (addr, port) = csock.getsockname()
    csock.close()
    return addr
  except socket.error:
    return "127.0.0.1"

if __name__ == "__main__":
  IPADDR = Get_local_ip()
  print IPADDR
