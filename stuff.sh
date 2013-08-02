#!/bin/bash
# this script greps for hostapd and then does.. stuff!
isthisimportant=`tail -1 /var/log/syslog | grep "hostapd"`
if [ -n "$isthisimportant" ]; then
	connected=`echo $isthisimportant | grep "handshake"`
	disconnected=`echo $isthisimportant | grep "deauthenticated"`
	if [ -n "$connected" ]; then
		mac=`echo $connected | cut -d" " -f8`
		alreadythere=`cat ./conclients | grep $mac`
		if [ -z "$alreadythere" ]; then
			echo $mac
			ip=`arp -n | grep "$mac" | cut -d" " -f1`
				if [ -z "$ip" ]; then
					ip=`nmap -sP 192.168.178.1/24 | tr "\n" " " | sed "s/Host is up./\n/g" | grep -i "$mac" | cut -d"(" -f2 | cut -d")" -f1`
				fi
			echo $ip
			hostname=`nslookup "$ip" | grep "name" | cut -d"=" -f2 | tr -d ' '`
			echo $hostname
			write="$mac;$ip;$hostname"
			echo $write >> ./conclients
		fi
	elif [ -n "$disconnected" ]; then
		mac=`echo $disconnected | cut -d" " -f8`
		sed -i.bak -e "/$mac/d" ./conclients
	fi
fi
