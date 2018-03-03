#!/bin/bash
#### Lets run a few checks to make sure things work as expected.
#Make sure we’re running with root permissions.
if [ `whoami` != root ]; then
    echo "Please run this script as root!"
    echo "Just run 'sudo !!'."
    exit
fi

#Install Message
echo "Licence for Maya 2016"
echo "This will start the Maya2016 Setup, Enter your Licence Information."
echo "Ignore the 'failed installation' Message at the end of the process."
echo ""
echo "Is Maya already installed?"
echo ""
read -p "Do you want to continue? [Y/n] " RESPONSE
case "$RESPONSE" in
	n*|N*)
	echo "Abort."
	exit 0;
esac

export TEMPINSTALLDIR=$HOME/"mayaTempInstall" 

gcc mayainstall.c

sudo mv /usr/bin/rpm /usr/bin/rpm_backup

sudo cp a.out /usr/bin/rpm

cd $TEMPINSTALLDIR

chmod +x ./setup

sudo ./setup

#Then, follow the GUI, Accept, put your Serial Number and the 657G1 thing

sudo rm /usr/bin/rpm
sudo mv /usr/bin/rpm_backup /usr/bin/rpm

# Run Maya as root to activate licence
sudo maya

## Since Maya was ran once with sudo, reset the owner of the maya folder to user
sudo chown -R "$USER":"$USER" ~/maya