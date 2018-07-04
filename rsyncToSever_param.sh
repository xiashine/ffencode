#!/bin/bash
. /data/encode/config.sh

#RSY=$(cat $BASE/encode/rsyServer.out)
#if [ $RSY -eq 1 ]; then
#   exit 0
#fi

#echo "1">$BASE/encode/rsyServer.out
dt=$1
if [ -z "$dt" ] ; then
                echo "dt no empty"
                exit 4
fi
#dt=$(date +%Y/%m/)
echo "$(date +%Y-%m-%d) $(date +%T) rsync starting ..."
arrdir=( "v480pflv" "v480p" "v480pm3u8" "v360p" "v360pflv" "v360pm3u8" "v720p" "v720pflv" "v720pm3u8" "v720phds" "v720pexp" "vprotecthls" )
for var in ${arrdir[@]};
do
    if [ -d /data/vdp/$var/movie/$dt ]; then
        cd /data/vdp/$var/movie/
        echo "rsync -vzrtogR --progress --bwlimit=5000 $dt root@118.145.26.113::vdp/$var/movie/"
        rsync -vzrtogR --progress --bwlimit=5000 $dt root@118.145.26.113::vdp/$var/movie/
    fi
done
echo "$(date +%Y-%m-%d) $(date +%T) rsync END"
#echo "0">$BASE/encode/rsyServer.out
