#!/bin/bash
echo "<html>"
echo "<head>"
echo "<title>Hostapd-statistics</title>"
echo "</head>"
echo "<body>"
echo "<center><h1>Ugly first webinterface. :)</h1>"
echo '<table border="1">'
echo "<tr>"
echo "<th>MAC</th>"
echo "<th>IP</th>"
echo "<th>HOSTNAME</th>"
echo "</tr>"
while read line
do
echo "<tr>"
a="<td> $line"
b=`echo $a | sed "s/;/ <\/td><td> /g"`
encoded="$b </td>"
echo $encoded
echo "</tr>"
done < ./conclients
echo "</table>"

s=`vnstati -i eth0 -s -o /dev/stdout | base64`
h=`vnstati -i eth0 -h -o /dev/stdout | base64`
d=`vnstati -i eth0 -d -o /dev/stdout | base64`
t=`vnstati -i eth0 -t -o /dev/stdout | base64`
m=`vnstati -i eth0 -m -o /dev/stdout | base64`
echo "<br>"
echo "<img src='data:image/png;base64,$s'>"
echo "<br>"
echo "<img src='data:image/png;base64,$h'>"
echo "<br>"
echo "<img src='data:image/png;base64,$d'>"
echo "<br>"
echo "<img src='data:image/png;base64,$t'>"
echo "<br>"
echo "<img src='data:image/png;base64,$m'>"
echo "</body>"
echo "</html>"
