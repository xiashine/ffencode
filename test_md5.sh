key1905="1905"
type="v360p"
filename="m22222222222222"
linkfile1="${type}#${filename}@${key1905}"
linkfile2="${type}flv#${filename}@${key1905}"
echo $linkfile1
echo $linkfile2
md5mp4filename=`echo -n ${linkfile1} |md5sum |cut -d ' ' -f1 |  tr '[a-z]' '[A-Z]' |cut -c1-25`
md5flvfilename=`echo -n ${linkfile2} |md5sum |cut -d ' ' -f1 |  tr '[a-z]' '[A-Z]' |cut -c1-25`
echo $md5mp4filename
echo $md5flvfilename
