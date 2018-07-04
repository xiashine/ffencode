#!/bin/bash
id="hduser"
outpath=/data/hadoop/tmp/$(date +%s%N)
type="v480p"
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
encodeinfo="movie=/usr/hadoop/videologo.png,scale=86:-1[watermark];movie=/usr/hadoop/videopindaologo.png,scale=60:-1[watermark2];[in]pad='if(gte(iw/ih,16/9),iw,ih*16/9)':'if(gte(iw/ih,16/9),iw*9/16,ih)':(ow-iw)/2:(oh-ih)/2,scale=720:trunc(ow/a/2)*2[scale];[scale][watermark]overlay=22:14[1];[1][watermark2]overlay=main_w-overlay_w-22:main_h-overlay_h-22[out]"
encodep=`echo $line | awk '{ print $2 }'`
encodebit=`echo $line | awk '{ print $3 }'`
encodex=`echo $line | awk '{ print $4 }'`
encodetit=`echo $line | awk '{ print $5 }'`
encodecrop=`echo $line | awk '{ print $6 }'`
autocrop=""
videobv="600k"
if [ "$encodecrop" != "" ]; then
        autocrop=${encodecrop},
fi
if [ "$encodex" == "0" ]; then
    autocrop=""
fi
if [ "$encodebit" == "1" ]; then
    videobv="900k"
fi
case $encodep in
0)
    encodeinfo="${autocrop}pad='if(gte(iw/ih,16/9),iw,ih*16/9)':'if(gte(iw/ih,16/9),iw*9/16,ih)':(ow-iw)/2:(oh-ih)/2,scale=720:trunc(ow/a/2)*2"
    ;;
1)
    encodeinfo="movie=/usr/hadoop/videologo.png,scale=86:-1[watermark];[in]${autocrop}pad='if(gte(iw/ih,16/9),iw,ih*16/9)':'if(gte(iw/ih,16/9),iw*9/16,ih)':(ow-iw)/2:(oh-ih)/2,scale=720:trunc(ow/a/2)*2[scale];[scale][watermark]overlay=22:14[out]"
    ;;
2)  
    encodeinfo="movie=/usr/hadoop/videologo.png,scale=86:-1[watermark];movie=/usr/hadoop/videopindaologo.png,scale=60:-1[watermark2];[in]${autocrop}pad='if(gte(iw/ih,16/9),iw,ih*16/9)':'if(gte(iw/ih,16/9),iw*9/16,ih)':(ow-iw)/2:(oh-ih)/2,scale=720:trunc(ow/a/2)*2[scale];[scale][watermark]overlay=22:14[1];[1][watermark2]overlay=main_w-overlay_w-22:main_h-overlay_h-22[out]"
    ;;
esac      
/usr/hadoop/bin/hadoop fs -get $input $outpath 2>&1
ffmpeg -y -i $outpath/$filename.mp4 -vcodec libx264 -vprofile high -preset slow -b:v ${videobv} -maxrate ${videobv} -bufsize 1000k -vf "${encodeinfo}" -acodec libfdk_aac -b:a 64k -ac 2 -af 'volume=1.5' $outpath/$type/$filename.qt.mp4 < a 2>&1
/usr/bin/qt-faststart $outpath/$type/$filename.qt.mp4 $outpath/$type/$filename.mp4 < a 2>&1
/usr/hadoop/bin/hadoop fs -put  $outpath/$type/$filename.mp4 ${base}/$filename.mp4 2>&1
/usr/hadoop/bin/hadoop fs -chown $id ${base}/$filename.mp4 2>&1
done
rm -f a
rm -rf $outpath
