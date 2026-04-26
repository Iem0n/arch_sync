#!/bin/bash

set -e

BLUE='\033[0;34m'
NC='\033[0m'
DOT_DIR="$(pwd)/dotfiles"

mkdir -p "$DOT_DIR"

# --- Функция установки Paru (если нужно) ---
install_paru() {
    if ! command -v paru &> /dev/null; then
        echo -e "${BLUE}==>${NC} Установка Paru..."
        sudo pacman -S --needed --noconfirm base-devel git
        TEMP_DIR=$(mktemp -d)
        git clone https://aur.archlinux.org/paru.git "$TEMP_DIR"
        cd "$TEMP_DIR" && makepkg -si --noconfirm && cd - && rm -rf "$TEMP_DIR"
    fi
}

# --- Логика переноса и линковки ---
sync_configs() {
    if [ ! -f "targets.txt" ]; then
        echo "Файл targets.txt не найден! Создай его и впиши пути к конфигам."
        return
    fi

    while read -r path; do
        [ -z "$path" ] && continue # Пропускаем пустые строки
        
        src="$HOME/$path"
        dest="$DOT_DIR/$path"

        if [ -e "$src" ]; then
            # 1. Если файл в дотфайлах уже есть, а в системе — настоящий файл (не ссылка)
            # Перемещаем оригинал в репозиторий, если его там еще нет
            if [ ! -L "$src" ]; then
                echo -e "${BLUE}==>${NC} Захват конфига: $path"
                mkdir -p "$(dirname "$dest")"
                mv "$src" "$dest"
            fi

            # 2. Создаем симлинк обратно в систему
            mkdir -p "$(dirname "$src")"
            ln -sfv "$dest" "$src"
        else
            echo -e "Предупреждение: $src не найден, пропускаю."
        fi
    done < targets.txt
}

# --- Основной запуск ---
install_paru

if [ -f "packages.txt" ]; then
    echo -e "${BLUE}==>${NC} Установка пакетов..."
    paru -S --needed --noconfirm - < packages.txt
fi

sync_configs

# Перенос обоев (опционально)
if [ -d "wallpapers" ]; then
    mkdir -p "$HOME/Pictures/wallpapers"
    cp -v wallpapers/* "$HOME/Pictures/wallpapers/"
fi

echo -e "${BLUE}==>${NC} Готово! Конфиги перенесены в репозиторий и залинкованы."
