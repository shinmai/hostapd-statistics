#!/bin/bash
# this script checks if the syslog event is relevant for us and then does the appropriate stuff
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
	webradio="0"
	webradio_url="http://main-high.rautemusik.fm"

	SCRIPT_FILE=$( readlink -f "${BASH_SOURCE[0]}" )
	SCRIPT_DIR="${SCRIPT_FILE%/*}"
	source "/etc/hostapd-statistics/CONFIG"
}
loadcfg
#functions
disconnect() {
	mac=`echo $disconnected | cut -d" " -f8`
	sed -i -e "/$mac/d" "/dev/shm/conclients"
	echo "$mac removed from connected clients."
}
connect () {
	mac=`echo $connected | cut -d" " -f8 | tr [:lower:] [:upper:]`
	echo "Looks like somebody says hello.."
	unique
	#check if the mac is already in our list of connected clients
	alreadythere=`grep $mac "/dev/shm/conclients"`
	if [ -z "$alreadythere" ]; then
		iplookup
		hostname=`nslookup "$ip" | grep "name" | cut -d"=" -f2 | tr -d ' '` 
		time=`date +"%H:%M"`
		write="$mac;$ip;$hostname;$time"
		echo "Client $mac added."
		echo "$write" >> "/dev/shm/conclients"
	else
		echo "Wait, he is already in our Database.."
	fi

}
unique() {
	if ! grep -q "$mac" "/etc/hostapd-statistics/uniquemacs" ; then
		echo "$mac" >> "/etc/hostapd-statistics/uniquemacs"
		echo "New device connected. Mac: $mac"
	fi
}
iplookup() {
	#Find out the corresponding IP to the mac adress
	ip=`grep "$mac" /proc/net/arp | cut -d" " -f1`
	#for devices like my sgs2: find out the ip with arp-scan or nmap since it doesn't appear in the arp cache
	trys=0
	if [ -z "$ip" ]; then
		arp-scanlookup
	fi
	arp-scanfailcheck
}
nmaplookup() {
	echo "IP lookup with nmap.."
	ip=`nmap -sP "${dhcpserverip}"/24 | sed -n '/Nmap scan report for/{s/.* //;s/[)(]//g;h};/'"$mac"'/{x;p;q;}'` #thank you sluggr 	
##sed on freenode
}
arp-scanlookup() {
	echo "IP lookup with arp-scan.."
	ip=`arp-scan -l -I "$arp_scan_dev" | grep -i "$mac" | head -n1 |grep -E -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'`
}
failcheck() {
	if [ -z "$ip" ]; then
		trys=$((trys+1))
		if (( trys < 3 )); then
			echo "Whoops, nmap ip lookup failed. Try again.."
			nmaplookup
			failcheck
		else
			echo "Looks like $mac disappeared from the network."
			exit 0
		fi
	fi


}
arp-scanfailcheck() {
	if [ -z "$ip" ]; then
		trys=$((trys+1))
		if (( trys < 3 )); then
			echo "Whoops, arp-scan ip lookup failed. Try again.."
			arp-scanlookup
			arp-scanfailcheck
		else
			trys=0
		echo "Okay.. lets try nmap."
		nmaplookup
		failcheck
	fi
fi


}
isthisimportant=`tail -1 /var/log/syslog | grep "hostapd"`
if [ -n "$isthisimportant" ]; then
	connected=`echo "$isthisimportant" | grep "handshake"`
	disconnected=`echo "$isthisimportant" | grep "deauthenticated"`
	if [ -n "$connected" ]; then
		connect
	elif [ -n "$disconnected" ]; then
		disconnect
	fi

fi
