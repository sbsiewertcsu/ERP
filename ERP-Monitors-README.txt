Building and installing ERP Sensor Fusion Apps on a Linux system

ERP software general use
------------------------------
1. git clone https://github.com/sbsiewertcsu/ERP.git
2. sudo apt-get install cmake
3. Plug in USB and CSI/MIPI devices - verify with "lsusb" and "ls /dev/video*"


R-Pi 3b+ Audio and Image Capture Node
------------------------------
myaudio@raspberrypi:~/ERP/audio/emvia-master $ lsb_release -a
No LSB modules are available.
Distributor ID:	Debian
Description:	Debian GNU/Linux 11 (bullseye)
Release:	11
Codename:	bullseye

GPS:
1. sudo apt-get install libgps-dev
2. sudo apt-get install gpsd
3. use "cgps" to test GPS (make sure receiver near a window or outdoors)

Audio:
1. sudo apt update
2. sudo apt-get install alsa-tools
3. sudo apt-get install libasound2-dev
4. make in "emvia-master"
5. make sure USB mic and USB gps are plugged in

Motion detect:
1. sudo apt-get install libopencv-dev
2. cmake motion-detect
3. make


Ubuntu 20.04 LTS PROCEDURE
------------------------------
1. Enable USB devices (camera, GPS, and microphone) with Config +USB and add for VB-Linux

Motion detect:
1. sudo apt install libopencv-dev
2. cmake motion-detect/
3. make in "motion"

Audio
1. sudo apt-get install alsa-tools
2. sudo apt-get install alsa-source
3. sudo apt-get install libsound2-dev
4. make in "emvia-master"
