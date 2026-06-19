#!/usr/bin/env python3
import os
import sys
import subprocess
import tomllib  # Встроен в Python 3.11+
from pathlib import Path

# Цветовая схема для вывода в терминал
BLUE = "\033[0;34m"
GREEN = "\033[0;32m"
RED = "\033[0;31m"
NC = "\033[0m"

PROFILE_PATH = Path("profile.toml")
DOT_DIR = Path.cwd() / "."
HOME_DIR = Path.home()


def log_info(message):
    print(f"{BLUE}==>{NC} {message}")


def log_success(message):
    print(f"{GREEN}{message}{NC}")


def log_error(message):
    print(f"{RED}Ошибка:{NC} {message}")


def main():
    if not PROFILE_PATH.exists():
        log_error(f"Файл профиля {PROFILE_PATH} не найден!")
        sys.exit(1)

    log_info("Запуск автоматизации из профиля TOML (Python-style)...")

    # Читаем TOML
    with open(PROFILE_PATH, "rb") as f:
        try:
            profile = tomllib.load(f)
        except Exception as e:
            log_error(f"Не удалось распарсить TOML: {e}")
            sys.exit(1)

    # 1. Установка пакетов через pacman
    packages = profile.get("packages", {}).get("list", [])
    if packages:
        log_info("Синхронизация базы данных и установка пакетов через pacman...")
        # Вызываем системный pacman через sudo
        cmd = ["sudo", "pacman", "-S", "--needed", "--noconfirm"] + packages
        try:
            subprocess.run(cmd, check=True)
        except subprocess.CalledProcessError:
            log_error("Ошибка при установке пакетов через pacman.")
            sys.exit(1)
    else:
        print("Список пакетов в профиле пуст.")

    # 2. Обработка конфигов (Захват и Линковка)
    targets = profile.get("configs", {}).get("targets", [])
    if targets:
        log_info("Обработка конфигурационных файлов...")
        DOT_DIR.mkdir(parents=True, exist_ok=True)

        for target in targets:
            if not target:
                continue

            src = HOME_DIR / target
            dest = DOT_DIR / target

            # Если это битая ссылка — удаляем
            if src.is_symlink() and not src.exists():
                print(f"{RED}Удаление битой ссылки:{NC} {target}")
                src.unlink()

            # Сценарий А: В системе есть реальный файл/папка (надо захватить)
            if src.exists() and not src.is_symlink():
                print(f"{GREEN}Захват:{NC} {target}")
                dest.parent.mkdir(parents=True, exist_ok=True)

                # Замена mv -T: переименовываем/перемещаем
                try:
                    os.rename(src, dest)
                except OSError:
                    # Если папки на разных файловых системах (маловероятно для хомяка, но всё же)
                    import shutil

                    shutil.move(str(src), str(dest))

                # Создаем симлинк
                src.symlink_to(dest)

            # Сценарий Б: В системе пусто, но в репозитории файл есть (надо восстановить)
            elif not src.exists() and dest.exists():
                print(f"{GREEN}Восстановление ссылки:${NC} {target}")
                src.parent.mkdir(parents=True, exist_ok=True)
                src.symlink_to(dest)

            # Сценарий В: Ссылка уже на месте
            elif src.is_symlink():
                print(f"Проверка: {target} уже является ссылкой.")
    else:
        print("Список таргетов в профиле пуст.")

    # 3. Синхронизация обоев
    wallpapers_src = Path("wallpapers")
    if wallpapers_src.is_dir():
        log_info("Синхронизация обоев...")
        wallpapers_dest = HOME_DIR / "Pictures" / "wallpapers"
        wallpapers_dest.mkdir(parents=True, exist_ok=True)

        import shutil

        for wall in wallpapers_src.iterdir():
            if wall.is_file():
                shutil.copy2(wall, wallpapers_dest / wall.name)

    # 4. Обновление кэша шрифтов
    log_info("Обновление кэша шрифтов...")
    subprocess.run(["fc-cache", "-fv"], stdout=subprocess.DEVNULL)

    log_success("==> Готово! Профиль успешно применен на Python.")


if __name__ == "__main__":
    main()
