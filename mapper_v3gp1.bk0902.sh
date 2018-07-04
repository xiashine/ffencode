#!/bin/bash
id="hduser"
outpath=/data/hadoop/tmp/$(date +%s%N)
type="v3gp1"
dt=$(date +%Y/%m/%d)
mkdir -p $outpath/$type
host=`hostname`
pwd=`pwd`
uid=`whoami`
put_dir=/data/vdp/$type/
dt=""
cd "$outpath"
true > a
while read line; do
input=`echo $line | awk '{ print $1 }'`
filename=`basename $input .mp4`

if [ "$dt" == "" ]; then
	tmpfilename=${filename%.*}
	if [ "${tmpfilename:0:1}" == "m" ]; then
	        dt="movie"
	else
	        dt="video"
	fi
	dt="${dt}/${tmpfilename:1:4}/${tmpfilename:5:2}/${tmpfilename:7:2}/${tmpfilename}/"
fi
base=$put_dir$dt
autocrop=`echo $line | awk '{ print $2 }'`
if [ "$autocrop" != "" ]; then
	autocrop="${autocrop},"
fi
/usr/hadoop/bin/hadoop fs -get $input $outpath 2>&1
ffmpeg -y -i $outpath/$filename.mp4 -vcodec libx264 -pix_fmt yuv420p  -vprofile baseline -preset slow -b:v 70k -maxrate 70k -bufsize 140k -vf "movie=/usr/hadoop/newlogo.png,scale=36:-1[watermark];movie=/usr/hadoop/pindaologo50px.png,scale=10:-1[watermark2];[in]${autocrop}scale=176:trunc(ow/a/2)*2 [scale];[scale][watermark]overlay=10:10[1];[1][watermark2]overlay=main_w-overlay_w-10:main_h-overlay_h-10[out]" -acodec libfdk_aac -b:a 16k -ac 2 -af 'volume=1.5' $outpath/$type/$filename.3gp < a 2>&1
/usr/hadoop/bin/hadoop fs -put  $outpath/$type/$filename.3gp ${base}/$filename.3gp 2>&1
/usr/hadoop/bin/hadoop fs -chown $id ${base}/$filename.3gp 2>&1
done
rm -f a
rm -rf $outpath
