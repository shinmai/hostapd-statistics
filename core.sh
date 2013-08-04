#!/bin/bash
# this script checks if the syslog event is relevant for us and then does the appropriate stuff
# TODO: Rewrite this since there could be a race condition if multiple clients connect simultaniously. (Forking?)
isthisimportant=`tail -1 /var/log/syslog | grep "hostapd"`
if [ -n "$isthisimportant" ]; then
	connected=`echo $isthisimportant | grep "handshake"`
	disconnected=`echo $isthisimportant | grep "deauthenticated"`
	if [ -n "$connected" ]; then
		mac=`echo $connected | cut -d" " -f8`
			#check if this mac ever connected before
			unique=`cat ./uniquemacs | grep "$mac"`
			if [ -z "$unique" ]; then
				echo $mac >> ./uniquemacs
			fi
		
		#check if the mac is already in our list of connected clients
		#TODO: This does not always work right. Sometimes for some reason it won't find the ip adress. (Delayed execution?)
		alreadythere=`cat ./conclients | grep $mac`
		if [ -z "$alreadythere" ]; then
			#Find out the corresponding IP to the mac adress
			ip=`arp -n | grep "$mac" | cut -d" " -f1`
			
				#for devices like my sgs2: find out the ip with nmap since it doesn't appear in the arp cache
				if [ -z "$ip" ]; then
					ip=`nmap -sP 192.168.178.1/24 | tr "\n" " " | sed "s/Nmap scan report for /\n/g" | grep -i "$mac" | cut -d"(" -f2 | cut -d")" -f1`
				fi
				
			hostname=`nslookup "$ip" | grep "name" | cut -d"=" -f2 | tr -d ' '` #this fails if we for some reason don't get the IP adress for the mac adress
			time=`date +"%H:%M"`
			write="$mac;$ip;$hostname;$time"
			echo "Client $mac added."
			echo $write >> ./conclients
		fi
	elif [ -n "$disconnected" ]; then #Just remove the line with $mac if it cleanly disconnects
		mac=`echo $disconnected | cut -d" " -f8`
		sed -i.bak -e "/$mac/d" ./conclients
		echo "$mac removed from connected clients."
	fi

fi
