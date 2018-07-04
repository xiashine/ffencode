#!/bin/bash
dtdir=$1
dt=$2
for line in `find /data/vdp/images/$dtdir -type f  -name "*.png"`
do
	if [ -f "/data/encode/reshotlist.$dt.log" ]; then
	     if grep -q $line /data/encode/reshotlist.$dt.log; then
	          continue
	     fi
	fi
	filename=$(basename $line)
	path=${line%/*}
	echo $path
	cd $path
	urlpath=`echo ${path} | sed "s/\/data\/vdp\/images\/movie\///g"`
	echo "curl -F "filename=@$filename" http://pic0.m1905.cn/upload/images/$urlpath/$filename"
	curl -F "filename=@$filename" http://pic0.m1905.cn/upload/images/$urlpath/$filename
    echo $line >>/data/encode/reshotlist.$dt.log
done
