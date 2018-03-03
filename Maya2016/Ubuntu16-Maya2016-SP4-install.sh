#!/bin/bash
# Heith Seewald 2012
# Garoe Dorta 2015
# Luca Weiss 2015
# Also based on https://gist.github.com/MichaelLawton/ee27bf4a0f591bed19ac
# Feel free to extend/modify to meet your needs.

#### Lets run a few checks to make sure things work as expected.
#Make sure we’re running with root permissions.
if [ `whoami` != root ]; then
    echo "Please run this script as root!"
    echo "Just run 'sudo !!'."
    exit
fi

#Check for 64-bit arch
if [ `uname -m` != x86_64 ]; then
    echo "Maya will only run on 64-bit Linux."
    echo "Please install a 64-bit Ubuntu and try again!"
    exit
fi

#Setup a few vars
export INSTALLFILE="Autodesk_Maya_2016_SP4_EN_Linux_64bit.tgz" #name of downloaded file
export INSTALLDIR="/usr/autodesk/maya2016" # file where most files go
export RPM_INSTALL_PREFIX=/usr # idk
export LD_LIBRARY_PATH=/opt/Autodesk/Adlm/R9/lib64/:$LD_LIBRARY_PATH # set the library path #TODO: path does not exist
export TEMPINSTALLDIR=$HOME/"mayaTempInstall" # temporary installation dir in ~
MAYAURL="http://download.autodesk.com/us/support/files/maya_2016_service_pack_4/Autodesk_Maya_2016_SP4_EN_Linux_64bit.tgz" # download url

LIBCRYPTO="/lib/x86_64-linux-gnu/libcrypto.so.1.0.0"
LIBSSL="/lib/x86_64-linux-gnu/libssl.so.1.0.0"

#Install Message
echo ""
echo "This script will download and install Autodesk Maya 2016."
read -p "Do you want to continue? [Y/n] " RESPONSE
case "$RESPONSE" in
	n*|N*)
	echo "Abort."
	exit 0;
esac

echo "We will install important packages now."
sudo apt-get install -y libjpeg62 
sudo apt-get install -y alien 
sudo apt-get install -y csh 
sudo apt-get install -y tcsh 
sudo apt-get install -y libaudiofile-dev 
sudo apt-get install -y libglw1-mesa 
sudo apt-get install -y elfutils 
sudo apt-get install -y gamin 
sudo apt-get install -y libglw1-mesa-dev 
sudo apt-get install -y mesa-utils 
sudo apt-get install -y xfstt 
sudo apt-get install -y ttf-liberation
sudo apt-get install -y xfonts-100dpi
sudo apt-get install -y xfonts-75dpi
sudo apt-get install -y ttf-mscorefonts-installer 
sudo apt-get install -y libgamin0 
# libxp6 was removed from Ubuntu 15
# sudo apt-get install -y libxp6

#Create a temp folder for the install files
if [ ! -d "$TEMPINSTALLDIR" ]; then
	mkdir $TEMPINSTALLDIR
	echo "Creating $TEMPINSTALLDIR folder."
	echo ""
fi

cd $TEMPINSTALLDIR
sudo chmod -R 777 $TEMPINSTALLDIR

#Now check to see if you already have maya downloaded and in the install folder.
if [ -f $TEMPINSTALLDIR/$INSTALLFILE ]; then
	#Make sure the install file is complete.
  echo "The Maya install file was found, verifying it now..."
	MAYA_INSTALL_HASH=$(md5sum -b $TEMPINSTALLDIR/$INSTALLFILE | awk '{print $1}')
	if [ "$MAYA_INSTALL_HASH" = "e228b13fec224d2e79879c1bc0103d5e" ]; then
		echo "The Maya install file was verified - skipping download!"
	else
		echo "The Maya install file is not complete. We'll try the download it again - resuming the download."
		#mv $INSTALLFILE $INSTALLFILE.bak
		wget --continue --referer="http://trial.autodesk.com" --content-disposition $MAYAURL
	fi
else
	echo "The Maya install file was not found. We'll download it now."
	wget --referer="http://trial.autodesk.com" --content-disposition $MAYAURL
fi

# Extract Maya Install Files
tar xvf $TEMPINSTALLDIR/$INSTALLFILE
# Convert rpms to debs
echo "Converting Red Hat .rpm files into Debian .deb. This could take a while..."
for i in $TEMPINSTALLDIR/*.rpm; do
  sudo alien -c $i
done

sleep 2s
#install the deb's
echo "Installing the converted .deb files. This also could take a while."
sudo dpkg -i $TEMPINSTALLDIR/*.deb

#Setup For Mental Ray.
sudo mkdir /usr/tmp
sudo chmod 777 /usr/tmp

#Required for license to install
sudo cp libadlmPIT.so.11 /usr/lib/libadlmPIT.so.11
sudo cp libadlmutil.so.11 /usr/lib/libadlmutil.so.11

# symbolic links:
# Its preferred to use the libssl and libcrypto that’s included with your system... so we’ll try that first.
# We’ll use the files included by autodesk as a fallback

#Libssl Link
if [ -f "$LIBSSL" ]; then
	echo "$LIBSSL found. Using it."
	sudo ln -s $LIBSSL $INSTALLDIR/lib/libssl.so.10
else
	echo "$LIBSSL not found. Using Autodesk’s libssl"
	sudo ln -s $INSTALLDIR/support/openssl/libssl.so.6 $INSTALLDIR/lib/libssl.so.10
fi

#LibCrypto Link
if [ -f "$LIBCRYPTO" ]
then
	echo "$LIBCRYPTO found. Using it."
	sudo ln -s $LIBCRYPTO $INSTALLDIR/lib/libcrypto.so.10
else
	echo "$LIBCRYPTO not found. Using Autodesk’s libssl"
	sudo ln -s $INSTALLDIR/support/openssl/libcrypto.so.6 $INSTALLDIR/lib/libcrypto.so.10
fi

# libjpeg
sudo ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so.8.0.2 /usr/lib/libjpeg.so.62
# libtiff
# May need to be adjusted to the version you have
sudo ln -s /usr/lib/x86_64-linux-gnu/libtiff.so.5.2.4 /usr/lib/libtiff.so.3

sudo ln -s /usr/lib/x86_64-linux-gnu/libgstapp-1.0.so.0 /usr/lib/libgstapp-0.10.so.0

# Ubuntu 16 LibXP6 Install
wget http://security.ubuntu.com/ubuntu/pool/main/libx/libxp/libxp6_1.0.1-2ubuntu0.12.04.2_amd64.deb
sudo dpkg -i libxp6*.deb
rm libxp6*.deb

# Fixes some startup Issue
sudo apt-get install -y libgstreamer-plugins-base0.10-0

# Bug with openGL populate, can do it here permanently, but a better alternative is explained below
# sudo mv /usr/lib/x86_64-linux-gnu/libGL.so /usr/lib/x86_64-linux-gnu/baklibGL.so
# sudo ldconfig

# Bitfrost bug
sudo mkdir $INSTALLDIR/plugin-backups
sudo mv $INSTALLDIR/plug-ins/bifrost $INSTALLDIR/plugin-backups/

sleep 2s

echo "Done with initial setup."
echo "You can now try to launch Maya by typing 'maya' into your terminal."
echo "Please look if there were any error messages!"