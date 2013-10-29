#!/bin/bash
sudo chmod +x ./hostapd-statistics/etc/init.d/hostapd-statistics
sudo chmod +x ./hostapd-statistics/usr/bin/hostapd-statistics
sudo chown root:root ./hostapd-statistics/
dpkg-deb --build ./hostapd-statistics
