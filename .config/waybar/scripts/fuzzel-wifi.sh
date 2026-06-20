#!/usr/bin/env bash

# Активная сеть
active_ssid=$(nmcli --terse --fields IN-USE,SSID device wifi list | grep "^*:" | cut -d':' -f2)

# Список остальных сетей
raw_list=$(nmcli --terse --fields SSID,SECURITY device wifi list | grep -v "^BSSID")

formatted_list=""
if [ -n "$active_ssid" ]; then
    formatted_list="󰖩  $active_ssid   [CONNECTED]\n"
fi

other_networks=$(echo "$raw_list" | grep -v "^:" | grep -w -v "$active_ssid" | sed 's/:/  │  /g' | sort -u)
formatted_list="${formatted_list}${other_networks}"

selected_node=$(echo -e "$formatted_list" | fuzzel --dmenu -i -p "󰖩 Сети:")

if [ -z "$selected_node" ]; then
    exit 0
fi

if [[ "$selected_node" == *"[CONNECTED]"* ]]; then
    notify-send "Wi-Fi" "Вы уже подключены к этой сети"
    exit 0
fi

ssid=$(echo "$selected_node" | awk -F '  │  ' '{print $1}' | sed 's/[[:space:]]*$//')
is_saved=$(nmcli connection show | grep -w "$ssid")

if [ -n "$is_saved" ]; then
    notify-send "Wi-Fi" "Подключение к $ssid..."
    nmcli connection up id "$ssid"
else
    if [[ "$selected_node" == *"WPA"* || "$selected_node" == *"WEP"* ]]; then
        pass=$(fuzzel --dmenu --password -p "Пароль для $ssid:")
        if [ -n "$pass" ]; then
            notify-send "Wi-Fi" "Подключение к новой сети $ssid..."
            nmcli device wifi connect "$ssid" password "$pass"
        fi
    else
        nmcli device wifi connect "$ssid"
    fi
fi
