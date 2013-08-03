#!/bin/bash
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
date
echo "<br>"
uptime
echo '<table>'
echo "<tr>"
echo "<th>MAC</th>"
echo "<th>IP</th>"
echo "<th>HOSTNAME</th>"
echo "<th>Inactive Time</th>"
echo "<th>Send</th>"
echo "<th>Recieved</th>"
echo "<th>Signal</th>"
echo "<th>Signal Avg.</th>"
echo "<th>Bandwith</th>"
echo "</tr>"
while read line
do
echo "<tr>"
a="<td> $line"
b=`echo $a | sed "s/;/ <\/td><td> /g"`
encoded="$b </td>"
mac=`echo $line | cut -d";" -f1`
iwstationdump=`iw dev wlan0 station dump | tr "\n" "%" | sed "s/Station/;/g" | tr ";" "\n" | grep -i "$mac"`
echo $encoded
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
echo "<table>"
echo "<tr>"
echo "<th>Sensor</th>"
echo "<th>Temp</th>"
echo "</tr>"
echo "<tr>"
echo "<td>"
sensors -A | grep "°" | cut -d"(" -f1 | grep "^" | head -c-1 - | tr "\n" ";" | sed 's/;/<\/td><\/tr><tr><td>/g' | sed 's/     /<\/td><td>/g' | sed 's/°/\&deg;/g'
echo "</td>"
echo "</tr>"
echo "</table>"
s=`vnstati -i eth0 -s -o /dev/stdout | base64`
h=`vnstati -i eth0 -h -o /dev/stdout | base64`
d=`vnstati -i eth0 -d -o /dev/stdout | base64`
t=`vnstati -i eth0 -t -o /dev/stdout | base64`
m=`vnstati -i eth0 -m -o /dev/stdout | base64`
echo "<br>"
echo "<img src='data:image/png;base64,$s'>"
#echo "<br>"
echo "<img src='data:image/png;base64,$h'>"
echo "<br>"
echo "<img src='data:image/png;base64,$d'>"
#echo "<br>"
echo "<img src='data:image/png;base64,$m'>"
echo "<br>"
echo "<img src='data:image/png;base64,$t'>"
echo "</center>"
echo "</body>"
echo "</html>"
