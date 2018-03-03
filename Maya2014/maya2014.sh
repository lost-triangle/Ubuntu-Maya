#!/bin/bash
#Heith Seewald 2012
#Feel free to extend/modify to meet your needs.
#Maya on Ubuntu v.1
#This is the base installer... I’ll add more features in later versions.
#if you have any issues, feel free email me at heiths@gmail.com
 
#this version is updated by insomniac_lemon... issues were fixed and it has been converted to 2014, use at your own risk... 
#testing in a VM first is recommended... (at least until I test it again or someone confirms it works without tinkering)

#this version is updated by borgfriend... tested on ubuntu 13.04 (fresh install virtual box)
#changed Libcrypto libssl linking
#updated versionnumbers of libtiff, libjpeg
 
#### Lets run a few checks to make sure things work as expected.
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
 
#Setup a few vars
export MAYAINSTALL='mayaTempInstall'
export RPM_INSTALL_PREFIX=/usr
export LD_LIBRARY_PATH=/opt/Autodesk/Adlm/R5/lib64/

MAYAURL="http://trial.autodesk.com/SWDLDNET3/2014/MAYA/ESD/Autodesk_Maya_2014_English_Linux_64bit.tgz"
 
#Install Message
echo "You’re about to download and install Autodesk Maya 2014"
echo ""
echo "Do you wish to continue [Y/n]?"
read RESPONSE
case "$RESPONSE" in
	n*|N*)
	echo "Install Terminated"
	exit 0;
esac
 
#Get serial number
echo "If you have not already done so, you can get your serial number from: http://students.autodesk.com"
echo "Enter the serial number"
read SERIALNUMBER
echo ""
 
#Create a temp folder for the install files 
if [ ! -d "$HOME/mayaInstaller" ]; then
	mkdir $HOME/$MAYAINSTALL
	echo "Creating $MAYAINSTALL folder"
	echo ""
fi
export INSTALLDIR=$HOME/$MAYAINSTALL
cd $INSTALLDIR
 
#Get Maya
wget --referer="http://trial.autodesk.com" --content-disposition $MAYAURL
 
 
 
# Install Dependencies
#I changed this a bit because for some reason alien would never install for me
#also note -y was added so you can leave the script alone and not having it snag on asking for user input
#well, the MS agreement will still stop it :(
sudo apt-get install -y alien
sudo apt-get install -y csh tcsh libaudiofile-dev libglw1-mesa elfutils
sudo apt-get install -y gamin libglw1-mesa-dev mesa-utils xfs xfstt 
sudo apt-get install -y ttf-liberation xfonts-100dpi xfonts-75dpi
sudo apt-get install -y ttf-mscorefonts-installer
sleep 3s
 
#This is in case of name change (due to new service pack or something)
MAYAFILE=Autodesk*.tgz
# Extract Maya Install Files
tar xvf $INSTALLDIR/$MAYAFILE
 
 
#prevents composite from messing up your system.... (it happened to me with 2013, I had to re-install...)
rm $INSTALLDIR/Composite*
 
# Convert rpms to debs
for i in $INSTALLDIR/*.rpm; do
  sudo alien -cv $i;
done
sleep 2s
 
#again, space saving step.
sudo rm $INSTALLDIR/*.rpm
 
#install the debs
sudo dpkg -i $INSTALLDIR/*.deb
 
#Setup For Mental Ray.
sudo mkdir /usr/tmp
sudo chmod 777 /usr/tmp
 
#font issue fix
xset +fp /usr/share/fonts/X11/100dpi/
xset +fp /usr/share/fonts/X11/75dpi/
 
#fixing a few lib issues
sudo cp $INSTALLDIR/libadlmPIT* /usr/lib/libadlmPIT.so.7
sudo cp $INSTALLDIR/libadlmutil* /usr/lib/libadlmutil.so.7
 
# License Setup:
sudo echo -e 'MAYA_LICENSE=unlimited\nMAYA_LICENSE_METHOD=standalone' > /usr/autodesk/maya2014-x64/bin/License.env
#Notice the lack of sudo.
/usr/autodesk/maya2014-x64/bin/adlmreg -i S 657F1 657F1 2014.0.0.F $SERIALNUMBER /var/opt/Autodesk/Adlm/Maya2014/MayaConfig.pit
 
# libtiff
sudo ln -s /usr/lib/x86_64-linux-gnu/libtiff.so.5 /usr/lib/libtiff.so.3

sudo apt-get install libjpeg62:i386
#libjpeg
sudo ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so.8.0.2 /usr/lib/libjpeg.so.62

sudo ln -s /usr/autodesk/maya2014-x64/support/openssl/libssl.so.6 /usr/autodesk/maya2014-x64/lib/libssl.so.10
sudo ln -s /usr/autodesk/maya2014-x64/support/openssl/libcrypto.so.6 /usr/autodesk/maya2014-x64/lib/libcrypto.so.10
sleep 2s

sudo maya