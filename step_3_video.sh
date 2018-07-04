#!/bin/bash
. /data/encode/config.sh

if [ $# -eq 0 ]
then
echo "no arg filename"
exit 0
fi
filepath=$1
if [ ! -f "$filepath" ]
then
        echo "$filepath file no exists"
        exit 1 
fi
type=$2
if [ -z "$type" ] ; then
			echo "type no empty"
			exit 2
fi

filename=$3
if [ -z "$filename" ] ; then
		echo "filename no empty"
		exit 4
fi

prex=$4
if [ -z "$prex" ] ; then
		prex="mp4"
fi
channelid=$5
echo "channelid:${channelid},type:${type}"

if [ "${filename:0:1}" == "m" ]; then
        dt="movie"
else
        dt="video"
fi

dt="${dt}/${filename:1:4}/${filename:5:2}/${filename:7:2}"


splitpath="$BASE/vdp/tmp/$dt/$filename/"
basepath="$BASE/vdp/$type/$dt/$filename/"
hadooppath="$BASE/vdp/$type/$dt/$filename/"
if [ "$type" == "v720p" ]||[ "$type" == "v360p" ]||[ "$type" == "v480p" ]; then
	flvbasepath="$BASE/vdp/${type}flv/$dt/$filename/"
	m3u8basepath="$BASE/vdp/${type}m3u8/$dt/$filename/"
	if [ ! -d $flvbasepath ]; then
		mkdir -p $flvbasepath
	fi
	if [ ! -d $m3u8basepath ]; then
			mkdir -p $m3u8basepath
	fi
fi

if [ "$type" == "v720p" ]&&[ $channelid -eq 30 ]; then
	hdsbasepath="$BASE/vdp/${type}hds/$dt/$filename/"
	if [ ! -d $hdsbasepath ]; then
                mkdir -p $hdsbasepath
        fi
fi

echo "$(date +%Y-%m-%d) $(date +%T) 	${filename} $type	step3  begin:"

/usr/hadoop/bin/hadoop fs -test -e $hadooppath
if [ $? -ne 0 ]; then
	/usr/hadoop/bin/hadoop fs -mkdir $hadooppath
fi
if [ ! -d $basepath ]; then
		mkdir -p $basepath
fi

#hadoop

echo  "$(date +%Y-%m-%d) $(date +%T) 	${filename} $type	step3:/usr/hadoop/bin/hadoop jar /usr/hadoop/contrib/streaming/hadoop-streaming-1.1.2.jar   -input ${splitpath}input -output ${splitpath}${type} -mapper $BASE/encode/mapper_${type}_video.sh  -file $BASE/encode/mapper_${type}_video.sh -jobconf mapred.job.name=\"${type}-${filename}\""
/usr/hadoop/bin/hadoop jar /usr/hadoop/contrib/streaming/hadoop-streaming-1.1.2.jar   -input ${splitpath}input -output ${splitpath}${type} -mapper $BASE/encode/mapper_${type}_video.sh  -file $BASE/encode/mapper_${type}_video.sh -jobconf mapred.job.name="${type}-${filename}"
echo  "$(date +%Y-%m-%d) $(date +%T) 	${filename} $type	step3:hadoop end."

#reduce
echo  "$(date +%Y-%m-%d) $(date +%T) 	${filename} $type	step3:reduce begin"
tmp_file=movies_tmp.txt
dir="$BASE/tmp/$(date +%s%N)"
mkdir -p $dir
cd $dir
true > ${tmp_file}
/usr/hadoop/bin/hadoop fs -ls $hadooppath|awk '{print $8}'|sed '/^$/d' >> ${tmp_file}
unset m
for i in `cat ${tmp_file}`
do
/usr/hadoop/bin/hadoop fs -get $i $dir
tmpfilename=`basename $i`
cutfilelen=`/usr/local/bin/mediainfo "--Inform=Video;%Duration%" ${tmpfilename}`
jsonfile="${tmpfilename}"
jsonlen="${cutfilelen}"
if [ ! -z $m ];then
tmpfilename="+$tmpfilename"
jsonfile=",${jsonfile}"
jsonlen=",${jsonlen}"
fi
jsoncutfiles="${jsoncutfiles}${jsonfile}"
jsoncutlens="{$jsoncutlens}${jsonlen}"
echo $tmpfilename >> $dir/files.txt
m=$((m+1))
done

jsoncutfiles="[{\"path\":\"${jsoncutfiles}\",\"duration\":\"${jsoncutlens}\"}]"
jsoncutlens="0"

if [ "$prex" == "mp4" ]; then
	/usr/local/bin/mkvmerge -o $dir/tmp_$filename.$prex `cat $dir/files.txt`
	/usr/local/bin/ffmpeg -y -i $dir/tmp_$filename.$prex -vcodec copy -acodec copy $dir/qt_$filename.$prex
	/usr/bin/qt-faststart  $dir/qt_$filename.$prex  $dir/$filename.$prex
else
	/usr/local/bin/mkvmerge -o $dir/tmp_$filename.$prex `cat $dir/files.txt`
	/usr/local/bin/ffmpeg -y -i $dir/tmp_$filename.$prex -vcodec copy -acodec copy $dir/$filename.$prex
fi
if [ "$type" == "v720p" ]||[ "$type" == "v360p" ]||[ "$type" == "v480p" ]; then
	/usr/local/bin/ffmpeg -y -i $dir/tmp_$filename.$prex -vcodec copy -acodec copy $dir/tmp_$filename.flv
	/usr/local/bin/yamdi -i $dir/tmp_$filename.flv -o $dir/$filename.flv
	mv $dir/$filename.flv $flvbasepath
	$BASE/encode/m3u8_encode.sh $dir/ $filename $m3u8basepath
fi
if [ "$type" == "v720p" ]&&[ $channelid -eq 30 ]; then
        if [ -f "$dir/$filename.$prex" ]; then
		$BASE/encode/hds_encode.sh $dir/ $filename $hdsbasepath
	fi
fi

/usr/hadoop/bin/hadoop fs -put $dir/$filename.$prex  $hadooppath
mv $dir/$filename*.$prex $basepath
rm -rf $dir
echo  "$(date +%Y-%m-%d) $(date +%T) 	${filename} $type	step3:reduce end"

echo "$(date +%Y-%m-%d) $(date +%T)    ${filename} $type       step4:update vms"
#step 4 update vms
if [ -f "$basepath/$filename.$prex" ]; then
	status=0
	status_flv=0
	status_m=0
	status_c=0
	status_h=0
	status_e=0
	case "$type" in
		"v720p" ) 
		status=9
		status_flv=12
		status_m=15
		status_c=18
		status_h=19
		status_e=20
		;;
		"v480p" )
		 status=8
		 status_flv=11
		 status_m=14
		 status_c=17
		;;
		"v360p" )
		 status=7
		 status_flv=10
		 status_m=13
		 status_c=16
		 ;;
		"v3gp1" ) status=6 ;;
		"v3gp2" ) status=5 ;;
		"v3gp3" ) status=4 ;;	
	esac
	echo "$(date +%Y-%m-%d) $(date +%T)    ${filename} status:${status} status_flv:${status_flv} status_m:${status_m}"	
	size=`ls -l $basepath/$filename.$prex | awk '{ print int($5) }'`
	timelen=`/usr/local/bin/mediainfo "--Inform=Video;%Duration%" $basepath/$filename.$prex`
	echo "$(date +%Y-%m-%d) $(date +%T) 	${filename} $type	step3: curl -d \"vid=${filename}&timelen=${timelen}&size=${size}&videopath=/$dt/$filename/$filename.$prex&status=${status}&channelid=${status}\" $DOMAIN/api.php?op=video_api&action=edit_video_status"
	curl -s -d "vid=${filename}&timelen=${timelen}&size=${size}&videopath=/$dt/$filename/$filename.$prex&status=${status}&channelid=${status}" "$DOMAIN/api.php?op=video_api&action=edit_video_status"
	
	if [ "$type" == "v720p" ]||[ "$type" == "v360p" ]||[ "$type" == "v480p" ]; then
		
		if [ -f "$flvbasepath/$filename.flv" ]; then
			size=`ls -l $flvbasepath/$filename.flv | awk '{ print int($5) }'`
			timelen=`/usr/local/bin/mediainfo "--Inform=Video;%Duration%" $flvbasepath/$filename.flv`
			curl -s -d "vid=${filename}&timelen=${timelen}&size=${size}&videopath=/$dt/$filename/$filename.flv&status=${status_flv}&channelid=${status_flv}" "$DOMAIN/api.php?op=video_api&action=edit_video_status"
		fi
		if [ -f "$m3u8basepath/$filename.m3u8" ]; then
			curl -s -d "vid=${filename}&timelen=${timelen}&size=${size}&videopath=/$dt/$filename/$filename.m3u8&status=${status_m}&channelid=${status_m}" "$DOMAIN/api.php?op=video_api&action=edit_video_status"
		fi
		jsoncutlens="${timelen}"
		curl -s -d "vid=${filename}&timelen=${jsoncutlens}&size=&videopath=${jsoncutfiles}&status=${status_c}&channelid=${status_c}" "$DOMAIN/api.php?op=video_api&action=edit_video_status"
		
	fi
	
	if [ "$type" == "v720p" ]; then
		 if [ -f "$hdsbasepath/$filename.f4m" ]&&[ $channelid -eq 30 ]; then
           curl -s -d "vid=${filename}&timelen=${timelen}&size=${size}&videopath=/$dt/$filename/$filename.f4m&status=${status_h}&channelid=${status_h}" "$DOMAIN/api.php?op=video_api&action=edit_video_status"
     		fi   
		echo  "$(date +%Y-%m-%d) $(date +%T) 	${filename} $type	step3:curl -s -d \"vid=${filename}&status=22\" $DOMAIN/api.php?op=video_api&action=edit_video_status"
		curl -s -d "vid=${filename}&status=22" "$DOMAIN/api.php?op=video_api&action=edit_video_status"
	fi
else
	echo  "$(date +%Y-%m-%d) $(date +%T) 	${filename} $type	step3:curl -s -d \"vid=${filename}&status=44\" $DOMAIN/api.php?op=video_api&action=edit_video_status"
	curl -s -d "vid=${filename}&status=44" "$DOMAIN/api.php?op=video_api&action=edit_video_status"
fi

if [ "$type" == "v720p" ]; then
		PID=$(cat $BASE/encode/vpid.out)
		echo $[PID-1]>$BASE/encode/vpid.out
fi
echo "$(date +%Y-%m-%d) $(date +%T) 	${filename} $type	step3 end."

