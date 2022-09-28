# EMVIA Acoustic Node Service

## Normal Operating States
1. Waiting for GPS - red LED blinks 3 times quickly every 5 seconds<br>
a. GPS acquired - red LED blinks 2 times quickly<br>
b. GPS acquire failed after timeout, default time picked - red LED blinks 6 times quickly<br>
3. Waiting for microphone - red LED blinks 2 times quickly every 5 seconds<br>
4. Active, recording audio - red LED blinks every ~200ms<br>
5. Powering down (mic unplugged) - red LED solid, yellow blinking<br>
6. Ready to unplug - red LED solid, yellow unblinking<br>

## Basic Bringup
### Imaging
1. Download Raspbian Stretch Desktop to PC/Laptop from https://www.raspberrypi.org/downloads/raspbian/<br>
2. Insert MicroSD card into PC/Laptop and follow imaging instructions using Etcher from https://www.raspberrypi.org/documentation/installation/installing-images/README.md<br>
3. Move MicroSD card to Pi, connect keyboard/mouse/monitor and boot<br>
4. Follow instructions, connect wifi, and update. Use password “pi” for ease of use.<br>
5. Reboot<br>
### Software Provisioning
1. Edit /boot/config.txt and add "enable_uart=1" at the end<br>
2. Edit /boot/cmdline.txt and remove "console=serial0,115200"<br>
3. systemctl enable ssh<br>
4. sudo apt-get install gpsd libgps-dev libasound2 libasound2-dev ffmpeg libbluetooth-dev<br>
5. Edit /etc/rc.local and add “chmod a+w /sys/class/leds/led1/brightness” before the last line<br>
6. Edit /etc/default/gpsd and add "/dev/serial0" to DEVICES<br>
7. cd ~/Desktop ; git clone https://github.com/solnus/emvia.git<br>

## Building
*make* - build the acoustic service<br>
*make install* - build/install the acoustic service<br>
*make uninstall* - uninstall the acoustic service<br>
<br>
<br>
## Install location
### Executables
/opt/emvia/bin/acoustic<br>
/opt/emvia/bin/pcm2wav.sh<br>
<br>
### Startup Script
/etc/systemd/system/acoustic.service<br>
<br>
### Output Directory
/opt/emvia/out/<br>
<br>
<br>
## Starting/stopping the service
The acoustic service starts at boot and shuts down during poweroff. Additionally, unplugging the microphone while the service is running will cause a system shutdown.<br>
<br>
### Manually starting/stopping the service or getting the status:<br>
sudo systemctl status acoustic<br>
sudo systemctl start acoustic<br>
sudo systemctl stop acoustic<br>

## Troubleshooting
*Check if GPS daemon is holding the tcp port:*<br>
sudo netstat -anp|grep 2947<br>
<br>
*Start/Stop GPS daemon:*<br>
sudo systemctl stop gpsd<br>
sudo systemctl start gpsd<br>
sudo systemctl disable gpsd<br>
sudo systemctl enable gpsd<br>
<br>
*GPS not acquiring: stop/kill the GPS service and then run manually to see what's happening:*<br>
gpsd -n -N -D 2 -S 6666 /dev/serial0<br>
<br>
*List ALSA devices:*<br>
aplay -L<br>
<br>
