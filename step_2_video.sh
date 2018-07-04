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

filename=$2
if [ -z "$filename" ] ; then
		echo "filename no empty"
		exit 4
fi

encodeinfo=$3

filesize=`ls -l $filepath | awk '{ print int($5/1024/20) }'`
if [ $filesize -eq 0 ];then
	echo "filesize less 10m"
	exit 3
fi


if [ "${filename:0:1}" == "m" ]; then
        dt="movie"
else
        dt="video"
fi

dt="${dt}/${filename:1:4}/${filename:5:2}/${filename:7:2}"

splitpath="$BASE/vdp/tmp/$dt/$filename/"
imagepath="$BASE/vdp/images/$dt/"

echo "$(date +%Y-%m-%d) $(date +%T) 	${filename}	step2  begin:"


/usr/hadoop/bin/hadoop fs -test -e $splitpath
if [ $? -ne 0 ]; then
		if [ ! -d $splitpath ]; then
		      mkdir -p $splitpath
		fi
		echo "$(date +%Y-%m-%d) $(date +%T) 	${filename}	step2: mkvmerge --split size:64m $filepath -o $splitpath$filename.%05d.mp4"
		/usr/local/bin/mkvmerge --split 300s $filepath -o $splitpath$filename.%05d.mp4
		/usr/hadoop/bin/hadoop fs -mkdir $splitpath
		for i in `ls $splitpath/$filename.*.mp4`; do /usr/hadoop/bin/hadoop fs -put $i $splitpath; done
		
		tmp_file=$filename-tmp.txt
		num=6
		true > ${tmp_file}
		/usr/hadoop/bin/hadoop fs -mkdir ${splitpath}input
		autocrop=`/usr/local/bin/ffmpeg -i $filepath -t 300 -vf select='eq(pict_type\,PICT_TYPE_I)',cropdetect -f null - 2>&1 | awk '/crop/ { print $NF }' | tail -1`
		echo "autocrop:${autocrop}"
		for i in `ls $splitpath$filename.[0-9][0-9][0-9][0-9][0-9].mp4`;do
			tmpfilename=`basename $i`
			echo "${splitpath}${tmpfilename} ${encodeinfo//,/ } ${autocrop}"
			echo "${splitpath}${tmpfilename} ${encodeinfo//,/ } ${autocrop}" >> ${tmp_file}
		done
		rows="$(($(wc -l ${tmp_file}|cut -d' ' -f1)/$num))"
		if [ $rows -eq 0 ]
		then
		rows=1
		fi
		split -l $rows ${tmp_file} movies-$filename-
		/usr/hadoop/bin/hadoop fs -put movies-$filename-[a-z0-9][a-z0-9] ${splitpath}input
		rm  movies-$filename-*
		rm ${tmp_file}
		
		if [ ! -d $imagepath ]; then
		      mkdir -p $imagepath
		fi

		echo "$(date +%Y-%m-%d) $(date +%T) 	${filename}	step2: snapshot picture"
		
		size=`ls -l $filepath | awk '{ print int($5) }'`
		timelen=`/usr/local/bin/mediainfo "--Inform=Video;%Duration%" $filepath`
		ss=`echo $timelen | awk '{ print int($1/1000/10) }'`
		echo "$(date +%Y-%m-%d) $(date +%T) 	${filename}	step2:/usr/local/bin/ffmpeg -i $filepath -y -f  image2  -ss ${ss}  -vframes 1  ${imagepath}/${filename}.jpg"
		/usr/local/bin/ffmpeg -y -ss ${ss} -i $filepath -f image2 -vframes 1  ${imagepath}/${filename}.jpg
		
		echo "$(date +%Y-%m-%d) $(date +%T) 	${filename}	step2:curl -d \"vid=${filename}&timelen=${timelen}&size=${size}&picpath=/images/${dt}/${filename}.jpg&status=2\" \"$DOMAIN/api.php?op=video_api&action=edit_video_status\" "
		curl -s -d "vid=${filename}&timelen=${timelen}&size=${size}&picpath=/images/${dt}/${filename}.jpg&status=2" "$DOMAIN/api.php?op=video_api&action=edit_video_status"
fi

echo "$(date +%Y-%m-%d) $(date +%T) 	${filename}	step2 end."
