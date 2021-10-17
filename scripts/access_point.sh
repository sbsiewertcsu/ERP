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

echo "Installing hostapd & dnsmasq"
apt-get install dnsmasq -y
apt-get install hostapd -y

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
cp ../config/resolv_dnsmasq.conf /var/run/dnsmasq/
cp ../config/wpa_supplicant.conf /etc/wpa_supplicant/

echo "Making AP name change"
line=$(cat /opt/settings/config/MD-info.json | grep "stn")
IFS=':'
read -a arr <<< "$line"
station=${arr[1]}
station_name=${station:2:5}
echo "Station Name: " "$station_name"

sed -i "s/Raspberry Shake AP/$station_name AP" /etc/hostapd/hostapd.conf

echo "Making final changes"
rfkill unblock wlan
iw reg set US
systemctl unmask hostapd
systemctl enable dnsmasq.service
systemctl enable hostapd.service
echo " echo 'nameserver 8.8.8.8' >> /etc/resolv.conf" >> ~/.bashrc


echo "Rebooting..."
reboot -f -h now