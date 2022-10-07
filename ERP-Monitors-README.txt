Building and installing ERP Sensor Fusion Apps on a Linux system

ERP software general use
1. git clone https://github.com/sbsiewertcsu/ERP.git
2. Enable USB devices (camera, GPS, and microphone) with Config +USB and add for VB-Linux - verify with "lsusb" and "ls /dev/video*"

R-Pi 3b+ Audio Capture Node
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

Audio:
1. sudo apt update
2. sudo apt-get install alsa-tools
3. sudo apt-get install libasound2-dev
4. make in "emvia-master"
5. make sure USB mic and USB gps are plugged in



Ubuntu 20.04 LTS PROCEDURE
------------------------------
Motion detect:
3. sudo apt-get install libgps-dev (sudo apt-get install libqgpsmm-dev)
4. sudo apt install libopencv-dev
5. sudo apt-get install gpsd
6. cmake motion-detect/
7. make in "motion"

Audio
1. sudo apt-get install alsa-tools
2. sudo apt-get install alsa-source
3. sudo apt-get install libsound2-dev
4. make in "emvia-master"
