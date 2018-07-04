#!/bin/bash

if [ $# -eq 0 ]
then
echo "no arg filename"
exit 0
fi
filepath=$1
if [ -z "$filepath" ]
then
        echo "$filepath file no exists"
        exit 1 
fi


filename=$2
if [ -z "$filename" ] ; then
		echo "filename no empty"
		exit 2
fi

m3u8basepath=$3
if [ -z "$m3u8basepath" ] ; then
		echo "m3u8basepath no empty"
		exit 3
fi

cd $m3u8basepath

/usr/local/bin/ffmpeg -i $filepath/$filename.mp4 -c copy -map 0 -vbsf h264_mp4toannexb -segment_list_type m3u8 -flags +global_header -f segment -segment_list $filename.m3u8 -segment_time 5 $filename.%03d.ts
     
#/usr/local/bin/mp4split -o $filepath/$filename.ismv  $filepath/$filename.mp4
#/usr/local/bin/mp4split -o $filepath/$filename.ism  $filepath/$filename.ismv
#/usr/local/bin/mp4split -o $filepath/$filename.ismc $filepath/$filename.ismv
#/usr/local/bin/mp4split -o $filepath/$filename.m3u8 $filepath/$filename.ismv
#if [ -f "$filepath/$filename.m3u8" ]; then
#	sed -i "s/no desc//g" $filepath/$filename*.m3u8
#	sed -i "s/\#EXT\-X\-TARGETDURATION\:\([0-9]\)\$/\#EXT\-X\-TARGETDURATION\:10/g" $filepath/$filename*.m3u8
#	sed -i "s/\#\#\\(.*\)mod\_smooth\_streaming\(.*\)/\#\#\\1WWW\.M1905\.COM/g" $filepath/$filename*.m3u8
#	sed -i "s/\.ism?format=ts&video=\([0-9]\+\)&bitrate=\([0-9]\+\)&audio=\([0-9]\+\)&bitrate=\([0-9]\+\)/_vi\1_vb\2_au\3_ab\4.ts/g" $filepath/$filename*.m3u8
	
#	mv  $filepath/$filename*.m3u8 $m3u8basepath
#	mv  $filepath/$filename.ism* $m3u8basepath
#fi	
