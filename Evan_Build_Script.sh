## This script intended for Ubuntu Server 12.04 installed on a virtual platform (Parallels Tools install in script)
## Script pulls from dz0ny's original build and is fork of .DEB install from Github
## by @pentestfail
## version 0.1
## 31 AUG, 2013

set +e

#Install Parallels or VMWare Tools
## read -p "Attach ISO to install virtualization tools from [press ENTER]"
mount /dev/cdrom /media/cdrom
echo "Installing Parallels Tools.  Please wait for task to complete."
/media/cdrom/install --install-unattended-with-deps

## Update Ubuntu and install dependencies & random tools (Add any tools you want now! you won't be able to later!)
echo "Updating Ubuntu and installing dependencies"
apt-get install -y python-software-properties
add-apt-repository ppa:webupd8team/java
apt-get update
## read -p "Did the update complete successfully? [press ENTER]"
## Accept Java license agreement automatically
echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
## Download dependencies
apt-get install -y unzip nano xorg matchbox-window-manager lightdm alsa icedtea-7-plugin oracle-java7-installer oracle-java7-set-default python3 python3-dbus

#Turn up volume and test audio
echo "Initializing sound devices"
alsactl init
echo "Testing sound output"
amixer set Master 100 umute
amixer set AUX 100 unmute
speaker-test -c 2 -l 1
read -p "Did you hear sound? If not, then exit [Ctrl+C]. If good then [press ENTER]"

## Create install directory & cd
## mkdir /opt/chrome-build-temp/
## cd /opt/chrome-build-temp/

## Download & extract install files
## Need to create download .ZIP with files
## wget http://{link to download}
## unzip {zip from download}

## Dz0ny's install .DEB decompiled as shells script (added copy of directories)
set -e
echo "Installing ChromeOS"
LKGR=$(curl http://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_ChromiumOS/LAST_CHANGE)
URL="http://commondatastorage.googleapis.com/chromium-browser-snapshots/Linux_ChromiumOS/${LKGR}/chrome-linux.zip"
ZIPFILE=$(tempfile)
echo "Downloading Google Chrome-Linux from latest build snapshot"
curl -z "${ZIPFILE}.zip" -o "${ZIPFILE}.zip" -L "$URL"
unzip "${ZIPFILE}.zip" -d "/opt/"
echo "Extracted Google Chrome-Linux to /opt/"
rm -rf /opt/chromeos
echo "Setting up directories and permissions"
mv /opt/chrome-linux /opt/chromeos
cp -R usr/* /usr
cp -R etc/* /etc
cp -R chromeos-plugins/* /opt/chromeos-plugins
chmod 775 /opt/chromeos -R
chmod 755 /etc/grub.d/11_chromeos
chown root:root /usr/sbin/chromeos
chown root:root /usr/sbin/chromeos-dm
chown root:root /usr/sbin/chromeos-plain
chown root:root /usr/share/xsessions/chromeos.desktop
## echo "Removing temporary files and directories"
## rm -rf $ZIPFILE
update-grub2

set +e

## Setup JAVA environment, etc.
echo "Configuring JAVA environment"
mkdir -p /usr/lib/mozilla/plugins/
ln -s /usr/lib/jvm/java-7-oracle/jre/lib/amd64/libnpjp2.so /usr/lib64/cromo/libnpjp2.so
ln -s /usr/lib/jvm/java-7-oracle/jre/lib/amd64/libnpjp2.so /usr/lib64/mozilla/plugins/libnpjp2.so
ln -s /usr/lib/jvm/java-7-oracle/jre/lib/amd64/libnpjp2.so /usr/lib64/libnpjp2.so
ln -s /usr/lib/jvm/java-7-oracle/jre/lib/amd64/libnpjp2.so /opt/google/chrome/libnpjp2.so
PATH="/usr/lib/jvm/java-7-oracle/jre/bin/"
JAVA_HOME="/usr/lib/jvm/java-7-oracle/"
env-update

## Download the updated goodies
echo "Downloading Chrome Browser updates and Google Talk plugin"
wget https://dl.google.com/linux/direct/google-talkplugin_current_amd64.deb
mkdir chrome-browser
cd chrome-browser
ar vxg google-chrome-stable_current_amd64.deb
tar -xvf /opt/chrome.tar.lzma -C chrome-browser
cd ..
mkdir chrome-talk
cd chrome-talk
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
ar vx google-talkplugin_current_amd64.deb
tar -xvf /opt/chrome.tar.lzma -C chrome-talk
cd ..

## Install MP3 & MP4 libraries
cp /opt/chrome-browser/opt/google/chrome/libffmpegsumo.so /usr/lib/cromo/ -f
cp /opt/chrome-browser/opt/google/chrome/libffmpegsumo.so /opt/google/chrome/ -f
cp /opt/chrome-browser/opt/google/chrome/libffmpegsumo.so /usr/lib/mozilla/plugins/ -f

## Install Chrome PDF to proper directories
cp /opt/chrome-browser/opt/google/chrome/libpdf.so /opt/google/chrome/ -f

## Install flash to proper directories
cp /opt/chrome-build-temp/chrome-browser/opt/google/chrome/PepperFlash/libpepflashplayer.so /opt/google/chrome/pepper/ -f
cp /opt/chrome-build-temp/chrome-browser/opt/google/chrome/PepperFlash/manifest.json /opt/google/chrome/pepper/ -f
curl -L https://raw.github.com/gist/3065781/pepper-flash.info > /opt/google/chrome/pepper/pepper-flash.info

## Install Google Talk to proper directories
ln -s /opt/google/talkplugin/libnpgoogletalk.so /opt/google/chrome/pepper/libnpgoogletalk.so
ln -s /opt/google/talkplugin/libnpgtpo3dautoplugin.so /opt/google/chrome/pepper/libnpgtpo3dautoplugin.so

## Disable sandbox in chrome launch configuration
## nano /usr/sbin/chromeos
## --disable-setuid-sandbox


## Set lightdm to auto-login with "mybitch" username
sudo /usr/lib/lightdm/lightdm-set-defaults --autologin mybitch

## Cleanup & download any missing dependencies
read -p "Do you want to delete install files? If NO, then exit [Ctrl+C] and manually reboot. If YES then [press ENTER]"
## rm -rf /opt/chrome-build-temp/
apt-get -f install

## Reboot post install
## reboot