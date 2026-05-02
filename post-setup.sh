#!/bin/bash
set -e

USER=$1
HOST=$2
ROOT=$3

echo "==> Setup time and locale..."
ln -sf /usr/share/zoneinfo/Europe/Warsaw /etc/localtime
hwclock --systohc

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "$HOST" >> /etc/hostname

echo "==> Creating root password..."
passwd

echo "==> Creating user..."
useradd -m -G wheel -s /bin/bash "$USER"

echo "Enter the password for $USER:"
passwd "$USER"

echo "Now You must manually give permissions for $USER"
echo 'Just uncomment this line ==> "%wheel ALL=(ALL:ALL) ALL"'
read -p "press enter to continue..."
EDITOR=nvim visudo

echo "==> Enabling NetworkManager..."
systemctl enable NetworkManager

echo "==> installing systemd-boot..."
bootctl install

# Получаем UUID для конфига загрузчика
UUID=$(blkid -s UUID -o value "$ROOT")

cat <<EOF > /boot/loader/loader.conf
default  arch.conf
timeout  0
console-mode max
EOF

cat <<EOF > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=$UUID rw
EOF

echo "==> loading dotfiles..."
su - "$USER" -c "git clone https://github.com/Iem0n/arch_sync.git ~/my-dotfiles"
su - "$USER" -c "cd ~/my-dotfiles && ./install.sh"

echo "==> Generating ZRAM..."
pacman -S zram-generator
cat <<EOF > /etc/systemd/zram-generator.conf
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
EOF

echo "==> Завершение настройки в chroot."

exit
