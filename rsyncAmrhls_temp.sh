cd /data/vdp/vamrhls/movie/
rsync -vzrtogR --progress --bwlimit=5000 2017/ root@118.145.26.118::video/movie/
