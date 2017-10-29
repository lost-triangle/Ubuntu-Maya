#!/bin/bash
#Make sure we’re running with root permissions.
if [ `whoami` != root ]; then
    echo Please run this script using sudo
    echo Just type “sudo !!”
    exit
fi

#Check for 64-bit arch
if [uname -m != x86_64]; then
    echo Maya will only run on 64-bit linux. 
    echo Please install the 64-bit ubuntu and try again.
    exit
fi

## Create Download Directory
mkdir -p maya2017Install
cd maya2017Install

## Download Maya Install Files
wget http://edutrial.autodesk.com/NET17SWDLD/2017/MAYA/ESD/Autodesk_Maya_2017_EN_JP_ZH_Linux_64bit.tgz
tar xvf Autodesk_Maya_2017_EN_JP_ZH_Linux_64bit.tgz

## Install Dependencies
apt-get install -y libssl1.0.0
apt-get install -y gcc  
apt-get install -y libssl-dev 
apt-get install -y libjpeg62 
apt-get install -y alien 
apt-get install -y csh 
apt-get install -y tcsh 
apt-get install -y libaudiofile-dev 
apt-get install -y libglw1-mesa 
apt-get install -y elfutils 
apt-get install -y libglw1-mesa-dev 
apt-get install -y mesa-utils 
apt-get install -y xfstt 
apt-get install -y ttf-liberation 
apt-get install -y xfonts-100dpi 
apt-get install -y xfonts-75dpi 
apt-get install -y ttf-mscorefonts-installer 
apt-get install -y libfam0 
apt-get install -y libfam-dev 
apt-get install -y libgstreamer-plugins-base0.10-0
wget http://launchpadlibrarian.net/183708483/libxp6_1.0.2-2_amd64.deb

## Install Maya 
alien -cv *.rpm
dpkg -i *.deb
echo "int main (void) {return 0;}" > mayainstall.c
gcc mayainstall.c
mv /usr/bin/rpm /usr/bin/rpm_backup
cp a.out /usr/bin/rpm
chmod +x ./setup
./setup
rm /usr/bin/rpm
mv /usr/bin/rpm_backup /usr/bin/rpm

## Fix Startup Errors
ln -s /usr/lib/x86_64-linux-gnu/libtiff.so.5.2.6 /usr/lib/libtiff.so.3
ln -s /usr/lib/x86_64-linux-gnu/libssl.so /usr/autodesk/maya2017/lib/libssl.so.10
ln -s /usr/lib/x86_64-linux-gnu/libcrypto.so /usr/autodesk/maya2017/lib/libcrypto.so.10

# ln -s /usr/autodesk/maya2017/lib/libtbb_preview.so.2 /usr/lib64/libtbb_preview.so.2
# ln -s /usr/lib/nvidia-384/libGL.so /usr/autodesk/maya2017/libGL.so


mkdir -p /usr/tmp
chmod 777 /usr/tmp

mkdir -p ~/maya/2017/
chmod 777 ~/maya/2017/

## Fix Segmentation Fault Error
echo "MAYA_DISABLE_CIP=1" >> ~/maya/2017/Maya.env

## Fix Color Managment Errors
echo "LC_ALL=C" >> ~/maya/2017/Maya.env

chmod 777 ~/maya/2017/Maya.env

## Maya Camera Modifier Key
gsettings set org.gnome.desktop.wm.preferences mouse-button-modifier "<Super>"

## Ensure that Fonts are Loaded
xset +fp /usr/share/fonts/X11/100dpi/
xset +fp /usr/share/fonts/X11/75dpi/
xset fp rehash

echo Maya was installed successfully. 