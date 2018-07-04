#!/bin/sh

lastMonth=`date -d '-1 month' +%Y/%m`

echo "-----$(date +%Y-%m-%d) $(date +%T) delete last week ${lastMonth} video begin----"
rm -rf /data/vdp/v720p/movie/${lastMonth}
rm -rf /data/vdp/v720pflv/movie/${lastMonth}
rm -rf /data/vdp/v720pm3u8/movie/${lastMonth}
rm -rf /data/vdp/v720phds/movie/${lastMonth}
rm -rf /data/vdp/v720pexp/movie/${lastMonth}

rm -rf /data/vdp/v480p/movie/${lastMonth}
rm -rf /data/vdp/v480pflv/movie/${lastMonth}
rm -rf /data/vdp/v480pm3u8/movie/${lastMonth}


rm -rf /data/vdp/v360p/movie/${lastMonth}
rm -rf /data/vdp/v360pflv/movie/${lastMonth}
rm -rf /data/vdp/v360pm3u8/movie/${lastMonth}

rm -rf /data/vdp/v3gp1/movie/${lastMonth}
rm -rf /data/vdp/v3gp2/movie/${lastMonth}
rm -rf /data/vdp/v3gp3/movie/${lastMonth}


echo "-----delete end.------"
