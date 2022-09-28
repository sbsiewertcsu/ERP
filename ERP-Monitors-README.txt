Building and installing ERP Sensor Fusion Apps on a Linux system

ERP software general use
1. git clone https://github.com/sbsiewertcsu/ERP.git
2. Enable USB devices (camera, GPS, and microphone) with Config +USB and add

Motion detect
3. sudo apt-get install libqgpsmm-dev
4. sudo apt install libopencv-dev
5. sudo apt-get install gpsd
6. cmake motion-detect/
7. make in motion

Audio
1. sudo apt-get install alsa-tools
2. sudo apt-get install alsa-source
3. sudo apt-get install libsound2-dev
4. make in emvia-master
