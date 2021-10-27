#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Exiting..."
   exit 1
fi

echo "Install Obspy.."

release_codename=$(lsb_release -cs)

mv /etc/apt/sources.list /etc/apt/sources.list.old
echo "deb http://archive.raspbian.org/raspbian $release_codename main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://archive.raspbian.org/raspbian $release_codename main contrib non-free" >> /etc/apt/sources.list

apt-get update -y
apt-get install python3-pip -y

pip3 install obspy

apt-get install libatlas-base-dev -y
apt-get install libxslt-dev -y
apt-get install libopenjp2-7 -y

echo "Done!"