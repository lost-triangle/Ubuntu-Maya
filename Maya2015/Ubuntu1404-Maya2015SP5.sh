#References:

#http://forums.autodesk.com/t5/installation-licensing/installing-maya-on-ubuntu/td-p/4905036
#http://askubuntu.com/questions/392806/installing-maya-on-ubuntu-linux
#https://gist.github.com/insomniacUNDERSCORElemon/5555214
#http://nealbuerger.com/2013/05/ubuntu-13-04-maya-2014-install-script/
#http://www.nkoubi.com/blog/tutorial/how-to-install-autodesk-maya-2011-on-debian-ubuntu/
#http://help.autodesk.com/view/MAYAUL/2015/ENU/?guid=GUID-E7E054E1-0E32-4B3C-88F9-BF820EB45BE5
#http://www.andrewhazelden.com/blog/2014/10/autodesk-nlm-licensing-issues-with-maya-2015-and-max-2015/

#Download Maya from here: http://knowledge.autodesk.com/support/maya/downloads/caas/downloads/content/autodesk-maya-2015-service-pack-5.html

#cd to download directory

mkdir maya2015_setup
mv Autodesk_Maya_2015_SP5_English_Linux.tgz maya2015_setup/
cd maya2015_setup
tar xvf Autodesk_Maya_2015_SP5_English_Linux.tgz

export RPM_INSTALL_PREFIX=/usr
export LD_LIBRARY_PATH=/opt/Autodesk/Adlm/R5/lib64/

LIBCRYPTO="/usr/lib/x86_64-linux-gnu/libcrypto.so.0.9.8"
LIBSSL="/usr/lib/x86_64-linux-gnu/libssl.so.0.9.8"

sudo ln -s /usr/lib/x86_64-linux-gnu/libssl.so.0.9.8 /usr/lib/x86_64-linux-gnu/libssl.so.10
sudo ln -s /usr/lib/x86_64-linux-gnu/libcrypto.so.0.9.8 /usr/lib/x86_64-linux-gnu/libcrypto.so.10

sudo apt-get install -y  alien csh tcsh libaudiofile-dev libglw1-mesa elfutils gamin libglw1-mesa-dev mesa-utils xfs xfstt ttf-liberation xfonts-100dpi xfonts-75dpi ttf-mscorefonts-installer libfam0 libfam0-dev

sudo apt-get install -y alien
sudo apt-get install -y csh tcsh libaudiofile-dev libglw1-mesa elfutils

sudo apt-get install -y gamin xfstt

#Didn’t work but doesn't seem to be a problem
sudo apt-get install -y libglw1-mesa-dev mesa-utils xfs

sudo apt-get install -y ttf-liberation xfonts-100dpi xfonts-75dpi
sudo apt-get install -y ttf-mscorefonts-installer

#Can take a long time - 15 to 30min
for i in *.rpm; do
  sudo alien -cv $i;
done

sudo dpkg -i *.deb

sudo mkdir /usr/tmp
 sudo chmod 777 /usr/tmp
 
xset +fp /usr/share/fonts/X11/100dpi/
xset +fp /usr/share/fonts/X11/75dpi/

sudo cp lib* /usr/lib/

sudo echo -e 'MAYA_LICENSE=unlimited\nMAYA_LICENSE_METHOD=standalone' > /usr/autodesk/maya2015-x64/bin/License.env

#Error 32 but didn’t matter
#Replace the asterisks with your serial number e.g. 123-12345678
#657G1 is the product code for Autodesk Maya 2015
/usr/autodesk/maya2015-x64/bin/adlmreg -i S 657G1 657G1 2015.0.0.F ***-******** /var/opt/Autodesk/Adlm/Maya2015/MayaConfig.pit

sudo ln -s /usr/lib/x86_64-linux-gnu/libcrypto.so.0.9.8 /usr/autodesk/maya2015-x64/lib/libcrypto.so.10
sudo ln -s /usr/lib/x86_64-linux-gnu/libcrypto.so.0.9.8 /usr/autodesk/maya2015-x64/lib/libcrypto.so.0.9.8

#Will install without these but will crash when selecting jpeg or tiff images
sudo ln -s /usr/lib/x86_64-linux-gnu/libtiff.so.5.2.0 /usr/lib/libtiff.so.3
sudo ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so.62 /usr/lib/libjpeg.so.62
 
sudo rm /usr/lib/libfam.so.0
 
sudo ln -s /usr/lib/libfam.so.0.0.0 /usr/lib/libfam.so.0

sudo sh -c "echo 'setenv LC_ALL en_US.UTF-8' >> /usr/autodesk/maya2015-x64/bin/maya2015"
 
/usr/autodesk/maya2015-x64/bin/licensechooser /usr/autodesk/maya2015-x64/ standalone 657G1 maya

sudo -i
export MAYA_LOCATION=/usr/autodesk/maya2015-x64/
export LD_LIBRARY_PATH=/opt/Autodesk/Adlm/R9/lib64/

nano mayainstall.c
 
#add the following in nano, save and close
 
int main (void) {return 0;}

gcc mayainstall.c

sudo mv /usr/bin/rpm /usr/bin/rpm_backup
 
sudo cp a.out /usr/bin/rpm

chmod +x ./setup

sudo ./setup

#Then, follow the GUI, Accept, put your Serial Number and the 657G1 thing

sudo rm /usr/bin/rpm

sudo mv /usr/bin/rpm_backup /usr/bin/rpm

#To prevent crashes when loading jpegs
sudo nano /usr/autodesk/maya2015-x64/bin/maya

#Search for
setenv LIBQUICKTIME_PLUGIN_DIR "$MAYA_LOCATION/lib"
#After that line add the following:
setenv LD_PRELOAD /usr/lib/x86_64-linux-gnu/libjpeg.so.62

#ctrl-x to exit

#use super (windows key) for dragging windows instead of alt which is needed for maya
gsettings set org.gnome.desktop.wm.preferences mouse-button-modifier "<Super>"

#and for the only first time, to activate and stuff

sudo maya 

#didn’t activate so go to https://registeronce.autodesk.com and when it asks you for request file, get from /tmp/MAYA2015en_USLongCode.xml while maya activation screen is open. You will get a file named Long_Response_Code.xml which will allow you to activate.
 
#close maya, and add the following to a launcher

maya
#or
maya -style gtk