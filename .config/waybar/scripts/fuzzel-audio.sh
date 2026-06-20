#!/usr/bin/env bash

# Получаем список аудиовыходов
devices=$(wpctl status | awk '/Sinks:/ {flag=1; next} /Sources:/ {flag=0} flag' | grep -E '[0-9]+\.' | sed 's/^[[:space:]]*//')

if [ -z "$devices" ]; then
    notify-send "Ошибка" "Аудиоустройства не найдены"
    exit 1
fi

# Вызываем fuzzel-меню
selected=$(echo "$devices" | fuzzel --dmenu -i -p "󰓃 Аудио:")

if [ -n "$selected" ]; then
    # Вытаскиваем ID устройства
    node_id=$(echo "$selected" | awk '{print $1}' | tr -d '.')
    wpctl set-default "$node_id"
    
    # Имя для уведомления
    dev_name=$(echo "$selected" | cut -d'.' -f2- | sed 's/^[[:space:]]*//')
    notify-send "Аудио" "Выход изменен на: $dev_name"
fii
