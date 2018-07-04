#!/bin/bash
. /data/encode/config.sh

if [ $# -eq 0 ]; then
	echo "no arg filename"
	exit 0
fi
filepath=$1
a=`ls $filepath | wc -l`

if [ $a -eq 0 ]; then
        echo $filepath no exist
        exit 1 
fi

filename=$2
if [ -z "$filename" ] ; then
		echo "filename no empty"
		exit 4
fi

channelid=$3
echo "channelid:${channelid}"
#echo "$(date +%Y-%m-%d) $(date +%T) 	step 1 start encode curl -s -d \"vid=${filename}&status=2\" \"$DOMAIN/api.php?op=video_api&action=edit_video_status\""
#curl -s -d "vid=${filename}&status=2" "$DOMAIN/api.php?op=video_api&action=edit_video_status"


echo "$(date +%Y-%m-%d) $(date +%T) 	${filename}	step2 begin: $BASE/encode/step_2.sh $filepath $filename"
$BASE/encode/step_2.sh $filepath $filename
echo "$(date +%Y-%m-%d) $(date +%T) 	${filename}	step2 end"

echo "$(date +%Y-%m-%d) $(date +%T) 	${filename}	step3 load begin:"
nohup $BASE/encode/step_3.sh $filepath v360p $filename >> $BASE/encode/encode.log&
nohup $BASE/encode/step_3.sh $filepath v480p $filename >> $BASE/encode/encode.log&
nohup $BASE/encode/step_3.sh $filepath v720p $filename mp4 ${channelid} >> $BASE/encode/encode.log&
nohup $BASE/encode/step_3.sh $filepath v3gp1 $filename 3gp >> $BASE/encode/encode.log&
nohup $BASE/encode/step_3.sh $filepath v3gp2 $filename 3gp >> $BASE/encode/encode.log&
nohup $BASE/encode/step_3.sh $filepath v3gp3 $filename 3gp >> $BASE/encode/encode.log&
echo "$(date +%Y-%m-%d) $(date +%T) 	${filename}	step3 load end:"

