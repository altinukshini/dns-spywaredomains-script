#!/bin/bash

if [ ${#} -lt 1 ]; then
	echo "No arguments provided!"
	echo "Use: <script> [master/slave] [master IP Address](only if slave)"
	exit 1
fi

if [ "$1" != "slave" ] || [ "$1" != "master" ]; then
	echo "Wrong arguments provided! First argument must be 'master' or 'slave'"
	echo "Use: <script> [master/slave] [master IP Address](only if slave)"
	exit 1
fi

if [ "$1" == "slave" ] && [ -z "$2" ]; then
        echo "Please provide master dns ip address as second argument"
        exit 1
fi

echo "----------------------------------------------------------------------------------------"
echo "Script started: "$(date)
echo "----------------------------------------------------------------------------------------"

# Download zip
echo "Downloading spywaredomains.zones.zip..."
wget -P /tmp http://dns-bh.sagadc.org/spywaredomains.zones.zip

# Extract zip, rename file to new zones, remove zip and
cd /tmp ; unzip spywaredomains.zones.zip ; rm spywaredomains.zones.zip ; mv spywaredomains.zones new.zones ; cd /etc/named

# Backup old zones
echo "Backing up spywaredomains.zones to spywaredoains.zones.old..."
cat spywaredomains.zones > spywaredomains.zones.old

# Filter only needed lines /wo comments
zones=$(grep -v '//' /tmp/new.zones)

echo "Cleaning the original spywaredomains.zones file..."
echo "// File updated on: "$(date) > spywaredomains.zones

# Parse lines as needed by removing the /etc/namedb/
echo "Parsing new zones to to required format in spywaredomains.zones file..."
if [ "$1" == "master" ]
then

	echo "$zones" |
	while read zone
	do
	        echo $zone | awk '{gsub("/etc/namedb/", "");print}' >> spywaredomains.zones
	done

elif [ "$1" == "slave" ]
then

	echo "$zones" |
	while read zone
	do
		echo $zone | awk '{gsub("/etc/namedb/", "");print}' | awk '{gsub("master;", "slave;");print}' | awk '{gsub(";};", "; masterfile-format text; masters { '$2'; };};");print}' >> spywaredomains.zones
	done
fi
echo "Parsing finished!"

rm -r /tmp/new.zones
echo "tmp folder cleaned!"

echo "#############################################################"

# Check if there are errors in configuration and reload named
echo "Checking if configuration has errors!"

status=$(named-checkconf -t /var/named/chroot /etc/named.conf)
errlen=${#status}

if [ $errlen -gt 0 ]
then
        echo "Configuration has errors: "
	echo $status

	# Roll back file content
        echo "Rolling back zones in spywaredomains.zones file..."
	cat spywaredomains.zones.old > spywaredomains.zones

        exit 1
else
        echo "No errors found in configuration. Reloading named..."
        
	systemctl reload named-chroot
	
	echo "DONE!"
	exit 0
fi

exit 0
