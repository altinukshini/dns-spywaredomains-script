#!/bin/sh

echo "----------------------------------------------------------------------------------------"
echo "Script started: "$(date)
echo "----------------------------------------------------------------------------------------"


echo "Downloading spywaredomains.zones.zip..."
# Download zip
wget -P /tmp http://dns-bh.sagadc.org/spywaredomains.zones.zip

# Extract zip, rename file to new zones, remove zip and
cd /tmp ; unzip spywaredomains.zones.zip ; rm spywaredomains.zones.zip ; mv spywaredomains.zones new.zones ; cd /etc/named

echo "Backing up spywaredomains.zones to spywaredoains.zones.old..."
# Backup old zones
cat spywaredomains.zones > spywaredomains.zones.old

# Filter only needed lines /wo comments
zones=$(grep -v '//' /tmp/new.zones)

echo "Cleaning the original spywaredomains.zones file..."
echo "// File updated on: "$(date) > spywaredomains.zones

echo "Parsing new zones to spywaredomains.zones file..."
# Parse lines as needed by removing the /etc/namedb/
echo "$zones" |
while read zone
do
	echo $zone | awk '{gsub("/etc/namedb/", "");print}' >> spywaredomains.zones
done
echo "Parsing finished!"

echo "tmp folder cleaned!"
rm -r /tmp/new.zones

echo "#############################################################"

# Check if there are errors in configuration
echo "Checking if configuration has errors!"

status=$(named-checkconf -t /var/named/chroot /etc/named.conf)
errlen=${#status}

if [ $errlen -gt 0 ]
then
        echo "Configuration has errors: "
	echo $status

	# Roll back file content
        cat spywaredomains.zones.old > spywaredomains.zones

        exit 1
else
        echo "No errors found in configuration. Reloading named..."
        systemctl reload named-chroot
fi


echo "DONE!"

exit 0
