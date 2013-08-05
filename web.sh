#!/bin/bash
#This bash script generates the HTML page on the fly.
#Since we use socat, we don't need dependencies to real webservers like apache. Also, it is nearly impossible to exploit this. (I hope..)
# uncomment to debug
#set -x
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
webradio="0"
webradio_url="http://main-high.rautemusik.fm"

SCRIPT_FILE=$( readlink -f "${BASH_SOURCE[0]}" )
SCRIPT_DIR="${SCRIPT_FILE%/*}"
source "${SCRIPT_DIR}/CONFIG"
}
loadcfg
if  (( ${webradio} == 1 )); then
	#Images
	play="iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABHNCSVQICAgIfAhkiAAAA7tJREFUWIXtlk9oXEUcx7+/mffeJpjdTbpZs2Z3m83WHDTBQ9hirMaeAm0S4yU16aEQiiAFiwcRW6kkoodqNLkVpC32FJEcLFoQqWCKKApeWihCqMpmS5Ju9m3cNMn7tzPjYTeKEDbbmMaD+cKc5r35fd53fvOdB+xpT/+x+BbzzQAaAHjlsesAkaN9PR8ZumYuLZkWAAeA2E2AUDLZeqG9veOl5uhjrcv5P2bX19cFABuA2hWAA48nT09NfcZbWhJPLC7On4g0N2FhfnFOCCFRcuThAwwOHkNDqJ4GBgZ0w9C7pBLHAv669Pz8wgqAIgD3oQIMDQ3DdR0oJdHe0cGPHDnqX8rl+kP76p9TSsya5rKLbfZH1QCeV/pIKSU4Z+juPsxTqYOxTCYz3BxrfjS3lLtj2zbKIHJHAAKBQCgWj/4DYENSCvgDfvT19fP98fhTOTN7ItLUZOXzy3d9Ph8cx7H/NUAymQwFg/7TQ8PHURRFMCIQsb8HCFIKxKIx6n9hwABUN0G8WBcM/lpbU7ve2NgoTNOs2B9UabKnp6eNmJy9evULWLYFooqPgzOO+6urGP/gvDeXznx/31p7m0mWdl13aWZmZlNHWKUFo9FoiZIYOOfgjINzDsZKDiilIKWAV/RgOzZWVguQqojR0Xf00bGxw8G6uu8C9XWvJRKJ+MjISM0DA4TDYQCAUhKWbcF2LNi2Bcd14HkOhChCSAkoBUYEjWvw+WrAGcfC/IK0LAucWDocDmNtbW3TKNcqAcRiMdz+5RaIGDSugbGNHiAQqLSBClDlUNQ1A5nMHCYmx13HcT999tAzE37/voV8Pm9OT09vejIqAkSjURi6ASL6awsYYyDGwIiw0UKccxQKBUxOTnh35zI/JxL7z7a1PflbMBjM9vb2VkzLLR3QdR0EgBEDMQJjDKzcC5xzWOsWrl370rt+/etsuDF85tSpV38QQuS6urpWKq1dvQOGDgVAKgmSBAkJxhikkLh186a8/MlFu76+4cOzZ85N1dbW5iORiElEVQdRVQ4opSBEsfSCpiN77x4uXvrYVQqfv3zylfHOzs4sgCwRPfDlVBEAAAzDgFISmqZDCoUrVy576fTvtw+mnn5zcHDoDoAcEVVl97YAdF0H5xp++vFG8duZb8x4vOXc++cnbgAolItXbff2AAwd7743Zvsf8V944/W3LoVCoVVs0+5tAbS2to4d6nr+q1QqlQNgElFhJwpvqGK4K6UOoJSWhXLxHf0f3FJKKV0p5dvVonv63+lPeip8lRfpXtkAAAAASUVORK5CYII="
	stop="iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABHNCSVQICAgIfAhkiAAAAfJJREFUWIXtlu2K00AUhp+kSduTBLKhDbGLf70iv/DmRBQFQW/IC1hkF4Tt4gfdzHn9kbbbottGA/6xLwyZIXPmfTLnzBA46aST/ndFPeacA/kAj6/AxX0vkx4LZE+eP/6UJMnqT53bth1/eP/x0aE5RwHKshTA29fvxu6Ou/cyT9OUZy+eUpalrq+vhwNI4vLqM65+AOcPHm7jDwHExxY6OzsTQPCAy5H3bGvQTfxfA8znc4duB/5Evp6/ib9PR1Mwm80kHEnEUYzvImu/czfUtlZms9lB8qMARVHo5tsSJOI4JtL+ydXGdsemDS1aAxRFMQygrmv9uPgOwGg02qZCEiG0BHdCaGlDwENLG5wIwbwhTVPquh4GkGWZmxnu4rZtCaFFwQkKWxDobrRRPCKOO0hJmBlZlg2rgcVioasvl0RxRERXByQRsUbd9qtLgrTpd+aiA1gsFsN2oKoqmU2JIkiSMZKvvxDYmOnOdNNHYDalqqphAGVZupkREZMmKe6+Y+T7ADsNwMyYTCbDAMxMZkYUQRx3Z1ASjtNdI1q3/VRvaqCqqmE10DSNzAxJjCeTbc5/94T1sRS4HDOjaZphO5DnucymvHrz8tjUX2Q2Jc/zgwBH/wckFcC4r+lyudwbr1ar27qub/rGn3TSSf9cPwGW+Ts6YB1vBQAAAABJRU5ErkJggg=="
	louder="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"
	quieter="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"
	mute="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"
