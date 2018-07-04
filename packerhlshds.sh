#!/bin/bash
. /data/encode/config.sh

HDS=$(cat $BASE/encode/hdspid.out)
if [ $HDS -eq 1 ]; then
   exit 0
fi

echo "1">$BASE/encode/hdspid.out

/usr/local/bin/python2.7 /data/encode/packager/main.py
/usr/local/bin/python2.7 /data/encode/packager/main2.py

echo "0">$BASE/encode/hdspid.out
