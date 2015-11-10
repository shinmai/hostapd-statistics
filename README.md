This is a custom fork of hostapd-statistics in use on a Raspberrypi access point.

#hostapd-statistics

![screenshot of hostap-statistic generated webpage](hostapd-statistics-demo.png?raw=true)

Webinterface with statistics for Hostapd

```
git clone https://github.com/shinmai/hostapd-statistics.git
cd hostapd-statistics
./build_deb.sh
sudo dpkg -i hostapd-statistics.deb
service hostapd-statistics start
```
________________________________
Requires: socat, nmap, inotifywait, arp-scan, iw
Optionally: vnstati, sensors, mplayer