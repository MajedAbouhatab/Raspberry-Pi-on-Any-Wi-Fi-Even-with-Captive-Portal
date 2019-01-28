#!/bin/bash
j=1
l=$(wpa_cli -i wlan0 scan_results | grep -v '/'  | cut -f5 | grep . | sort --unique |\
while read -r line; do echo "($j)" $line  \
$(grep "$line" /etc/wpa_supplicant/wpa_supplicant.conf -q \
&& echo \(Network is in wpa_supplicant.conf\));j=$((j+1)) ; done)
read -p "$l`echo $'\n \b'`Select a network number: " n
ThatNetwork=$(echo "$l"|grep "($n)"| cut -d')' -f 2 | cut -d'(' -f 1| xargs)
ThatNetwork=${ThatNetwork:=Galaxy S5 2708}
if ! grep -q "$ThatNetwork" /etc/wpa_supplicant/wpa_supplicant.conf 
then
sudo sh -c "echo '\nnetwork={\n\tssid=\"$ThatNetwork\"\n\tkey_mgmt=NONE\n}' >>\
/etc/wpa_supplicant/wpa_supplicant.conf"
wpa_cli -i wlan0 reconfigure &>/dev/null	
fi
read -p "Time to spend there (in seconds or m or h): " Time2SpendThere
Time2SpendThere="${Time2SpendThere:=60}"
ThisNetwork=$(iwconfig wlan0 | grep ESSID | cut -d":" -f2| xargs\
| rev | cut -c1- | rev | cut -c1-)
echo Start:     $ThisNetwork \(`date "+%m/%d/%Y - %H:%M:%S"`\)
echo Visit:     $ThatNetwork \($Time2SpendThere\)
echo Return to: $ThisNetwork
read -p "Ready to continue?" temp
##############################
wpa_cli -i wlan0 select_network $(wpa_cli -i wlan0 list_networks\
|grep "$ThatNetwork"|cut -f 1) &>/dev/null
bash BrowseIt.sh &
sleep $Time2SpendThere
wpa_cli -i wlan0 select_network $(wpa_cli -i wlan0 list_networks\
|grep "$ThisNetwork"|cut -f 1) &>/dev/null
echo Came back: \(`date "+%m/%d/%Y - %H:%M:%S"`\)
read -p "Press any key to continue"
