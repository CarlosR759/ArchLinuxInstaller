#!/bin/sh

ln -sf /usr/share/zoneinfo/Chile/Continental /etc/localtime
hwclock --systohc

#Adding parallel downloads to new chroot environemnt
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf
pacman -Syyu

#Ntp conf and locale conf
#Check this line of systemctl
systemctl enable ntpd.service
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

#Network configuration part#
read -r -p "Please insert your desire hostname name: " Hostname
echo
echo "$Hostname" >> /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $Hostname.localdomain $Hostname" >> /etc/hosts
systemctl enable NetworkManager.service

#Setting root password
read -rs -p "Please create your root account password: " Password1
echo
read -rs -p "Please write your password again: " Password2
echo
#Needs to verify password match
echo "$Password1" | passwd --stdin

read -r -p "Do you want to create another user besides root ? write yes or no: " answer
echo

if [ "$answer" = 'yes' ]
then
    read -r -p "Please write your new user username: " User
    echo
    read -r -p "do you want to have your new user in wheel group to have sudo ussage? write yes or no: " wheel
    echo
    if [ "$wheel" = 'yes' ]
    then
        useradd -m "$User"
        usermod -aG wheel "$User"
        read -rs -p "Please create your $User account password: " Password1
        echo
        read -rs -p "Please write your password again: " Password2
        echo
        echo "$Password1" | passwd --stdin "$User"
        ### NEED TO VERIFY PASSWORD MATCH
    fi
else
    echo "okey, another user will not be made"
fi

mkinitcpio -P

# GRUB INSTALLATION AND CONFIGURATION
# NEED TO CHECK IF THIS VARIABLE IS OKEY OR NOT
BiosOrUefi=$(cat /sys/firmware/efi/fw_platform_size) #Check if path is correct

if [ "$BiosOrUefi" = '64' ]
then
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
elif [ "$BiosOrUefi" = '32' ]
then
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
else
    #grub-install "$DISK"
    grub-install /dev/vda
fi

grub-mkconfig -o /boot/grub/grub.cfg



### Installing window manager
read -r -p "Do you want to install DWM for window manager support ? write yes or no: " answer
echo

if [ "$answer" = 'yes' ]
then
    pacman -S git rofi lf xorg xorg-xinit base base-devel ntp feh picom nerd-fonts gnu-free-fonts ttf-font-awesome noto-fonts-emoji ttf-iosevka-nerd
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
    mkdir ~/.config
    cd ~/.config
    git clone https://github.com/CarlosR759/mydotfiles .
    cp /etc/X11/xinit/xinitrc ~/.xinitrc
    #echo "feh --bg-scale ~/wallpapers/container_ship.png" >> ~/.xinitrc
    echo "picom -b &" >> ~/.xinitrc
    echo "dwmblocks &" >> ~/.xinitrc
    echo "dwm 2> ~/.dwm.log" >> ~/.xinitrc
fi

rm -rf /chrootPart.sh
exit
## TODO: add parallel downloads
## Add password verificator function
