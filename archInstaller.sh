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
    BiosOrUefi = '32'
    echo "You are using a BIOS system"
fi

#Updates the system clock
timedatectl

#Making the partitions for the system
echo "Selecting drive for installation"
lsblk

echo "You will need to select a drive for your arch linux installation: for example, if you need sda drive put the path like this: /dev/sda"

read -rs -p "Please insert your desire drive to make installation: " DISK


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
    echo "Hey something got wrong in this script during partition making, abort it using ctrl + c, script could not know if system is bios or uefi"
    sleep 20
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
pacstrap -K /mnt base linux linux-firmware man-db man-pages texinfo vi vim eza networkmanager bat alacritty kitty xorg xorg-xinit ntp feh picom lf sudo fastfetch ufw

genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Chile/Continental /etc/localtime
hwclock --systohc

#Ntp conf and locale conf
systemctl enable ntpd.service
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

#Network configuration part#
read -rs -p "Please insert your desire hostname name: " Hostname
echo "$Hostname" >> /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $Hostname.localdomain $Hostname" >> /etc/hosts
systemctl enable NetworkManager.service

#Setting root password
read -rs -p "Please create your root account password: " Password1
read -rs -p "Please write your password again: " Password2
#Needs to verify password match
echo "$Password1" | passwd --stdin

read -rs -p "Do you want to create another user besides root ? write yes or no" answer

if [ "$answer" = 'yes' ]
then
    read -rs -p "Please write your new user username: " User
    read -rs -p "do you want to have your new user in wheel group to have sudo ussage? write yes or no: " wheel
    if [ "$wheel" = 'yes' ]
    then
        useradd "$User"
        usermod -aG wheel "$User"
        read -rs -p "Please create your $User account password: " Password1
        read -rs -p "Please write your password again: " Password2
        echo "$Password1" | passwd --stdin "$User"
        ### NEED TO VERIFY PASSWORD MATCH
    fi
else
    echo "okey, another user will not be made"
fi

mkinitcpio -P

# GRUB INSTALLATION AND CONFIGURATION
if [ "$BiosOrUefi" = '64' ]
then
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
elif [ "$BiosOrUefi" = '32' ]
then
    grub-install "$DISK"
else
    echo "Hey something got wrong in this script during grub installation abort it using ctrl + c, system is not bios or uefi"
    sleep 20
fi

grub-mkconfig -o /boot/grub/grub.cfg



### Installing window manager
read -rs -p "Do you want to install DWM for window manager support ? write yes or no" answer
if [ "$answer" = 'yes' ]
then
    pacman -S xorg picom feh rofi lf betterlockscreen
    cd
    ##Need to change to userfolder instead of root
    git clone https://github.com/CarlosR759/dwm-rice
    git clone https://github.com/CarlosR759/dmenu-rice
    git clone https://github.com/CarlosR759/dwmBlocks-rice

    cd dwm-rice
    make clean install
    cd ~/dmenu-rice
    make clean install
    cd ~/dwmBlocks-rice
    make clean install
    cd ~/.config
    git clone https://github.com/CarlosR759/mydotfiles .
    ## NEED to create xinit file
fi
exit

umount -R /mnt

echo "#####################################################"
echo "#                 CONGRATULATIONS!                  #"
echo "#####################################################"
echo " "
echo " "
echo "You arch linux installation is completed, just write reboot to reboot the system and start using it!"
echo "by the way, you have alacritty and kitty by default terminals"
echo "please use visudo to uncomment the wheel group if you want your user to have sudo privilege"
### TO DO: Check xinitrc configuration
