#!/usr/bin/python
# -*- coding: utf-8 -*-

"""

# deb2tar - convert a Debian Linux .deb file to a .tar
#
# First line -- file header: "!<arch>" or similar
# Multiple blocks -- each one, a header line followed by data
# Header line -- <filename> <num1> <num2> <num3> <mode> <len>
# Data -- <len> bytes of data
# We want the block called "data.tar.*"

"""

import shlex
import os
import sys


def copypart(
    src,
    dest,
    start,
    length,
    bufsize=1024 * 1024,
    ):
    """
      Binary copy
    """

    in_file = open(src, 'rb')
    in_file.seek(start)

    out_file = open(dest, 'wb')
    pointer = start
    chunk = False
    amount = bufsize
    while pointer < length:
        if length - pointer < amount:
            amount = length - pointer
        chunk = in_file.read(amount)
        pointer += len(chunk)
        out_file.write(chunk)

    in_file.close()
    out_file.close()


def main(file_open, file_write):
    """
      Copy tar data block
    """

    print 'Source file:', file_open
    print 'Destination file:', file_write
    zacetek = 0
    konec = 0
    file_name = ''
    with open(file_open, 'r', 1024 * 1024) as in_file:
        for (pointer, line) in enumerate(in_file):
            zacetek += len(line)
            if 'data.tar' in line:
                meta = shlex.split(line[line.find('data.tar'):len(line)])
                konec = int(meta[5])
                file_name = str(meta[0])
                break

    statinfo = os.stat(file_open)
    if statinfo.st_size - konec == zacetek:
        copypart(file_open, file_write, int(zacetek), int(konec) + int(zacetek))
    else:
        print '----DEBUG----'
        print 'start block', zacetek
        print 'end block', konec
        print 'end deb', statinfo.st_size
        print 'diff', statinfo.st_size - konec
        print 'Internal filename is ' + file_name
        print 'meta', meta
        print 'Failed parsing file! Internal meta mismatch, please report this to author!'
        print '----DEBUG----'

if __name__ == '__main__':
    try:
        main(sys.argv[1], sys.argv[2])
    except Exception, e:
        print e
        print 'Usage:', sys.argv[0], 'debian_file.deb', 'tar_file.tar.lzma or gz'
