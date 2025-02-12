#!/bin/sh

#let's set fonts for HIDPI screens
setfont ter-132b

echo "#####################################################"
echo "#          ARCH LINUX SCRIPT INSTALLER              #"
echo "#####################################################"
echo " "
echo " "

#####This line of code is to see if is bios or uefi. Bios==32 & Uefi==64
BiosOrUefi=$(cat /sys/firmware/efi/fw_platform_size)

if [ "$BiosOrUefi" = '64' ]
then
	echo "You are using a UEFI system"
elif [ "$BiosOrUefi" = '32' ]
then
	echo "You are using a UEFI system that can only use systemd-boot or grub"
else
    BiosOrUefi='0'
    echo "You are using a BIOS system"
fi

#Updates the system clock
timedatectl

#Making the partitions for the system
echo "Selecting drive for installation"
lsblk

echo "You will need to select a drive for your arch linux installation: for example, if you need sda drive put the path like this: /dev/sda"

read -r -p "Please insert your desire drive to make installation: " DISK
echo

echo "Creating partitions on $DISK..."

### This if make the partitions for bios or uefi depending the case.
if [ "$BiosOrUefi" = '64' ]
then
	# Create a GPT partition table (for UEFI systems)
	sudo fdisk "$DISK" << EOF
	g  # Create a new empty partition table (GPT)
	n  # New partition for EFI System (512MB)
	p
	1

	+512M
	n  # New partition for root (/) (remaining space)
	p
	2


	w  # Write changes and exit
EOF
elif [ "$BiosOrUefi" = '32' ]
then
    sudo fdisk "$DISK" << EOF
    g  # Create a new empty partition table (GPT)
    n  # New partition for EFI System (512MB)
    p
    1

    +512M
    n  # New partition for root (/) (remaining space)
    p
    2


    w  # Write changes and exit
EOF
elif [ "$BiosOrUefi" = '0' ]
then
    sudo fdisk  "$DISK" << EOF
    o # Create new empy partition table (MBR)
    n  # New partition for EFI System (512MB)
    p
    1

    +512M
    n  # New partition for root (/) (remaining space)
    p
    2


    w  # Write changes and exit
EOF
else
    echo "something went wrong when creating partitions. Please cancel the script with ctrl + c"
    sleep 3600
fi


### NEED TO CREATE FORMATING OF PARTITIONS WITH NVME SUPPORT
# Format the partitions
echo "Formatting partitions..."
sudo mkfs.fat -F 32 "${DISK}"1  # EFI System Partition (ESP)
sudo mkfs.ext4 "${DISK}"2       # Root partition

# Mount the partitions for installation
echo "Mounting partitions..."
mount "${DISK}"2 /mnt
mkdir -p /mnt/boot
mount "${DISK}"1 /mnt/boot

echo "Done. Proceeding with Arch Linux installation."

### Needs to install amd or intel microcode
### INSTALL LIST AND ARCH CHROOT ###
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf
pacstrap -K /mnt base linux linux-firmware grub man-db man-pages texinfo vi vim eza networkmanager ntp bat alacritty kitty sudo fastfetch ufw

genfstab -U /mnt >> /mnt/etc/fstab
cp /root/ArchLinuxInstaller/chrootPart.sh /mnt/chrootPart.sh
arch-chroot /mnt /chrootPart.sh "$DISK"

umount -R /mnt

echo "#####################################################"
echo "#                 CONGRATULATIONS!                  #"
echo "#####################################################"
echo " "
echo " "
echo "You arch linux installation is completed, just write reboot to reboot the system and start using it!"
echo "by the way, you have alacritty and kitty by default terminals"
echo "please use visudo to uncomment the wheel group if you want your user to have sudo privilege"
