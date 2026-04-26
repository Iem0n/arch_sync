#!/bin/bash

# Прекратить выполнение при ошибке
set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${BLUE}==>${NC} Запуск настройки системы Arch Linux..."

# 1. Установка базовых зависимостей для сборки (base-devel и git)
echo -e "${BLUE}==>${NC} Проверка базовых зависимостей (git, base-devel)..."
sudo pacman -S --needed --noconfirm base-devel git

# 2. Автоустановка Paru, если его нет
if ! command -v paru &> /dev/null; then
    echo -e "${BLUE}==>${NC} Paru не найден. Начинаю установку..."
    TEMP_DIR=$(mktemp -d)
    git clone https://aur.archlinux.org/paru.git "$TEMP_DIR"
    cd "$TEMP_DIR"
    makepkg -si --noconfirm
    cd -
    rm -rf "$TEMP_DIR"
    echo -e "${GREEN}==>${NC} Paru успешно установлен."
else
    echo -e "${GREEN}==>${NC} Paru уже установлен, пропускаю."
fi

# 3. Установка пакетов (через paru, чтобы подхватить и AUR, и официальные)
if [ -f "packages.txt" ]; then
    echo -e "${BLUE}==>${NC} Установка пакетов из списка..."
    paru -S --needed --noconfirm - < packages.txt
fi

# 4. Создание симлинков для конфигов
echo -e "${BLUE}==>${NC} Создание символьных ссылок из папки dotfiles..."
DOT_SOURCE="$(pwd)/dotfiles"

if [ -d "$DOT_SOURCE" ]; then
    cd "$DOT_SOURCE"
    # Находим все файлы, включая скрытые
    find . -type f | while read -r file; do
        target="$HOME/${file#./}"
        mkdir -p "$(dirname "$target")"
        ln -sfv "$DOT_SOURCE/${file#./}" "$target"
    done
    cd ..
else
    echo -e "${BLUE}==>${NC} Папка dotfiles не найдена, пропускаю создание ссылок."
fi

# 5. Перенос обоев
if [ -d "wallpapers" ]; then
    echo -e "${BLUE}==>${NC} Копирование обоев..."
    mkdir -p "$HOME/Pictures/wallpapers"
    cp -v wallpapers/* "$HOME/Pictures/wallpapers/"
fi

echo -e "${GREEN}==>${NC} Установка завершена успешно!"
