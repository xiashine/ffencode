#!/usr/bin/env python

__author__ = 'Julien Boeuf <jboeuf@intertrust.com>'
__copyright__ = 'Copyright 2011, Intertrust Technologies'

import sys
import os
import glob
import re
import os.path as path

def main(args):
    usage = 'create-hls-playlist2.py <targetduration> <MainDirectory>'
    
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
    #subdirs = sorted(subdirs)
    subdirs = sorted(subdirs, key=lambda x : int(x[3:]))
	# compute the bitrates based on the subdir names
    r = re.compile(r'[a-z]+(\d+)')
    bitrates = [int(r.search(d).group(1))*1000 for d in subdirs]

    pl_filepath = path.join(top, path.basename(top) + ".m3u8")
    pl = open(pl_filepath, "w")
   
    tsfile_count = 0
    try:
        pl.write("#EXTM3U\r\n")
        for d, b in zip(subdirs, bitrates):
            pl.write("#EXT-X-STREAM-INF:PROGRAM-ID=1, BANDWIDTH=%d\r\n" % (b,))
            pl.write("%s/index.m3u8\r\n" % (d,))
            abs_subdir = path.join(top, d)

            # check ts file count
            tsfiles = glob.glob(abs_subdir + '/*.ts')
            if tsfile_count == 0:
                tsfile_count = len(tsfiles)
            else:
                if len(tsfiles) != tsfile_count:
                    print 'number of ts files differ in subdirs'

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
