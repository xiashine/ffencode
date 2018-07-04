#!/bin/bash
. /data/encode/config.sh

RSY=$(cat $BASE/encode/rsyVideoServer.out)
if [ $RSY -eq 1 ]; then
   exit 0
fi

echo "1">$BASE/encode/rsyVideoServer.out

dt="$(date +%Y/%m/%d)"
echo "$(date +%Y-%m-%d) $(date +%T) rsync starting ..."
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v480pflv/video root@118.145.26.113::vdp/v480pflv
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v480p/video root@118.145.26.113::vdp/v480p
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v480pm3u8/video root@118.145.26.113::vdp/v480pm3u8
echo "$(date +%Y-%m-%d) $(date +%T) rsync starting v360p:"
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v360p/video root@118.145.26.113::vdp/v360p
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v360pflv/video root@118.145.26.113::vdp/v360pflv
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v360pm3u8/video root@118.145.26.113::vdp/v360pm3u8
echo "$(date +%Y-%m-%d) $(date +%T)rsync starting v720p:"
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v720p/video root@118.145.26.113::vdp/v720p
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v720pflv/video root@118.145.26.113::vdp/v720pflv
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v720pm3u8/video root@118.145.26.113::vdp/v720pm3u8
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v720phds/video root@118.145.26.113::vdp/v720phds
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v720pexp/video root@118.145.26.113::vdp/v720pexp
echo "$(date +%Y-%m-%d) $(date +%T)rsync starting v3gp1:"
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v3gp1/video root@118.145.26.113::vdp/v3gp1
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v3gp2/video root@118.145.26.113::vdp/v3gp2
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v3gp3/video root@118.145.26.113::vdp/v3gp3
echo "$(date +%Y-%m-%d) $(date +%T) rsync END"
echo "0">$BASE/encode/rsyVideoServer.out
