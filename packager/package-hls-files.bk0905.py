#!/usr/bin/env python

__author__    = 'Julien Boeuf <jboeuf@intertrust.com>'
__copyright__ = 'Copyright 2011, Intertrust Technologies'

import sys
import os
import os.path as path
from optparse import OptionParser, make_option, OptionError
from subprocess import check_call, CalledProcessError
import urlparse
import random
import base64
import shutil
import tempfile

# path tricks
SCRIPT_PATH = path.abspath(path.dirname(__file__))
sys.path += [SCRIPT_PATH]
if sys.platform.startswith('darwin'):
    BIN_PATH = path.join(SCRIPT_PATH, 'bin', 'macosx')
elif sys.platform.startswith('linux'):
    BIN_PATH = path.join(SCRIPT_PATH, 'bin', 'linux')
else:
    BIN_PATH = path.join(SCRIPT_PATH, 'bin', sys.platform)

print  BIN_PATH   
if not path.exists(BIN_PATH):
    raise Error("Platform not supported")

def random_string(bytecount):
    return base64.b16encode(os.urandom(bytecount))


def parse_variant_playlist(filename):
    """yields (media_sequence, duration, media_filename)"""
    media_seq = 0
    duration = 0
    next_line_is_media = False
    with open(filename) as pl:
        for line in pl:
            if len(line) == 0:
                continue
            if next_line_is_media:
                yield (media_seq, 
                       duration, 
                       line.strip())
                media_seq += 1
                next_line_is_media = False
                continue 
            if line.startswith("#EXT-X-MEDIA-SEQUENCE:"):
                media_seq = int(line[line.rfind(':')+1:])
                continue
            if line.startswith("#EXTINF:"):
                duration = int(line[line.rfind(':')+1:line.rfind(',')])
                next_line_is_media = True


def process_main_playlist(filename, output_dir, content_id, 
                          sla_url=None, ri_url=None, preview_url=None):
    """writes drm info in the playlist and yields the variant
       playlists filenames'"""

    # format the key tag
    key_tag = '#EXT-X-KEY:METHOD=MARLIN-BBTS,CID="%s"' % (content_id,)
    if sla_url:
        key_tag += ',SILENT-RIGHTS-URL="%s"' % (sla_url,)
    if ri_url:
        key_tag += ',RIGHTS-ISSUER-URL="%s"' % (ri_url,)
    if preview_url:
        key_tag += ',PREVIEW-RIGHTS-URL="%s"' % (preview_url,)
    key_tag += '\n\n'

    # read, write and yield...
    next_line_is_playlist = False
    with open(filename) as reading_pl:
        with open(path.join(output_dir, path.basename(filename)), "w") as writing_pl:
            for line in reading_pl:
                if len(line) == 0:
                    continue
                if next_line_is_playlist:
                    variant = line.strip()
                    if variant.startswith("http://") or \
                       variant.startswith("..")      or \
                       path.isabs(variant):
                        raise Exception("Variant url %s not supported" % (variant,))
                    yield variant
                    next_line_is_playlist = False
                elif line.startswith('#EXT-X-STREAM-INF:'):
                    if key_tag:
                        writing_pl.write(key_tag)
                        key_tag = None # write it only once
                    next_line_is_playlist = True
                writing_pl.write(line)


def encrypt_ts(ts, media_seq, duration, out_ts, content_id, 
               content_key, traffic_key_seed, iv, ksm_pid, protection,
               sla_url=None, ri_url=None, preview_url=None):
    """encrypts the ts file using the native tool"""
    # create a temp dir
    tmpdir = tempfile.mkdtemp()

    # create a rotation file which will insert the ECM (KSM) after the PAT
    # and the PMT (index 2)
    with open(path.join(tmpdir, 'rot.in'), "w") as rotin:
        rotin.write("2")

    # create the command line
    cmd = [path.join(BIN_PATH, 'Ts2AdaptiveAwareEncrypt'),
           '--key', content_id + '::' + content_key,
           '--traffic-seed', traffic_key_seed,
           '--traffic-key-lifetime', str(duration),
           '--ksm-pid', str(ksm_pid),
           '--protection', protection,
           '--rotation-in', path.join(tmpdir, 'rot.in'),
           '--rotation-out', path.join(tmpdir, 'rot.out'),
           '--first-segment-index', str(media_seq)]
    if sla_url:
        cmd += ['--silent-rights', sla_url]
    if ri_url:
        cmd += ['--rights-issuer', ri_url]
    if preview_url:
        cmd += ['--preview-rights', preview_url]
    cmd += [path.abspath(ts), 
            path.abspath(out_ts)]

    # launch
    print "\nEncrypting media:"
    print " ".join(cmd)
    try:
        check_call(cmd) 
    except CalledProcessError, e:
        raise Exception("binary tool failed with error %d" % e.returncode)
    
    shutil.rmtree(tmpdir)



