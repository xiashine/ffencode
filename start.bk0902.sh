#!/bin/bash
. /data/encode/config.sh

PID=$(cat $BASE/encode/pid.out)
if [ $PID -gt $LIMIT ]; then
   exit 0
fi
RSY=$(cat $BASE/encode/rsy.out)
if [ $RSY -eq 1 ]; then
   exit 0
fi
echo "1">$BASE/encode/rsy.out
declare -a ids
declare -a vids
declare -a videopaths
curl -s  "$DOMAIN/api.php?op=video_api&action=video_list" > tmpxml
dos2unix tmpxml
tmp=`sed -n  -e 's/<item //' -e 's/><\/item>//p' tmpxml | sed -e 's/id="//' -e 's/vid="//' -e 's/videopath="//' -e 's/"//g'`
rm tmpxml
item=($(echo $tmp))
for((i=0, j=0; i<${#item[*]}; i++, j++))
do
   ids[j]=${item[i]}
   vids[j]=${item[++i]}
   videopaths[j]=${item[++i]}
done

if [ ${#ids[*]} -eq 0 ]; then
	echo "0">$BASE/encode/rsy.out
	exit 0
fi

for((k=0; k<${#ids[*]}; k++))
do
	
	vpath="$BASE${videopaths[k]}"
	ospath="${videopaths[k]}"
	filename="${vids[k]}"
	channelid="${ids[k]}"
	
	echo "$(date +%Y-%m-%d) $(date +%T)   start encode curl -s -d \"vid=${filename}&status=2\" \"$DOMAIN/api.php?op=video_api&action=edit_video_status\""
	curl -s -d "vid=${filename}&status=2" "$DOMAIN/api.php?op=video_api&action=edit_video_status"
	echo "start rsy channelid:${channelid},vpath:${ospath},filename:${filename}"
	vdirname=`dirname ${ospath}`
	if [ ! -d ${BASE}${vdirname}/ ]; then
		mkdir -p ${BASE}${vdirname}/
	fi
	echo "$(date +%Y-%m-%d) $(date +%T) begin:rsync -vzrtog --progress $SERVERIP::${ospath:1} ${BASE}${vdirname}/"
 	rsync -vzrtog --progress $SERVERIP::${ospath:1} ${BASE}${vdirname}/
	
 	echo "$(date +%Y-%m-%d) $(date +%T) end:rsync"
	echo "$(date +%Y-%m-%d) $(date +%T) 	${filename} step_1 start:"   
	echo "$(date +%Y-%m-%d) $(date +%T) 	${filename}	$BASE/encode/step_1.sh  $vpath  $filename"
	nohup $BASE/encode/step_1.sh  ${vpath} ${filename} ${channelid} >> $BASE/encode/encode.log  2>&1 &
	PID=$(cat $BASE/encode/pid.out)
	PID=$[PID+1]
	echo "pid:$PID"
	echo $PID>$BASE/encode/pid.out
	if [ $PID -gt $LIMIT ]; then
		break
        fi
done
echo "rsy:0"
echo "0">$BASE/encode/rsy.out
