#!/bin/sh


echo "-----$(date +%Y-%m-%d) $(date +%T) delete last 7 days video begin----"

#find /data/vdp/v720p/ -type f -mtime +7 -exec rm {} \;
find /data/vdp/v720pflv/ -type f -mtime +7 -exec rm {} \;
find /data/vdp/v720pm3u8/ -type f -mtime +7 -exec rm {} \;

#find /data/vdp/v480p/ -type f -mtime +7 -exec rm {} \;
find /data/vdp/v480pflv/ -type f -mtime +7 -exec rm {} \;
find /data/vdp/v480pm3u8/ -type f -mtime +7 -exec rm {} \;

find /data/vdp/v360p/ -type f -mtime +7 -exec rm {} \;
find /data/vdp/v360pflv/ -type f -mtime +7 -exec rm {} \;
find /data/vdp/v360pm3u8/ -type f -mtime +7 -exec rm {} \;

#find /data/vdp/v3gp1/ -type f -mtime +7 -exec rm {} \;
#find /data/vdp/v3gp2/ -type f -mtime +7 -exec rm {} \;
#find /data/vdp/v3gp3/ -type f -mtime +7 -exec rm {} \;

find /data/vdp/tmp/ -type f -mtime +2 -exec rm {} \;
find /data/uploadfile/ -type f -mtime +7 -exec rm {} \;

echo "-----delete end.------"
