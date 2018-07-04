#!/bin/bash
dt=$(date +%Y%m)
for line in `find /data/vdp/images/ -type f  -mtime -7  -name "*.png"`
do
	if [ -f "/data/encode/shotlist.$dt.log" ]; then
	     if grep -q $line /data/encode/shotlist.$dt.log; then
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
    echo $line >>/data/encode/shotlist.$dt.log
done
