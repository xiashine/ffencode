#!/bin/bash
id="hduser"
outpath=/data/hadoop/tmp/$(date +%s%N)
type="v360p"
dt=$(date +%Y/%m/%d)
mkdir -p $outpath/$type
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
encodeinfo="movie=/usr/hadoop/videologo.png,scale=58:-1[watermark];movie=/usr/hadoop/videopindaologo.png,scale=40:-1[watermark2];[in]pad='if(gte(iw/ih,16/9),iw,ih*16/9)':'if(gte(iw/ih,16/9),iw*9/16,ih)':(ow-iw)/2:(oh-ih)/2,scale=480:trunc(ow/a/2)*2[scale];[scale][watermark]overlay=16:10[1];[1][watermark2]overlay=main_w-overlay_w-16:main_h-overlay_h-16[out]"
encodep=`echo $line | awk '{ print $2 }'`
encodebit=`echo $line | awk '{ print $3 }'`
encodex=`echo $line | awk '{ print $4 }'`
encodetit=`echo $line | awk '{ print $5 }'`
encodecrop=`echo $line | awk '{ print $6 }'`
autocrop=""
if [ "$encodecrop" != "" ]; then
        autocrop=${encodecrop},
fi
if [ "$encodex" == "0" ]; then
    autocrop=""
fi
case $encodep in
0)
    encodeinfo="${autocrop}pad='if(gte(iw/ih,16/9),iw,ih*16/9)':'if(gte(iw/ih,16/9),iw*9/16,ih)':(ow-iw)/2:(oh-ih)/2,scale=480:trunc(ow/a/2)*2"
    ;;
1)
    encodeinfo="movie=/usr/hadoop/videologo.png,scale=58:-1[watermark];[in]${autocrop}pad='if(gte(iw/ih,16/9),iw,ih*16/9)':'if(gte(iw/ih,16/9),iw*9/16,ih)':(ow-iw)/2:(oh-ih)/2,scale=480:trunc(ow/a/2)*2[scale];[scale][watermark]overlay=16:10[out]"
    ;;
2)
    encodeinfo="movie=/usr/hadoop/videologo.png,scale=58:-1[watermark];movie=/usr/hadoop/videopindaologo.png,scale=40:-1[watermark2];[in]${autocrop}pad='if(gte(iw/ih,16/9),iw,ih*16/9)':'if(gte(iw/ih,16/9),iw*9/16,ih)':(ow-iw)/2:(oh-ih)/2,scale=480:trunc(ow/a/2)*2[scale];[scale][watermark]overlay=16:10[1];[1][watermark2]overlay=main_w-overlay_w-16:main_h-overlay_h-16[out]"
    ;;
esac
/usr/hadoop/bin/hadoop fs -get $input $outpath 2>&1
ffmpeg -y -i $outpath/$filename.mp4 -vcodec libx264 -pix_fmt yuv420p -vprofile baseline -preset slow -b:v 300k -maxrate 300k -bufsize 600k -vf "${encodeinfo}" -acodec libfdk_aac -ac 2 -b:a 48k -af 'volume=1.5' $outpath/$type/$filename.qt.mp4 < a 2>&1
/usr/bin/qt-faststart $outpath/$type/$filename.qt.mp4 $outpath/$type/$filename.mp4 < a 2>&1
/usr/hadoop/bin/hadoop fs -put  $outpath/$type/$filename.mp4 ${base}/$filename.mp4 2>&1
/usr/hadoop/bin/hadoop fs -chown $id ${base}/$filename.mp4 2>&1
done
rm -f a
rm -rf $outpath
