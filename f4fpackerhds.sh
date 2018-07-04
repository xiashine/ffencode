for line in `cat /data/encode/tmphds.txt`
do
    filename=`basename $line .mp4`
    path=`dirname $line`
    filepath=/data/vdp/v720p${path}/
    outpath=/data/vdp/v720phds${path}/
    echo "filename:${filename},filepath:${filepath},outpath:${outpath}"
    if [ ! -d $outpath ]; then
        mkdir -p $outpath
    fi
    if [ -f "${filepath}${filename}.f4m" ]; then
                continue
    fi
    /usr/local/f4fpackager/f4fpackager --input-file=${filepath}${filename}.mp4 --content-id=$filename --common-key=/usr/local/f4fpackager/m1905FlashAccess/m1905-license.key --license-server-url=http://drmfa.m1905.com/flashaccessserver/sampletenant/ --license-server-cert=/usr/local/f4fpackager/m1905FlashAccess/m1905-license.der --transport-cert=/usr/local/f4fpackager/m1905FlashAccess/m1905-transport.der --packager-credential=/usr/local/f4fpackager/m1905FlashAccess/m1905-packager.pfx --credential-pwd=1qazxsw2M1905packager --policy-file=/usr/local/f4fpackager/m1905FlashAccess/ad-policy.pol --output-path=$outpath
done
