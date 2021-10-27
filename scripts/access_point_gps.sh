#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Exiting..."
   exit 1
fi

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

echo "Setting up Raspberry Shake for Access Point Mode!"
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
apt-get update -y
apt-get upgrade -y
apt-get install vim -y

echo "Installing hostapd & dnsmasq"
apt-get install dnsmasq -y
apt-get install hostapd -y

echo "Enabling wifi"
sed -i "s/OFF/ON/" /opt/settings/user/enable-wifi.conf

echo "Copying over configuration files..."
cd ~
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.old
mv /etc/hostapd/hostapd.conf /etc/hostapd/hostapd.conf.old
mv /etc/systemd/system/multi-user.target.wants/hostapd.service /etc/systemd/system/multi-user.target.wants/hostapd.service.old
mv /etc/network/interfaces /etc/network/interfaces.old
mv /var/run/dnsmasq/resolv_dnsmasq.conf /var/run/dnsmasq/resolv_dnsmasq.conf.old
mv /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.old

cd "$parent_path"

cp ../config/dnsmasq.conf /etc/
cp ../config/hostapd.conf /etc/hostapd/
cp ../config/hostapd.service /etc/systemd/system/multi-user.target.wants/
cp ../config/interfaces /etc/network/
cp ../config/wpa_supplicant.conf /etc/wpa_supplicant/

echo "Making AP name change"
station_name=$(cat /opt/settings/sys/STN.txt)
echo "Station Name: " "$station_name"

sed -i "s/Raspberry Shake AP/$station_name AP/" /etc/hostapd/hostapd.conf

echo "Making final changes"
rfkill unblock wlan
iw reg set US
systemctl unmask hostapd
systemctl enable hostapd
systemctl enable dnsmasq
systemctl start dnsmasq
systemctl enable dnsmasq.service
cp ../config/resolv_dnsmasq.conf /var/run/dnsmasq/
systemctl enable hostapd.service
systemctl start hostapd
echo " echo 'nameserver 8.8.8.8' >> /etc/resolv.conf" >> ~/.bashrc
cronjob="@reboot sudo /usr/sbin/service hostapd start"
(crontab -u root -l; echo "$cronjob" ) | crontab -u root -

echo "Setting up Raspberry Pi to acquire time from GPS"

apt install gpsd -y
apt install gpsd-clients -y
mv /etc/default/gpsd /etc/default/gpsd.old
cp ../config/gpsd /etc/default/
gpsd /dev/ttyACM0

echo "Rebooting..."
reboot -f -h now