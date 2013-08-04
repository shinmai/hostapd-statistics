#!/bin/bash
#This bash script generates the HTML page on the fly.
#Since we use socat, we don't need dependencies to real webservers like apache. Also, it is nearly impossible to exploit this. (I hope..)
str_trim() { sed -r -e 's,^\s+,,' -e 's,\s+$,,' -e 's,\s+, ,g' "$@"; } # stolen from dywi
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

SCRIPT_FILE=$( readlink -f "${BASH_SOURCE[0]}" )
SCRIPT_DIR="${SCRIPT_FILE%/*}"
source "${SCRIPT_DIR}/CONFIG"
}
loadcfg

#Headers'n'stuff
echo -e "HTTP/1.1 200 OK\n\n"
echo "<html>"
echo "<style type='text/css'>"
cat style.css
echo "</style>"
echo "<head>"
echo "<title>Hostapd-statistics</title>"
echo "</head>"
echo "<body>"
echo "<center><h1>Hostapd-statistics</h1>"
date   #Todo: beautify this.
echo "<br>"
uptime #Todo: beautify this.
echo '<table>'
echo "<tr>"
echo "<th>MAC</th>"
echo "<th>IP</th>"
echo "<th>HOSTNAME</th>"
echo "<th>Con. since</th>"
if  (( ${use_iw} == 1 )); then
	echo "<th>Inactive Time</th>"
	echo "<th>Send</th>"
	echo "<th>Recieved</th>"
	echo "<th>Signal</th>"
	echo "<th>Signal Avg.</th>"
	echo "<th>Bandwith</th>"
fi
echo "</tr>"
#Teh realz stuff
while read -r line # cycle through all lines in conclients (flatfile ftw!) and parse the values so they fit into our html page
do
	
	echo "<tr>"
	#this uses the values given in the file. (mac, ip, hostname)
	a="<td> $line"
	b=`echo "$a" | sed "s/;/ <\/td><td> /g"`
	encoded="$b </td>"
	echo "$encoded"
	if  (( ${use_iw} == 1 )); then
		#This uses current data aquired with iw.
		mac=`echo "$line" | cut -d";" -f1`
		iwstationdump=`iw dev "$wlandev" station dump | tr "\n" "%" | sed "s/Station/;/g" | tr ";" "\n" | grep -i "$mac"`
		#timeout
		echo "<td>"
		echo "$iwstationdump" | cut -d"%" -f2 | cut -d":" -f2
		echo "</td>"
		#send
		echo "<td>"
		tmp=`echo "$iwstationdump" | cut -d"%" -f3 | cut -d":" -f2`
		if [ -n "$tmp" ]; then
			echo "$(($tmp/1048576)) MB"
		fi
		echo "</td>"
		#recieved
		echo "<td>"
		tmp=`echo "$iwstationdump" | cut -d"%" -f5 | cut -d":" -f2`
		if [ -n "$tmp" ]; then
			echo "$(($tmp/1048576)) MB"
		fi
		echo "</td>"
		#signal
		echo "<td>"
		echo "$iwstationdump" | cut -d"%" -f9 | cut -d":" -f2 | tr -d " "
		echo "</td>"
		#signal avg
		echo "<td>"
		echo "$iwstationdump" | cut -d"%" -f10 | cut -d":" -f2 | tr -d " "
		echo "</td>"
		#Bandwith
		echo "<td>"
		echo "$iwstationdump" | cut -d"%" -f11 | cut -d":" -f2 | tr -d " "
		echo "</td>"
	fi
	echo "</tr>"
done < "${SCRIPT_DIR}/conclients"
echo "</table>"
echo "<br>"
if  (( ${use_sensors} == 1 )); then
	# A new table for our temperature values
	echo "<table>"
	echo "<tr>"
	echo "<th>Sensor</th>"
	echo "<th>T (°C)</th>"
	echo "</tr>"
	LANG=C LC_ALL=C sensors -A | sed -nr -e 's,^(.*+)[:]\s+[+]?([0-9.]+).C.*$,<tr><td>\1</td><td>\2</td></tr>,p' #thanks dywi
	echo "</table>"
fi
if  (( ${use_vnstat} == 1 )); then
	#generate the vnstat images with vnstati
	#This generates relatively much load on my atom n270.. (Load->Heat)
	s=`vnstati -i eth0 -s -o /dev/stdout | base64`
	h=`vnstati -i eth0 -h -o /dev/stdout | base64`
	d=`vnstati -i eth0 -d -o /dev/stdout | base64`
	t=`vnstati -i eth0 -t -o /dev/stdout | base64`
	m=`vnstati -i eth0 -m -o /dev/stdout | base64`
	echo "<br>"
	#Embed the images
	echo "<img src='data:image/png;base64,$s'>"
	echo "<img src='data:image/png;base64,$h'>"
	echo "<br>"
	echo "<img src='data:image/png;base64,$d'>"
	echo "<img src='data:image/png;base64,$m'>"
	echo "<br>"
	echo "<img src='data:image/png;base64,$t'>"
fi
echo "</center>"
#the end
echo "</body>"
echo "</html>"
