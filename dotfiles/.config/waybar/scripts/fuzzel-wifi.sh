#!/bin/bash

# Сканируем доступные сети
wifi_list=$(nmcli --fields IN-USE,SSID,SECURITY device wifi list | sed 's/^IN-USE\s*//' | grep -v "SSID")

# Показываем список сетей
selected_node=$(echo "$wifi_list" | fuzzel --dmenu -i -p "󰖩 Сети:")

if [ ! -z "$selected_node" ]; then
    ssid=$(echo "$selected_node" | awk '{print $1}')
    
    if [[ "$selected_node" == *"WPA"* || "$selected_node" == *"WEP"* ]]; then
        # Запрашиваем пароль в таком же красивом окошке
        pass=$(fuzzel --dmenu --password -p "Пароль для $ssid:")
        [ ! -z "$pass" ] && nmcli device wifi connect "$ssid" password "$pass"
    else
        nmcli device wifi connect "$ssid"
    fi
fi
