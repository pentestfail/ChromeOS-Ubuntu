#!/bin/bash
#based on https://wiki.archlinux.org/index.php/Chromium

if [ `uname -m` == 'x86_64' ]; then
  # 64-bit
  export CHROME="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
  export TALK="https://dl.google.com/linux/direct/google-talkplugin_current_amd64.deb"
  export JAVA="http://javadl.sun.com/webapps/download/AutoDL?BundleId=65687"
else
  # 32-bit
  export CHROME="https://dl-ssl.google.com/linux/direct/google-chrome-stable_current_i386.deb"
  export TALK="https://dl.google.com/linux/direct/google-talkplugin_current_i386.deb"
  export JAVA="http://javadl.sun.com/webapps/download/AutoDL?BundleId=65685"
fi


#clean stuff
mount -o remount, rw /
cd /opt/
rm "/opt/deb2tar.py"

curl -o "/opt/deb2tar.py" "https://raw.github.com/gist/3065781/deb2tar.py"

mkdir -p /usr/lib/mozilla/plugins/

#Flash, pdf

echo "Downloading Google Chrome"
curl -z "/opt/chrome-bin.deb" -o "/opt/chrome-bin.deb" -L $CHROME


python /opt/deb2tar.py /opt/chrome-bin.deb /opt/chrome.tar.lzma
rm -rf chrome-unstable
mkdir chrome-unstable
tar -xvf /opt/chrome.tar.lzma -C chrome-unstable

#mp3,mp4
cp /opt/chrome-unstable/opt/google/chrome/libffmpegsumo.so /usr/lib/cromo/ -f
cp /opt/chrome-unstable/opt/google/chrome/libffmpegsumo.so /opt/google/chrome/ -f
cp /opt/chrome-unstable/opt/google/chrome/libffmpegsumo.so /usr/lib/mozilla/plugins/ -f

#pdf
cp /opt/chrome-unstable/opt/google/chrome/libpdf.so /opt/google/chrome/ -f

#flash
cp /opt/chrome-unstable/opt/google/chrome/PepperFlash/libpepflashplayer.so /opt/google/chrome/pepper/ -f
cp /opt/chrome-unstable/opt/google/chrome/PepperFlash/manifest.json /opt/google/chrome/pepper/ -f
curl -L https://raw.github.com/gist/3065781/pepper-flash.info > /opt/google/chrome/pepper/pepper-flash.info

rm -rf chrome-unstable
rm /opt/chrome.tar.lzma


## Google Talk
echo "Downloading Google Talk plugin"
curl -z "/opt/talk-bin.deb" -o "/opt/talk-bin.deb" -L $TALK

python /opt/deb2tar.py /opt/talk-bin.deb /opt/talk.tar.gz
rm -rf /opt/google/talkplugin

tar -xvf /opt/talk.tar.gz -C /
rm /opt/google/chrome/pepper/libnpgoogletalk.so
ln -s /opt/google/talkplugin/libnpgoogletalk.so /opt/google/chrome/pepper/libnpgoogletalk.so
rm /opt/google/chrome/pepper/libnpgtpo3dautoplugin.so
ln -s /opt/google/talkplugin/libnpgtpo3dautoplugin.so /opt/google/chrome/pepper/libnpgtpo3dautoplugin.so

rm /opt/talk.tar.gz

## JAVA
## JAVA
echo "Downloading Oracle Java"
curl -z "/opt/java-bin.tar.gz" -o "/opt/java-bin.tar.gz" -L $JAVA

rm -rf /usr/lib/jvm/java-7-oracle/jre/
mkdir -p /usr/lib/jvm/java-7-oracle/jre/
tar -xvf /opt/java-bin.tar.gz -C /usr/lib/jvm/java-7-oracle/jre/ --strip-components 1
rm /usr/lib/cromo/libnpjp2.so
if [ `uname -m` == 'x86_64' ]; then
  ln -s /usr/lib/jvm/java-7-oracle/jre/lib/amd64/libnpjp2.so /usr/lib64/cromo/libnpjp2.so
  ln -s /usr/lib/jvm/java-7-oracle/jre/lib/amd64/libnpjp2.so /usr/lib64/mozilla/plugins/libnpjp2.so
  ln -s /usr/lib/jvm/java-7-oracle/jre/lib/amd64/libnpjp2.so /usr/lib64/libnpjp2.so
  ln -s /usr/lib/jvm/java-7-oracle/jre/lib/amd64/libnpjp2.so /opt/google/chrome/libnpjp2.so
else
  ln -s /usr/lib/jvm/java-7-oracle/jre/lib/i386/libnpjp2.so /usr/lib/cromo/libnpjp2.so
  ln -s /usr/lib/jvm/java-7-oracle/jre/lib/i386/libnpjp2.so /usr/lib/mozilla/plugins/libnpjp2.so
  ln -s /usr/lib/jvm/java-7-oracle/jre/lib/i386/libnpjp2.so /usr/lib/libnpjp2.so
  ln -s /usr/lib/jvm/java-7-oracle/jre/lib/i386/libnpjp2.so /opt/google/chrome/libnpjp2.so
fi
curl -L https://raw.github.com/gist/3065781/99java > /etc/env.d/99java
env-update
restart ui