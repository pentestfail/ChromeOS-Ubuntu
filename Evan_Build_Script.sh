## This script intended for Ubuntu Server 12.04 installed on a virtual platform (Parallels Tools install in script)
## Script pulls from dz0ny's original build and is fork of .DEB install from Github
## by @pentestfail
## version 0.1
## 31 AUG, 2013

## Update Ubuntu and install dependencies & random tools (Add any tools you want now! you won't be able to later!)
apt-get update
apt-get install unzip, nano, xorg, lightdm, alsa, icedtea-7-plugin
alsactl init

## Download the goodies
export CHROME="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
export TALK="https://dl.google.com/linux/direct/google-talkplugin_current_amd64.deb"

## Setup JAVA environment, etc.
mkdir -p /usr/lib/mozilla/plugins/
ln -s /usr/lib/jvm/java-7-oracle/jre/lib/amd64/libnpjp2.so /usr/lib64/cromo/libnpjp2.so
ln -s /usr/lib/jvm/java-7-oracle/jre/lib/amd64/libnpjp2.so /usr/lib64/mozilla/plugins/libnpjp2.so
ln -s /usr/lib/jvm/java-7-oracle/jre/lib/amd64/libnpjp2.so /usr/lib64/libnpjp2.so
ln -s /usr/lib/jvm/java-7-oracle/jre/lib/amd64/libnpjp2.so /opt/google/chrome/libnpjp2.so
PATH="/usr/lib/jvm/java-7-oracle/jre/bin/"
JAVA_HOME="/usr/lib/jvm/java-7-oracle/"
env-update

#Install Parallels or VMWare Tools
mount /dev/cdrom /media/cdrom
/media/cdrom/install

#Turn up volume and test audio
alsamixer
speaker-test -c 2

## Install MP3 & MP4 libraries
cp /opt/chrome-unstable/opt/google/chrome/libffmpegsumo.so /usr/lib/cromo/ -f
cp /opt/chrome-unstable/opt/google/chrome/libffmpegsumo.so /opt/google/chrome/ -f
cp /opt/chrome-unstable/opt/google/chrome/libffmpegsumo.so /usr/lib/mozilla/plugins/ -f

## Install Chrome PDF to proper directories
cp /opt/chrome-unstable/opt/google/chrome/libpdf.so /opt/google/chrome/ -f

## Install flash to proper directories
cp /opt/chrome-unstable/opt/google/chrome/PepperFlash/libpepflashplayer.so /opt/google/chrome/pepper/ -f
cp /opt/chrome-unstable/opt/google/chrome/PepperFlash/manifest.json /opt/google/chrome/pepper/ -f
curl -L https://raw.github.com/gist/3065781/pepper-flash.info > /opt/google/chrome/pepper/pepper-flash.info

## Install Google Talk to proper directories
ln -s /opt/google/talkplugin/libnpgoogletalk.so /opt/google/chrome/pepper/libnpgoogletalk.so
ln -s /opt/google/talkplugin/libnpgtpo3dautoplugin.so /opt/google/chrome/pepper/libnpgtpo3dautoplugin.so

## Install updated chrome build, Java, GoogleTalk, Flash, etc.
wget https://gist.github.com/shagr4th/6178203/raw/ab97b222c7a8679e933a83a13a3223261ebdadd4/br3ker.sh

## Set lightdm to auto-login with "mybitch" username
sudo /usr/lib/lightdm/lightdm-set-defaults --autologin mybitch