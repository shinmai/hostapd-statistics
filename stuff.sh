#!/bin/bash
# this script greps for hostapd and then does.. stuff!
isthisimportant=`cat /dev/shm/hostapd-statistics | grep "hostapd"`
if [ -n "$isthisimportant" ]; then
	connected=`echo $isthisimportant | grep "handshake"`
	disconnected=`echo $isthisimportant | grep "deauthenticated"`
	if [ -n "$connected" ]; then
		mac=`echo $connected | cut -d" " -f8`
		unique=`cat ./uniquemacs | grep "$mac"`
		if [ -z "$unique" ]; then
			echo $mac >> ./uniquemacs
		fi
		alreadythere=`cat ./conclients | grep $mac`
		if [ -z "$alreadythere" ]; then
			ip=`arp -n | grep "$mac" | cut -d" " -f1`
				if [ -z "$ip" ]; then
					ip=`nmap -sP 192.168.178.1/24 | tr "\n" " " | sed "s/Nmap scan report for /\n/g" | grep -i "$mac" | cut -d"(" -f2 | cut -d")" -f1`
				fi
			hostname=`nslookup "$ip" | grep "name" | cut -d"=" -f2 | tr -d ' '`
			write="$mac;$ip;$hostname"
			echo "Client $write added."
			echo $write >> ./conclients
		fi
	elif [ -n "$disconnected" ]; then
		mac=`echo $disconnected | cut -d" " -f8`
		sed -i.bak -e "/$mac/d" ./conclients
		echo "$mac removed from connected clients."
	fi
fi
