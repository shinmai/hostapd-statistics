#!/bin/bash
#This bash script generates the HTML page on the fly.
#Since we use socat, we don't need dependencies to real webservers like apache. Also, it is nearly impossible to exploit this. (I hope..)


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
echo "<th>Inactive Time</th>"
echo "<th>Send</th>"
echo "<th>Recieved</th>"
echo "<th>Signal</th>"
echo "<th>Signal Avg.</th>"
echo "<th>Bandwith</th>"
echo "</tr>"
#Teh realz stuff
while read line # cycle through all lines in conclients (flatfile ftw!) and parse the values so they fit into our html page
do
	
	echo "<tr>"
	#this uses the values given in the file. (mac, ip, hostname)
	a="<td> $line"
	b=`echo $a | sed "s/;/ <\/td><td> /g"`
	encoded="$b </td>"
	echo $encoded
	
	#This uses current data aquired with iw.
	mac=`echo $line | cut -d";" -f1`
	iwstationdump=`iw dev wlan0 station dump | tr "\n" "%" | sed "s/Station/;/g" | tr ";" "\n" | grep -i "$mac"` #TODO: make wlan0 configurable
	#timeout
	echo "<td>"
	echo $iwstationdump | cut -d"%" -f2 | cut -d":" -f2
	echo "</td>"
	#send
	echo "<td>"
	tmp=`echo $iwstationdump | cut -d"%" -f3 | cut -d":" -f2`
	if [ -n "$tmp" ]; then
		echo "$(($tmp/1048576)) MB"
	fi
	echo "</td>"
	#recieved
	echo "<td>"
	tmp=`echo $iwstationdump | cut -d"%" -f5 | cut -d":" -f2`
	if [ -n "$tmp" ]; then
		echo "$(($tmp/1048576)) MB"
	fi
	echo "</td>"
	#signal
	echo "<td>"
	echo $iwstationdump | cut -d"%" -f9 | cut -d":" -f2 | tr -d " "
	echo "</td>"
	#signal avg
	echo "<td>"
	echo $iwstationdump | cut -d"%" -f10 | cut -d":" -f2 | tr -d " "
	echo "</td>"
	#Bandwith
	echo "<td>"
	echo $iwstationdump | cut -d"%" -f11 | cut -d":" -f2 | tr -d " "
	echo "</td>"
	echo "</tr>"
done < ./conclients
echo "</table>"
echo "<br>"

# A new table for our temperature values
echo "<table>"
echo "<tr>"
echo "<th>Sensor</th>"
echo "<th>Temp</th>"
echo "</tr>"
echo "<tr>"
echo "<td>"
sensors -A | grep "°" | cut -d"(" -f1 | grep "^" | head -c-1 - | tr "\n" ";" | sed 's/;/<\/td><\/tr><tr><td>/g' | sed 's/     /<\/td><td>/g' | sed 's/°/\&deg;/g' #Does this work on other hardware? There must be a better regex way.
echo "</td>"
echo "</tr>"
echo "</table>"

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
echo "</center>"
#the end
echo "</body>"
echo "</html>"
