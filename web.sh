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
echo "</body>"
echo "</html>"
