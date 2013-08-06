#!/bin/bash
#This script simply waits for stuff from Hostapd to appear in the syslog
# uncomment to debug
#set -x
loadcfg() {
#if we got no conf file define everything here.
wlandev="wlan0"
sleeptime="5m"
webinterfaceport="1500"
dhcpserverip="192.168.178.1"
arp_scan_dev="br0"
use_sensors="0"
use_vnstat="0"
use_iw="0"
webradio="0"
webradio_url="http://main-high.rautemusik.fm"

SCRIPT_FILE=$( readlink -f "${BASH_SOURCE[0]}" )
SCRIPT_DIR="${SCRIPT_FILE%/*}"
source "${SCRIPT_DIR}/CONFIG"
}
loadcfg
timeoutcheck() {
# This function removes devices which aren't connected anymore but also don't disconnect properly.
# It uses the iw tool to dump all connected clients.
while read -r line
do
	mac=`echo "$line" | cut -d";" -f1`
	iwcheck=`iw dev "$wlandev" station dump | grep -i "$mac"` 
	if [ -z "$iwcheck" ]; then
		sed -i -e "/$mac/d" "${SCRIPT_DIR}/conclients" #remove the line with $mac from conclients
		echo "$mac timed out."
	fi
done < "${SCRIPT_DIR}/conclients"
}
timeoutcheck_loop() { timeoutcheck; while sleep "$sleeptime"; do timeoutcheck; done; }
echo "Hostapd-statistics launched"
# Remove all old entrys and create the file if it doesn't exist.
> "${SCRIPT_DIR}/conclients"
# Launch the webinterface listener. In comparison to netcat, this method runs web.sh only at access and not as soon as netcat is startet.
socat TCP4-LISTEN:"$webinterfaceport",fork,reuseaddr EXEC:"bash ${SCRIPT_DIR}/web.sh" & 
# Run the infinite loop
timeoutcheck_loop &
readonly TIMEOUTCHECK_PID=$!
trap "kill ${TIMEOUTCHECK_PID}; rm '/dev/shm/hostapd_statistics_webradio.pid' > /dev/null 2>&1 > /dev/null" TERM EXIT
# The whole watch the syslog thingy
while :
do
	inotifywait -q -q -e modify /var/log/syslog && bash "${SCRIPT_DIR}/core.sh"
done