fi
#Headersnstuff
read request
request=`echo $request | cut -d" " -f2`
echo -e "HTTP/1.1 200 OK\n"
echo "<!DOCTYPE html>"
echo "<html>"
echo "<style type='text/css'>"
cat style.css
echo "</style>"
echo "<head>"
echo "<title>Hostapd-statistics</title>"
if  (( ${webradio} == 1 )); then # Ajax would be much better for this..
	if  [ "$request" == "/mplayeron" ] || \
		[ "$request" == "/mplayeroff" ] || \
		[ "$request" == "/louder" ] || \
		[ "$request" == "/quieter" ] || \
		[ "$request" == "/mute" ]; then
			if  [ "$request" == "/mplayeron" ]; then 
				if [ ! -f "/dev/shm/hostapd_statistics_webradio.pid" ]; then
					mplayer '-really-quiet' '-msglevel' 'all=-1' "$webradio_url" > /dev/null 2>&1 > /dev/null &
					echo "$!" > "/dev/shm/hostapd_statistics_webradio.pid"
				fi
			fi
			if  [ "$request" == "/mplayeroff" ]; then
				kill $(< /dev/shm/hostapd_statistics_webradio.pid)
				rm "/dev/shm/hostapd_statistics_webradio.pid" > /dev/null 2>&1 > /dev/null
			fi
			if  [ "$request" == "/louder" ]; then
				amixer 'sset' 'Master,0' '5%+' > /dev/null 2>&1 > /dev/null
			fi
			if  [ "$request" == "/quieter" ]; then
				amixer 'sset' 'Master,0' '5%-' > /dev/null 2>&1 > /dev/null
			fi
			if  [ "$request" == "/mute" ]; then
				amixer 'sset' 'Master,0' 'toggle' > /dev/null 2>&1 > /dev/null
			fi
			echo "<meta http-equiv='refresh' content='0; URL=./'>"
			echo "</head>"
			echo "<body>"
			echo "</body>"
			echo "</html>"
	fi
fi
echo "</head>"
if  (( ${webradio} == 1 )); then
	if  [ "$request" == "/webradio" ] || [ "$request" == "/webradio/mplayeron" ] || [ "$request" == "/webradio/mplayeroff" ] || [ "$request" == "/webradio/louder" ] || [ "$request" == "/webradio/quieter" ] || [ "$request" == "/webradio/mute" ]; then 
		echo "<body>"
		echo "<center>"
		echo "<a href='/webradio/mplayeron'><img width='256' height='256' src='data:image/png;base64,$play'></a>"
		echo "<br>"
		echo "<br>"
		echo "<a href='/webradio/mplayeroff'><img width='256' height='256' src='data:image/png;base64,$stop'></a>"
		echo "<br>"
		echo "<br>"
		echo "<a href='/webradio/louder'><img width='256' height='256' src='data:image/png;base64,$louder'></a>"
		echo "<br>"
		echo "<br>"
		echo "<a href='/webradio/quieter'><img width='256' height='256' src='data:image/png;base64,$quieter'></a>"
		echo "<br>"
		echo "<br>"
		echo "<a href='/webradio/mute'><img width='256' height='256' src='data:image/png;base64,$mute'></a>"
		echo "</center>"
		echo "</body>"
		echo "</html>"
		if  [ "$request" == "/webradio/mplayeron" ]; then 
			if [ ! -f "/dev/shm/hostapd_statistics_webradio.pid" ]; then
				mplayer '-really-quiet' '-msglevel' 'all=-1' "$webradio_url" > /dev/null 2>&1 > /dev/null &
				echo "$!" > "/dev/shm/hostapd_statistics_webradio.pid"
			fi
			fi
			if  [ "$request" == "/webradio/mplayeroff" ]; then
				kill $(< /dev/shm/hostapd_statistics_webradio.pid)
				rm "/dev/shm/hostapd_statistics_webradio.pid" > /dev/null 2>&1 > /dev/null			
			fi
			if  [ "$request" == "/webradio/louder" ]; then
				amixer 'sset' 'Master,0' '5%+' > /dev/null 2>&1 > /dev/null
			fi
			if  [ "$request" == "/webradio/quieter" ]; then
				amixer 'sset' 'Master,0' '5%-' > /dev/null 2>&1 > /dev/null
			fi
			if  [ "$request" == "/webradio/mute" ]; then
				amixer 'sset' 'Master,0' 'toggle' > /dev/null 2>&1 > /dev/null
			fi
		exit 0
	fi
fi
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
	echo "<th>T (&deg;C)</th>"
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
echo "<br>"
if  (( ${webradio} == 1 )); then
	#mplayer stuff
	echo "<div class='mplayermenu'>"
	echo "<center>"
	echo "<a href='/mplayeron'><img src='data:image/png;base64,$play'></a>"
	echo "<a href='/mplayeroff'><img src='data:image/png;base64,$stop'></a>"
	echo "<a href='/louder'><img src='data:image/png;base64,$louder'></a>"
	echo "<a href='/quieter'><img src='data:image/png;base64,$quieter'></a>"
	echo "<a href='/mute'><img src='data:image/png;base64,$mute'></a>"
	echo "</center>"
	echo "</div>"
fi
echo "</center>"
#the end
echo "</body>"
echo "</html>"
