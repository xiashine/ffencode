#!/usr/bin/env python

__author__ = 'Julien Boeuf <jboeuf@intertrust.com>'
__copyright__ = 'Copyright 2011, Intertrust Technologies'

import sys
import os
import glob
import re
import os.path as path

def main(args):
    usage = 'create-hls-playlist.py <targetduration> <MainDirectory>'
    
    if len(args) != 2:
        print usage
        sys.exit(1)

    try:
        target_duration = int(args[0])
    except:
        print "target duration must be a number of seconds"
        sys.exit(1)

    top = path.abspath(args[1])
    subdirs = [d for d in os.listdir(top) if path.isdir(path.join(top, d))]
    if len(subdirs) == 0:
        print "no subdirectory in master dir"
        sys.exit(1)
    subdirs = sorted(subdirs)
	# compute the bitrates based on the subdir names
    r = re.compile(r'-[a-z]+(\d+)')
    bitrates = [int(r.search(d).group(1))*1000 for d in subdirs]

    pl_filepath = path.join(top, path.basename(top) + ".m3u8")
    pl = open(pl_filepath, "w")
   
    tsfile_count = 0
    try:
        pl.write("#EXTM3U\n\n")
        for d, b in zip(subdirs, bitrates):
            pl.write("#EXT-X-STREAM-INF:PROGRAM-ID=1, BANDWIDTH=%d\n" % (b,))
            pl.write("%s/index.m3u8\n\n" % (d,))
            abs_subdir = path.join(top, d)

            # check ts file count
            tsfiles = glob.glob(abs_subdir + '/*.ts')
            if tsfile_count == 0:
                tsfile_count = len(tsfiles)
            else:
                if len(tsfiles) != tsfile_count:
                    print 'number of ts files differ in subdirs'

            sub_pl = open(path.join(abs_subdir, "index.m3u8"), "w")
            try:
                sub_pl.write("#EXTM3U\n")
                sub_pl.write("#EXT-X-TARGETDURATION:%d\n" % (target_duration,))
                sub_pl.write("#EXT-X-MEDIA-SEQUENCE:0\n")
                idx = 0
                while True:
                    # hacky but will do
                    ts = [t for t in tsfiles if ("." + str(idx) + ".") in t]
                    if len(ts) == 0:
                        break
                    sub_pl.write("#EXTINF:%d, no desc\n" % (target_duration,))
                    sub_pl.write(path.basename(ts[0]) + "\n")
                    idx += 1
                sub_pl.write("#EXT-X-ENDLIST\n")
            finally:
                sub_pl.close()
    except Exception, e:
        print e
        sys.exit(1)
    finally:
        pl.close()

    if tsfile_count == 0:
        print 'no ts files found in subdirs'
        sys.exit(1)

                      

if __name__ == '__main__':
    main(sys.argv[1:])
