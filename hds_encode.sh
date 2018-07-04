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

hdsbasepath=$3
if [ -z "$hdsbasepath" ] ; then
		echo "hdsbasepath no empty"
		exit 3
fi

/usr/local/f4fpackager/f4fpackager --input-file=$filepath/$filename.mp4 --content-id=m201312182FPYXQ9ZFU61T83O --common-key=/usr/local/f4fpackager/m1905FlashAccess/m1905-license.key --license-server-url=http://drmfa.m1905.com/flashaccessserver/sampletenant/ --license-server-cert=/usr/local/f4fpackager/m1905FlashAccess/m1905-license.der --transport-cert=/usr/local/f4fpackager/m1905FlashAccess/m1905-transport.der --packager-credential=/usr/local/f4fpackager/m1905FlashAccess/m1905-packager.pfx --credential-pwd=1qazxsw2M1905packager --policy-file=/usr/local/f4fpackager/m1905FlashAccess/ad-policy.pol --output-path=$hdsbasepath


