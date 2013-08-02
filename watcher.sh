#!/bin/bash
#This script simply waits for stuff from Hostapd to appear in the syslog
#Awesome. :)
touch ./conclients
while :
do
	inotifywait -e modify /var/log/syslog && bash ./stuff.sh
done

