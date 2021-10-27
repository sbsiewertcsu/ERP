#!/bin/bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Exiting..."
   exit 1
fi

echo "Install Obspy.."

release_codename=$(lsb_release -cs)
echo "$release_codename"

deb http://deb.obspy.org $release_codename main > /etc/apt/sources.list
wget --quiet -O - https://raw.githubusercontent.com/obspy/obspy/master/misc/debian/public.key | sudo apt-key add -

apt-get update -y

apt-get install python-obspy python3-obspy -y

echo "Done!"