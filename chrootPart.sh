#!/bin/sh

Password='0'
psswd_check() {
    if [[ "$1" != "$2" ]]
    then
        echo
        echo "Password didn't match!"
        echo
        read -rs -p "Please repeat your password: " repeatPassword1
        echo
        read -rs -p "Please repeat your password again: " repeatPassword2
        echo
        psswd_check "$repeatPassword1" "$repeatPassword2"
    fi

    Password="$1"
}

ln -sf /usr/share/zoneinfo/Chile/Continental /etc/localtime
hwclock --systohc

#Adding parallel downloads to new chroot environemnt
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf
pacman -Syyu

#Ntp conf and locale conf
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
psswd_check "$Password1" "$Password2"
#Needs to verify password match
echo "$Password" | passwd --stdin

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
        Password=$(psswd_check "$Password1" "$Password2")
        echo "$Password" | passwd --stdin "$User"
        ### NEED TO VERIFY PASSWORD MATCH
    fi
else
    echo "okey, another user will not be made"
    User='0' #This help in the last if to check if a user was made or not
fi

mkinitcpio -P

# GRUB INSTALLATION AND CONFIGURATION
BiosOrUefi=$(cat /sys/firmware/efi/fw_platform_size)

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

if [[ "$answer" = 'yes'  && "$User" = '0' ]]
then
    pacman -S git rofi lf xorg xorg-xinit base base-devel ntp feh picom nerd-fonts gnu-free-fonts ttf-font-awesome noto-fonts-emoji ttf-iosevka-nerd --noconfirm
    cd
    git clone https://github.com/CarlosR759/dwm-rice
    git clone https://github.com/CarlosR759/dmenu-rice
    mkdir programs && cd programs
    git clone https://github.com/CarlosR759/dwmBlocks-rice

    cd ~/dwm-rice
    make clean install
    cd ~/dmenu-rice
    make clean install
    cd ~/programs/dwmBlocks-rice
    make clean install
    mkdir ~/.config
    cd ~/.config
    git clone https://github.com/CarlosR759/mydotfiles .
    cp /etc/X11/xinit/xinitrc ~/.xinitrc
    sed -i 's/^$twm &//' ~/.xinitrc
    sed -i 's/^$xclock -geometry 50x50-1+1 &//' ~/.xinitrc
    sed -i 's/^$xterm -geometry 80x50+494+51 &//' ~/.xinitrc
    sed -i 's/^$xterm -geometry 80x20+494-0 &//' ~/.xinitrc
    sed -i 's/^exec $xterm -geometry 80x66+0+0 -name login//' ~/.xinitrc

    #echo "feh --bg-scale ~/wallpapers/container_ship.png" >> ~/.xinitrc
    echo "picom -b &" >> ~/.xinitrc
    echo "dwmblocks &" >> ~/.xinitrc
    echo "dwm 2> ~/.dwm.log" >> ~/.xinitrc
elif [[ "$answer" = 'yes' && "$User" != '0' ]]
then
    pacman -S git rofi lf xorg xorg-xinit base base-devel ntp feh picom nerd-fonts gnu-free-fonts ttf-font-awesome noto-fonts-emoji ttf-iosevka-nerd --noconfirm
    cd /home/"$User"
    git clone https://github.com/CarlosR759/dwm-rice
    git clone https://github.com/CarlosR759/dmenu-rice
    mkdir programs && cd programs
    git clone https://github.com/CarlosR759/dwmBlocks-rice

    cd /home/"$User"/dwm-rice
    make clean install
    cd /home/"$User"/dmenu-rice
    make clean install
    cd /home/"$User"/programs/dwmBlocks-rice
    make clean install
    mkdir /home/"$User"/.config
    cd /home/"$User"/.config
    git clone https://github.com/CarlosR759/mydotfiles .
    cp /etc/X11/xinit/xinitrc /home/"$User"/.xinitrc
    sed -i 's/^$twm &//' /home/"$User"/.xinitrc
    sed -i 's/^$xclock -geometry 50x50-1+1 &//' /home/"$User"/.xinitrc
    sed -i 's/^$xterm -geometry 80x50+494+51 &//' /home/"$User"/.xinitrc
    sed -i 's/^$xterm -geometry 80x20+494-0 &//' /home/"$User"/.xinitrc
    sed -i 's/^exec $xterm -geometry 80x66+0+0 -name login//' /home/"$User"/.xinitrc

    #echo "feh --bg-scale ~/wallpapers/container_ship.png" >> ~/.xinitrc
    echo "picom -b &" >> ~/.xinitrc
    echo "dwmblocks &" >> ~/.xinitrc
    echo "dwm 2> ~/.dwm.log" >> ~/.xinitrc
fi

rm -rf /chrootPart.sh
exit
## Add password verificator function
