#!/bin/sh

arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Chile/Continental /etc/localtime
hwclock --systohc

#Ntp conf and locale conf
#systemctl enable ntpd.service ###NEEEEEEEEED TO HAVE NTP FIX
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
    pacman -S rofi lf betterlockscreen xorg xorg-xinit ntp feh picom lf
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
