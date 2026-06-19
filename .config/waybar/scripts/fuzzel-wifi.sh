#!/bin/bash

# 1. Сканируем доступные сети вокруг
wifi_list=$(nmcli --fields IN-USE,SSID,SECURITY device wifi list | sed 's/^IN-USE\s*//' | grep -v "SSID")

# Показываем список сетей пользователю через fuzzel
selected_node=$(echo "$wifi_list" | fuzzel --dmenu -i -p "󰖩 Сети:")

# Если ничего не выбрали — просто выходим
if [ -z "$selected_node" ]; then
    exit 0
fi

# Вытягиваем чистый SSID (первое слово/имя сети)
ssid=$(echo "$selected_node" | awk '{print $1}')

# 2. Проверяем, сохранена ли эта сеть уже в NetworkManager
# grep -w ищет точное совпадение по имени профиля
is_saved=$(nmcli connection show | grep -w "$ssid")

if [ ! -z "$is_saved" ]; then
    # Сеть уже известна системе! Подключаем без ввода пароля
    notify-send "Wi-Fi" "Подключение к сохраненной сети $ssid..."
    nmcli connection up id "$ssid"
else
    # Сеть новая. Проверяем, запаролена ли она
    if [[ "$selected_node" == *"WPA"* || "$selected_node" == *"WEP"* ]]; then
        # Запрашиваем пароль в красивом окошке fuzzel
        pass=$(fuzzel --dmenu --password -p "Пароль для $ssid:")
        if [ ! -z "$pass" ]; then
            notify-send "Wi-Fi" "Подключение к новой сети $ssid..."
            nmcli device wifi connect "$ssid" password "$pass"
        fi
    else
        # Открытая новая сеть
        notify-send "Wi-Fi" "Подключение к открытой сети $ssid..."
        nmcli device wifi connect "$ssid"
    fi
fi
