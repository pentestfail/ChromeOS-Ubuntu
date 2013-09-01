#Flash, java, mp3 and mp4 and pdf support for Chromium OS builds by hexxeh

This script downloads and installs libraries needed for Chromium, so that you can actually "TEST" multimedia experience.
 
##How to use?

Simply run as root user

    curl -L http://goo.gl/qPrfd | bash

or if you prefer wget
    
    wget -qO- http://goo.gl/qPrfd | bash

Then reboot computer!

##You don't know how to become root user?

    CTRL+ALT+F2
    $ chronos   (user)
    $ facepunch (password)
    $ sudo su

That's it, enjoy!

## No sound?

Login as root

    $ mount -o remount, rw /
    $ alsaconf

Choose your sound card, then reboot!

## Bugs

deb2tar.py was the hardest thing to do here, it should have a lot of bugs (probably) and might only work for this version.