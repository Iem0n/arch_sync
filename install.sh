#!/bin/bash

# Выход при ошибке
set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

DOT_DIR="$(pwd)/dotfiles"
TARGETS="targets.txt"
PACKAGES="package.txt"

echo -e "${BLUE}==>${NC} Запуск автоматизации Arch Linux..."

# 1. Установка Paru (если нет)
if ! command -v paru &> /dev/null; then
    echo -e "${BLUE}==>${NC} Установка базовых зависимостей и Paru..."
    sudo pacman -S --needed --noconfirm base-devel git
    TEMP_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/paru.git "$TEMP_DIR"
    cd "$TEMP_DIR" && makepkg -si --noconfirm && cd - && rm -rf "$TEMP_DIR"
fi

# 2. Установка пакетов
if [ -f "$PACKAGES" ]; then
    echo -e "${BLUE}==>${NC} Установка пакетов из $PACKAGES..."
    paru -S --needed --noconfirm - < "$PACKAGES"
fi

# 3. Обработка конфигов (Захват и Линковка)
if [ -f "$TARGETS" ]; then
    echo -e "${BLUE}==>${NC} Обработка конфигов..."
    mkdir -p "$DOT_DIR"

    while read -r path; do
        [ -z "$path" ] && continue
        
        src="$HOME/$path"
        dest="$DOT_DIR/$path"

        # Сценарий А: В системе есть реальный файл/папка (надо захватить)
        if [ -e "$src" ] && [ ! -L "$src" ]; then
            echo -e "${GREEN}Захват:${NC} $path"
            mkdir -p "$(dirname "$dest")"
            
            # Используем -T чтобы избежать вложенности папок
            mv -vT "$src" "$dest"
            
            # Создаем симлинк
            ln -sfv "$dest" "$src"

        # Сценарий Б: В системе пусто, но в репозитории файл есть (надо восстановить)
        elif [ ! -e "$src" ] && [ -e "$dest" ]; then
            echo -e "${GREEN}Восстановление ссылки:${NC} $path"
            mkdir -p "$(dirname "$src")"
            ln -sfv "$dest" "$src"
            
        # Сценарий В: Ссылка уже на месте
        elif [ -L "$src" ]; then
            echo -e "Проверка: $path уже является ссылкой."
        fi
    done < "$TARGETS"
else
    echo -e "Файл $TARGETS не найден. Пропускаю конфиги."
fi

# 4. Обои
if [ -d "wallpapers" ]; then
    echo -e "${BLUE}==>${NC} Синхронизация обоев..."
    mkdir -p "$HOME/Pictures/wallpapers"
    cp -rf wallpapers/* "$HOME/Pictures/wallpapers/"
fi

echo -e "${GREEN}==>${NC} Готово! Теперь можно делать git add, commit и push."
