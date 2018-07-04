#!/bin/bash
unset m
for i in `cat movies_tmp.txt`
do
/usr/hadoop/bin/hadoop fs -get $i ./
tmpfilename=`basename $i`
if [ ! -z $m ];then
tmpfilename="+$tmpfilename"
fi
echo $tmpfilename >> files.txt
m=$((m+1))
done
