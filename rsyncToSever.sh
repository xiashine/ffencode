#!/bin/bash
. /data/encode/config.sh

RSY=$(cat $BASE/encode/rsyServer.out)
if [ $RSY -eq 1 ]; then
   exit 0
fi

echo "1">$BASE/encode/rsyServer.out

dt=$(date +%Y/%m/)
echo "$(date +%Y-%m-%d) $(date +%T) rsync starting ..."
arrdir=( "v480pflv" "v480p" "v480pm3u8" "v360p" "v360pflv" "v360pm3u8" "v720p" "v720pflv" "v720pm3u8" "v720phds" "v720pexp" "vprotecthls" )
for var in ${arrdir[@]};
do
    if [ -d /data/vdp/$var/movie/$dt ]; then
        cd /data/vdp/$var/movie/
        echo "rsync -vzrtogR --progress --bwlimit=5000 $dt root@115.182.205.4::vdp/$var/movie/"
        #rsync -vzrtogR --progress --bwlimit=5000 $dt root@118.145.26.113::vdp/$var/movie/
        rsync -vzrtogR --progress --bwlimit=5000 $dt root@115.182.205.4::vdp/$var/movie/
    fi
    DAY=$(date +%d)
if [[ $DAY -le 6 ]]; then
  predt=$(date -d "-1 month" +%Y/%m/)
  if [ -d /data/vdp/$var/movie/$predt ]; then
      cd /data/vdp/$var/movie/
      echo "rsync -vzrtogR --progress --bwlimit=5000 $predt root@115.182.205.4:vdp/$var/movie/"
      #rsync -vzrtogR --progress --bwlimit=5000 $predt root@118.145.26.113::vdp/$var/movie/
      rsync -vzrtogR --progress --bwlimit=5000 $predt root@115.182.205.4::vdp/$var/movie/
  fi
fi 
done

if [ -d /data/vdp/vamrhls/movie/$dt ]; then
   cd /data/vdp/vamrhls/movie/
   #rsync -vzrtogR --progress --bwlimit=5000 $dt root@118.145.26.117::video/vhls/movie/
   #rsync -vzrtogR --progress --bwlimit=5000 $dt root@115.182.205.5::video/vhls/movie/
fi

DAY=$(date +%d)
if [[ $DAY -le 6 ]]; then
  predt=$(date -d "-1 month" +%Y/%m/)
  if [ -d /data/vdp/vamrhls/movie/$predt ]; then
      cd /data/vdp/vamrhls/movie/
      #rsync -vzrtogR --progress --bwlimit=5000 $predt root@115.182.205.5::video/vhls/movie/
  fi
fi 

echo "$(date +%Y-%m-%d) $(date +%T) rsync END"
echo "0">$BASE/encode/rsyServer.out
