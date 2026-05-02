#!/bash/bin
set -e

echo "==> List of avalible drives:"
lsblk -dno NAME,SIZE,MODEL | grep -v "loop"
read -p "Enter drive name (nvme0n1 or sda): " DISK_NAME
DISK="/dev/$DISK_NAME"

if [ ! -b "$DISK" ]; then
    echo "ERROR: Disk $DISK not found!"
    exit 1
fi

[[ $DISK =~ "nvme" ]] && P="p" || P=""

echo "Select install mode:"
echo "1) Dualboot"
echo "2) Only Linux"
read -p "Your choice (1/2): " MODE

if [[ $MODE == "1" ]]; then
    EFI_PART="${DISK}${P}1"
    ROOT_PART="${DISK}${P}4"
    FORMAT_EFI=false
    echo "MODE: Dualboot. EFI ($EFI_PART) will not be formated."
elif [[ $MODE == "2" ]]; then
    # Для режима "Only Linux" обычно используют p1 (EFI) и p2 (Root)
    EFI_PART="${DISK}${P}1"
    ROOT_PART="${DISK}${P}2"
    FORMAT_EFI=true
    echo "MODE: Only Linux. EFI ($EFI_PART) WILL BE FORMATED!"
else
    echo "Invalid choice!"
    exit 1
fi

echo "WARNING: ROOT ($ROOT_PART) WILL BE FORMATED!"
read -p "Continue? (y/n): " confirm
[[ $confirm != "y" ]] && exit 1

echo "==>  Formating root..."
mkfs.ext4 -F "$ROOT_PART"

if [ "$FORMAT_EFI" = true ]; then
    echo "==> Formating EFI..."
    mkfs.fat -F32 "$EFI_PART"
fi

echo "==> Mounting parts..."
mount "$ROOT_PART" /mnt
mkdir -p /mnt/boot
mount "$EFI_PART" /mnt/boot

echo "==> Installing base system..."
pacstrap -K /mnt base linux linux-firmware linux-headers amd-ucode base-devel networkmanager neovim efibootmgr git

echo "==> Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

echo "==> Copying post-install sript..."
cp post_install.sh /mnt/post_install.sh
chmod +x /mnt/post_install.sh

echo "==> Enter in chroot..."
arch-chroot /mnt ./post-install.sh "vova" "vova-pc" "$ROOT"

read -p "system instaled! press ENTER for reboot"

umount -R /mnt
reboot
