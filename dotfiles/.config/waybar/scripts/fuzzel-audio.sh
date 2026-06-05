#!/bin/bash

# Читаем статус wireplumber и вытаскиваем только аудиовыходы (Sinks)
devices=$(wpctl status | awk '/Sinks:/ {flag=1; next} /Sources:/ {flag=0} flag' | grep -E '[0-9]+\.' | sed 's/^[[:space:]]*//')

if [ -z "$devices" ]; then
    notify-send "Ошибка" "Аудиоустройства не найдены"
    exit 1
fi

# Показываем меню (fuzzel сам подтянет настройки из fuzzel.ini)
selected=$(echo "$devices" | fuzzel --dmenu -i -p "󰓃 Аудио:")

if [ ! -z "$selected" ]; then
    # Вытягиваем чистый ID устройства (цифры до точки)
    node_id=$(echo "$selected" | awk '{print $1}' | tr -d '.')
    
    # Делаем устройство дефолтным
    wpctl set-default "$node_id"
    
    # Опционально: отправляем уведомление, что звук переключен
    dev_name=$(echo "$selected" | cut -d'.' -f2- | sed 's/^[[:space:]]*//')
    notify-send "Аудио" "Выход изменен на: $dev_name"
fi