def main(args):
    usage = 'usage: %prog [options] <contentid> <m3u8file>'
    
    def check_key(option, opt_str, value, parser):
        try:    
            if len(value) != 32:
                raise Error
            long(value, 16)
        except:
            raise OptionError("invalid --key option", option)
        setattr(parser.values, option.dest, value)
 
    option_list = [
        make_option('-k', '--key', default=None, action='callback',
                    type='string', callback=check_key,
                    help="if specified must be 32 hex chars (representing 16 bytes),"\
                          "automatically generated otherwise"),
        make_option('-t', '--traffic-key-seed', default=None, action='callback',
                    type='string', callback=check_key,
                    help="if specified must be 32 hex chars (representing 16 bytes),"\
                          "automatically generated otherwise"),
        make_option('-i', '--traffic-iv', default=None, action='callback',
                    type='string', callback=check_key,
                    help="if specified must be 32 hex chars (representing 16 bytes),"\
                          "automatically generated otherwise"),
        make_option('-e', '--ecm-pid', default=142, type='int',
                    help="pid for the generated ecm [default: %default]"),
        make_option('-v', '--protection', default='bbts-1.1', type='string',
                    help="if specified it should be  bbts-1.1 or bbts-2.0 [takes %default otherwise]"),
        make_option('-o', '--output-dir', default='./ProtectedHls',
                    help="output directory for the protected files [default: %default]"),
        make_option('-r', '--rights-issuer-url',
                    help="rights issuer url"),
        make_option('-s', '--silent-rights-url',
                    help="silent rights url"),
        make_option('-p', '--preview-rights-url',
                    help="preview rights url"),

    ]
    
    parser = OptionParser(usage=usage, option_list=option_list)
    opts, args = parser.parse_args(args)
    if len(args) != 2:
        parser.error("invalid number of arguments")
        
    # try to create the output dir
    os.mkdir(opts.output_dir)

    # content key
    if opts.key is None:
        opts.key = random_string(16)

    # traffic key seed
    if opts.traffic_key_seed is None:
        opts.traffic_key_seed = random_string(16)

    # traffic iv
    if opts.traffic_iv is None:
        opts.traffic_iv = random_string(16)

    # now process
    input_dir = path.dirname(args[1])
    for variant_playlist in process_main_playlist(args[1], 
                                                opts.output_dir, 
                                                args[0], 
                                                opts.silent_rights_url,
                                                opts.rights_issuer_url,
                                                opts.preview_rights_url):
        # create the output dir for the variant playlist and copy
        os.makedirs(path.join(opts.output_dir, 
                              path.dirname(variant_playlist)))
        out_variant_playlist = path.join(opts.output_dir, variant_playlist)
        shutil.copyfile(path.join(input_dir, variant_playlist), 
                        out_variant_playlist)

        # encrypt the segments
        for media_seq, duration, ts in parse_variant_playlist(out_variant_playlist):
            ts_rel_path = path.join(path.dirname(variant_playlist), ts)
            ts = path.join(input_dir, ts_rel_path)
            out_ts = path.join(opts.output_dir, ts_rel_path)
            encrypt_ts(ts, media_seq, duration, out_ts, args[0],
                       opts.key, opts.traffic_key_seed, opts.traffic_iv, 
                       opts.ecm_pid, opts.protection, opts.silent_rights_url, 
                       opts.rights_issuer_url, opts.preview_rights_url)

    # status message
    print "packaging done: content key is %s" % opts.key

if __name__ == '__main__':
    main(sys.argv[1:])





