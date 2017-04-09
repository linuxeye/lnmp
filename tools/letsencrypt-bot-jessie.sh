#!/bin/bash
# Author : kmahyyg (Find me at Github)
# Blog : https://kmahyyg.cf
# This script can only be used on Debian 8(Jessie).

sudo apt-get update
sudo apt-get install certbot -t jessie-backports -y

echo "Choose standalone method , And change the ssl certificate path of vhost by yourself mannually , Thanks! "
echo "A Self-Sign certificate may cause a lot of trouble."

sudo certbot certonly

echo "Done!"
exit 0
