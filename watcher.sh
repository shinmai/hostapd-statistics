#!/bin/bash
#This script simply waits for stuff from Hostapd to appear in the syslog
#Awesome. :)
timeoutcheck() {

while read line
do
mac=`echo $line | cut -d";" -f1`
iwcheck=`iw dev wlan0 station dump | grep -i "$mac"`
if [ -z "$iwcheck" ]; then
	sed -i.bak -e "/$mac/d" ./conclients
	echo "$mac timed out."
fi
done < ./conclients
sleep 5m
timeoutcheck &
}
echo "Hostapd-statistics launched"
rm ./conclients
touch ./conclients
socat TCP4-LISTEN:1501,fork,reuseaddr EXEC:"bash ./web.sh" &
timeoutcheck &
while :
do
	inotifywait -q -e modify /var/log/hostapd.log && bash ./stuff.sh
done

