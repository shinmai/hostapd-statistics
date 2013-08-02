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
fi
done < ./conclients
sleep 5m
timeoutcheck &
}
echo "Hostapd-statistics launched"
rm ./conclients
touch ./conclients
bash ./webservice.sh &
timeoutcheck &
while :
do
	inotifywait -q -e modify /var/log/syslog && tail -1 /var/log/syslog > /dev/shm/hostapd-statistics && bash ./stuff.sh
done

