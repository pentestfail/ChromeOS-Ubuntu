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
cp -R chromeos-plugins/* /opt
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

##Insert update scripting here...

## Set lightdm to auto-login with "mybitch" username
sudo /usr/lib/lightdm/lightdm-set-defaults --autologin mybitch

## Cleanup & download any missing dependencies
read -p "Do you want to delete install files? If NO, then exit [Ctrl+C] and manually reboot. If YES then [press ENTER]"
## rm -rf /opt/chrome-build-temp/
apt-get -f install

## Reboot post install
## reboot