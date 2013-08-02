#!/bin/bash
#This script simply waits for stuff from Hostapd to appear in the syslog
#Awesome. :)
echo "Hostapd-statistics launched"
touch ./conclients
while :
do
	inotifywait -q -e modify /var/log/syslog && bash ./stuff.sh
done

