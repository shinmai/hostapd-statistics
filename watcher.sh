#!/bin/bash
#This script simply waits for stuff from Hostapd to appear in the syslog


timeoutcheck() {
# This function removes devices which aren't connected anymore but also don't disconnect properly.
# It uses the iw tool to dump all connected clients.
while read line
do
	mac=`echo $line | cut -d";" -f1`
	iwcheck=`iw dev wlan0 station dump | grep -i "$mac"` #TODO: Make wlan0 configurable
	if [ -z "$iwcheck" ]; then
		sed -i.bak -e "/$mac/d" ./conclients #remove the line with $mac from conclients
		echo "$mac timed out."
	fi
done < ./conclients
sleep 5m #TODO: Make this configurable
timeoutcheck & # Goto start
}
echo "Hostapd-statistics launched"
# Remove all old entrys and create the file if it doesn't exist.
rm ./conclients
touch ./conclients
# Launch the webinterface listener. In comparison to netcat, this method runs web.sh only at access and not as soon as netcat is startet.
socat TCP4-LISTEN:1500,fork,reuseaddr EXEC:"bash ./web.sh" & #TODO: Make port configurable
# Run the infinite loop
timeoutcheck &
# The whole watch the syslog thingy
while :
do
	inotifywait -q -e modify /var/log/syslog && bash ./core.sh
done

