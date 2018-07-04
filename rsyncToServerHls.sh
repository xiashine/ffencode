#!/bin/bash
. /data/encode/config.sh

RSY=$(cat $BASE/encode/rsyHlsServer.out)
if [ $RSY -eq 1 ]; then
   exit 0
fi

echo "1">$BASE/encode/rsyHlsServer.out

dt=$(date +%Y/%m/)
echo "$(date +%Y-%m-%d) $(date +%T) rsync starting amrhls ..."

if [ -d /data/vdp/vamrhls/movie/$dt ]; then
   cd /data/vdp/vamrhls/movie/
   rsync -vzrtogR --progress --bwlimit=5000 $dt root@118.145.26.235::video/movie/
fi

DAY=$(date +%d)
if [[ $DAY -le 12 ]]; then
  predt=$(date -d "-1 month" +%Y/%m/)
  if [ -d /data/vdp/vamrhls/movie/$predt ]; then
      cd /data/vdp/vamrhls/movie/
      rsync -vzrtogR --progress --bwlimit=5000 $predt root@118.145.26.235::video/movie/
  fi
fi 

echo "$(date +%Y-%m-%d) $(date +%T) rsync amrhls END"
echo "0">$BASE/encode/rsyHlsServer.out
