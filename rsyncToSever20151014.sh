#!/bin/bash
. /data/encode/config.sh

RSY=$(cat $BASE/encode/rsyServer.out)
if [ $RSY -eq 1 ]; then
   exit 0
fi

echo "1">$BASE/encode/rsyServer.out

dt="$(date +%Y/%m/%d)"
echo "$(date +%Y-%m-%d) $(date +%T) rsync starting ..."
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v480pflv/movie root@118.145.26.113::vdp/v480pflv
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v480p/movie root@118.145.26.113::vdp/v480p
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v480pm3u8/movie root@118.145.26.113::vdp/v480pm3u8
echo "$(date +%Y-%m-%d) $(date +%T) rsync starting v360p:"
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v360p/movie root@118.145.26.113::vdp/v360p
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v360pflv/movie root@118.145.26.113::vdp/v360pflv
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v360pm3u8/movie root@118.145.26.113::vdp/v360pm3u8
echo "$(date +%Y-%m-%d) $(date +%T)rsync starting v720p:"
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v720p/movie root@118.145.26.113::vdp/v720p
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v720pflv/movie root@118.145.26.113::vdp/v720pflv
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v720pm3u8/movie root@118.145.26.113::vdp/v720pm3u8
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v720phds/movie root@118.145.26.113::vdp/v720phds
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v720pexp/movie root@118.145.26.113::vdp/v720pexp
rsync -vzrtog --progress --bwlimit=2000 /data/vdp/vprotecthls/movie root@118.145.26.113::vdp/vprotecthls

#echo "$(date +%Y-%m-%d) $(date +%T)rsync starting v3gp1:"
#rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v3gp1/movie root@118.145.26.113::vdp/v3gp1
#rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v3gp2/movie root@118.145.26.113::vdp/v3gp2
#rsync -vzrtog --progress --bwlimit=2000 /data/vdp/v3gp3/movie root@118.145.26.113::vdp/v3gp3
#echo "$(date +%Y-%m-%d) $(date +%T) rsync END"
echo "0">$BASE/encode/rsyServer.out
