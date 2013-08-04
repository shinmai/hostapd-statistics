#!/bin/bash
# this script checks if the syslog event is relevant for us and then does the appropriate stuff
# TODO: Rewrite this since there could be a race condition if multiple clients connect simultaniously. (Forking?)

#functions
disconnect() {
mac=`echo $disconnected | cut -d" " -f8`
sed -i.bak -e "/$mac/d" ./conclients
echo "$mac removed from connected clients."
}
connect () {
mac=`echo $connected | cut -d" " -f8 | tr [:lower:] [:upper:]`
unique
#check if the mac is already in our list of connected clients
#TODO: This does not always work right. Sometimes for some reason it won't find the ip adress. (Delayed execution?)
alreadythere=`cat ./conclients | grep $mac`
if [ -z "$alreadythere" ]; then
	iphostlookup
	time=`date +"%H:%M"`
	write="$mac;$ip;$hostname;$time"
	echo "Client $mac added."
	echo $write >> ./conclients
fi


}
unique() {
unique=`cat ./uniquemacs | grep "$mac"`
if [ -z "$unique" ]; then
	echo $mac >> ./uniquemacs
fi
}
iphostlookup() {
#Find out the corresponding IP to the mac adress
ip=`arp -n | grep "$mac" | cut -d" " -f1`
	
#for devices like my sgs2: find out the ip with nmap since it doesn't appear in the arp cache
trys=0
if [ -z "$ip" ]; then
	nmaplookup
fi
failcheck		
hostname=`nslookup "$ip" | grep "name" | cut -d"=" -f2 | tr -d ' '` #this fails if we for some reason don't get the IP adress for the mac adress
}
nmaplookup() {
echo "IP lookup with nmap.."
ip=`nmap -sP 192.168.178.1/24 | awk -v mac="$mac" '/Nmap scan report for / { lastip=$0; sub(".* ","",lastip); gsub("[)(]","",lastip); }  { if ($0 ~ mac) { print lastip; exit } }'`
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

isthisimportant=`tail -1 /var/log/syslog | grep "hostapd"`
if [ -n "$isthisimportant" ]; then
	connected=`echo $isthisimportant | grep "handshake"`
	disconnected=`echo $isthisimportant | grep "deauthenticated"`
	if [ -n "$connected" ]; then
		connect
	elif [ -n "$disconnected" ]; then
		disconnect
	fi

fi
