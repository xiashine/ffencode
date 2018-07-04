#!/bin/bash
. /data/encode/config.sh

RSY=$(cat $BASE/encode/rsyServer.out)
if [ $RSY -eq 1 ]; then
   exit 0
fi

echo "1">$BASE/encode/rsyServer.out

dt="$(date +%Y/%m/%d)"
echo "$(date +%Y-%m-%d) $(date +%T) rsync starting ..."
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v360p root@118.145.26.113::vdp
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v360pflv root@118.145.26.113::vdp
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v360pm3u8 root@118.145.26.113::vdp
echo "$(date +%Y-%m-%d) $(date +%T) rsync starting v480p:"
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v480p root@118.145.26.113::vdp
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v480pflv root@118.145.26.113::vdp
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v480pm3u8 root@118.145.26.113::vdp
echo "$(date +%Y-%m-%d) $(date +%T)rsync starting v720p:"
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v720p root@118.145.26.113::vdp
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v720pflv root@118.145.26.113::vdp
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v720pm3u8 root@118.145.26.113::vdp
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v720phds root@118.145.26.113::vdp
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v720pexp root@118.145.26.113::vdp
echo "$(date +%Y-%m-%d) $(date +%T)rsync starting v3gp1:"
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v3gp1 root@118.145.26.113::vdp
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v3gp2 root@118.145.26.113::vdp
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v3gp3 root@118.145.26.113::vdp
echo "$(date +%Y-%m-%d) $(date +%T) rsync END"
echo "0">$BASE/encode/rsyServer.out


