#!/bin/bash
. /data/encode/config.sh
echo "$(date +%Y-%m-%d) $(date +%T) ffmpeg m3u8 starting ..."

arrdir=("v480p" "v360p" "v720p" "v1080p")
for var in ${arrdir[@]};do
	status_m=0
    case "$var" in
            "v720p" ) 
            status_m=15
            ;;
            "v1080p" )
             status_m=25
            ;;
            "v480p" )
             status_m=14
            ;;
            "v360p" )
             status_m=13
             ;;
    esac
	#cat ${var}_t.txt | while read line;do
	for line in $(cat ${var}_t.txt)
	do
		echo $line
		filename=`echo ${line//,/ } | awk '{ print $1 }'`
		videopath=`echo ${line//,/ } | awk '{ print $2 }'`
		md5filename=`basename $videopath .mp4`
		path=`dirname $videopath`
		#echo "filename:${filename},videopath:${videopath},md5filename:${md5filename},path:${path}"
		if [ ! -f "/data/vdp/${var}${videopath}" ]; then
			continue
		fi
		if [ -f "/data/vdp/${var}m3u8${path}/$md5filename.m3u8" ]; then
			echo "/data/vdp/${var}m3u8${path}/$md5filename.m3u8" >> log_${var}_exist.log
		fi
		#echo "filename:${filename},videopath:${videopath},md5filename:${md5filename},path:${path}"
		if [ ! -f "/data/vdp/${var}m3u8${path}/$md5filename.m3u8" ]; then
			echo "filename:${filename},videopath:${videopath},md5filename:${md5filename},path:${path}" >> log_v480p_m3u8.log
			cd /data/vdp/${var}m3u8${path}/
			ffmpeg -i /data/vdp/${var}${videopath} -c copy -map 0 -vbsf h264_mp4toannexb -segment_list_type m3u8 -flags +global_header -f segment -segment_list ${md5filename}.m3u8 -segment_time 30 ${md5filename}.%03d.ts >> log_ffmpeg_m3u8.log
			#echo "/data/encode/m3u8_encode.sh /data/vdp/${var}${path}/ ${md5filename} /data/vdp/${var}m3u8${path}/"
			#/data/encode/m3u8_encode.sh /data/vdp/${var}${path}/ ${md5filename} /data/vdp/${var}m3u8${path}/ >> log_ffmpeg_m3u8.log
			if [  -f "/data/vdp/${var}m3u8${path}/$md5filename.m3u8" ]; then
				size=`ls -l /data/vdp/${var}$videopath | awk '{ print int($5) }'`
	        	timelen=`/usr/local/bin/mediainfo "--Inform=Video;%Duration%" /data/vdp/${var}$videopath`
	        	echo "curl -s -d \"vid=${filename}&timelen=${timelen}&size=${size}&videopath=${path}/$md5filename.m3u8&status=${status_m}&channelid=${status_m}" "$DOMAIN/api.php?op=video_api&action=edit_video_status\""
	            curl -s -d "vid=${filename}&timelen=${timelen}&size=${size}&videopath=${path}/$md5filename.m3u8&status=${status_m}&channelid=${status_m}" "$DOMAIN/api.php?op=video_api&action=edit_video_status"
	       		 fi
	   	fi    
	done
done
