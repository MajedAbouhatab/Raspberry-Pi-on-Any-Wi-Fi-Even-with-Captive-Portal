#!/bin/bash
j=1
# Create a numbered list of available networks 
l=$(wpa_cli -i wlan0 scan_results | grep -v '/'  | cut -f5 | grep . | sort --unique |\
while read -r line; do echo "($j)" $line  \
$(grep "$line" /etc/wpa_supplicant/wpa_supplicant.conf -q \
&& echo \(Network is in wpa_supplicant.conf\));j=$((j+1)) ; done)
# Get user input
read -p "$l`echo $'\n \b'`Select a network number: " n
# Target network
ThatNetwork=$(echo "$l"|grep "($n)"| cut -d')' -f 2 | cut -d'(' -f 1| xargs)
# Default if no selection
ThatNetwork=${ThatNetwork:=Galaxy S5 2708}
# Check wpa_supplicant.conf  to see if network does not exist
if ! grep -q "$ThatNetwork" /etc/wpa_supplicant/wpa_supplicant.conf 
then
# Add target network to wpa_supplicant.conf 
sudo sh -c "echo '\nnetwork={\n\tssid=\"$ThatNetwork\"\n\tkey_mgmt=NONE\n}' >>\
/etc/wpa_supplicant/wpa_supplicant.conf"
# Apply the update
wpa_cli -i wlan0 reconfigure &>/dev/null	
fi
# How long to stay at the target network
read -p "Time to spend there (in seconds or m or h): " Time2SpendThere
# Default if no selection
Time2SpendThere="${Time2SpendThere:=60}"
# Network to get back to
ThisNetwork=$(iwconfig wlan0 | grep ESSID | cut -d":" -f2| xargs\
| rev | cut -c1- | rev | cut -c1-)
# Quick summary
echo Start:     $ThisNetwork \(`date "+%m/%d/%Y - %H:%M:%S"`\)
echo Visit:     $ThatNetwork \($Time2SpendThere\)
echo Return to: $ThisNetwork
# Final confirmation
read -p "Ready to continue?" temp
##############################
# Switching networks
wpa_cli -i wlan0 select_network $(wpa_cli -i wlan0 list_networks\
|grep "$ThatNetwork"|cut -f 1) &>/dev/null
# Going to Internet
bash BrowseIt.sh &
# Wait until we get what we came for
sleep $Time2SpendThere
# Switching back
wpa_cli -i wlan0 select_network $(wpa_cli -i wlan0 list_networks\
|grep "$ThisNetwork"|cut -f 1) &>/dev/null
# Notification
echo Came back: \(`date "+%m/%d/%Y - %H:%M:%S"`\)
# Hold until acknowledged
read -p "Press any key to continue"
