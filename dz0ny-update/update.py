#!/usr/bin/python
# -*- coding: utf-8 -*-

from bs4 import BeautifulSoup
import urllib
import re
import shlex
import subprocess
from urlparse import parse_qs
import httplib
from urlparse import urlparse
import os
import time

debug = False

soup = BeautifulSoup(urllib.urlopen('http://chromeos.hexxeh.net/').read())


## {{{ http://code.activestate.com/recipes/541096/ (r1)

def confirm(prompt=None, resp=False):
    """prompts for yes or no response from the user. Returns True for yes and
    False for no.

    'resp' should be set to the default value assumed by the caller when
    user simply types ENTER.

    >>> confirm(prompt='Create Directory?', resp=True)
    Create Directory? [y]|n: 
    True
    >>> confirm(prompt='Create Directory?', resp=False)
    Create Directory? [n]|y: 
    False
    >>> confirm(prompt='Create Directory?', resp=False)
    Create Directory? [n]|y: y
    True

    """

    if prompt is None:
        prompt = 'Confirm'

    if resp:
        prompt = '%s [%s]|%s: ' % (prompt, 'y', 'n')
    else:
        prompt = '%s [%s]|%s: ' % (prompt, 'n', 'y')

    while True:
        ans = raw_input(prompt)
        if not ans:
            return resp
        if ans not in ['y', 'Y', 'n', 'N']:
            print 'please enter y or n.'
            continue
        if ans == 'y' or ans == 'Y':
            return True
        if ans == 'n' or ans == 'N':
            return False


## end of http://code.activestate.com/recipes/541096/ }}}

def get_head(name, req):
    url = urlparse(req)
    conn = httplib.HTTPConnection(url.netloc)
    conn.request('HEAD', url.path + '?' + url.query)
    res = conn.getresponse()

    return res.getheader(name)


def run(cmd, d=False, shell=False):

    # print 'cwd', os.path.dirname(os.path.abspath(__file__))

    print cmd
    if not debug or d:
        proc = subprocess.Popen(shlex.split(cmd), stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                shell=False)
        (curlstdout, curlstderr) = proc.communicate()

        # print '|', curlstdout + curlstderr, '|'

        return curlstdout + curlstderr


def find_croot():

    disk = run('bash -c "ls /dev/disk/by-label/ -all | grep C-ROOT"', True).split('/')
    print 'C-ROOT is :', disk[len(disk) - 1]
    if confirm(prompt='Is this correct?', resp=True):
        return disk[len(disk) - 1]
    else:
        return input('Enter correct disk? (sdd5)?')


def unzip(verzija):
    run('unzip ' + verzija + '-chromeos.zip')


def kpartx(verzija):

    # http://blog.vodkamelone.de/archives/137-Mounting-a-disk-image-containing-several-partitions.html

    disk = find_croot()
    run('kpartx -a -v ChromeOS-Vanilla-' + verzija + '.img')
    time.sleep(5)
    run('dd if=/dev/mapper/loop0p3 of=/dev/' + disk)
    time.sleep(5)
    run('fsck /dev/' + disk + ' -fy')
    time.sleep(5)

    # run('mount /dev/mapper/loop0p3 /mnt/ -o loop,ro')
    # Time.sleep(5)
    # run('bash -c "cd /mnt; tar cvf ' + loc + '/chromeos.tar opt/"')
    # time.sleep(5)
    # run('umount /mnt/')
    # time.sleep(5)

    run('kpartx -d -v ChromeOS-Vanilla-' + verzija + '.img')


def curl(zip_image, verzija):
    run('curl -C - -z ' + verzija + '-chromeos.zip -L ' + zip_image + ' -o ' + verzija
        + '-chromeos.zip')


def get_version(lin):
    url = parse_qs(lin['href'])
    return str(url['build'][0])


def main():

    # http://chromeos.hexxeh.net/download.php?track=vanilla&build=2556.0.2012_07_07_1636-rccf8f959&type=usb

    linki = soup.find_all(href=re.compile('track=vanilla.+type=usb'))
    i = 1
    for lin in linki:

        print '(', i, ')', get_version(lin)
        i += 1

        # break

    verzija = get_version(linki[int(input('Choose version to download?')) - 1])

    zip_image = get_head('location', 'http://chromeos.hexxeh.net/download.php?track=vanilla&build='
                         + verzija + '&type=usb')
    size = int(get_head('content-length', zip_image))
    try:
        size_local = int(os.stat(verzija + '-chromeos.zip').st_size)
    except Exception:
        size_local = 0

    print 'size', size
    print 'size local', size_local
    if size != size_local:
        curl(zip_image, verzija)
    unzip(verzija)
    kpartx(verzija)


    # http://distribution.hexxeh.net/archive/vanilla/2591.0.2012_07_13_1633-rd712ae90/ChromeOS-Vanilla-2591.0.2012_07_13_1633-rd712ae90.zip

if __name__ == '__main__':
    main()
