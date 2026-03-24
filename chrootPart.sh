#!/bin/sh

DISK="$1"
encryptFlag="$2"
Password='0'

psswd_check() {
    while true; do
        read -s -p "Enter password: " Password
        echo
        read -s -p "Confirm password: " confirm
        echo

        if [ "$Password" == "$confirm" ]; then
            break
        else
            echo "Passwords do not match. Please try again."
        fi
    done
}


ln -sf /usr/share/zoneinfo/Chile/Continental /etc/localtime
hwclock --systohc

#Adding parallel downloads to new chroot environemnt
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf
pacman -Syyu

#Ntp conf and locale conf
systemctl enable ntpd.service
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
locale-gen

#Network configuration part#
read -r -p "Please insert your desire hostname name: " Hostname
echo
echo "$Hostname" >> /etc/hostname
echo "127.0.0.1       localhost" >> /etc/hosts
echo "::1             localhost" >> /etc/hosts
echo "127.0.1.1       $Hostname.localdomain.$Hostname" >> /etc/hosts
systemctl enable NetworkManager.service

#Setting root password
echo "You will need to create your root password now."
echo
psswd_check
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
        echo "You will need to create your "$User" password now."
        psswd_check
        echo "$Password" | passwd --stdin "$User"
    fi
else
    echo "okey, another user will not be made"
    User='0' #This help in the last if block to check if a user was made or not
fi

#initcpio only for unencrypted devices. It avoids making it twice in the opposite case
if [ "$encryptFlag" == 'no' ]
then
    mkinitcpio -P
fi

# GRUB INSTALLATION AND CONFIGURATION
BiosOrUefi=$(cat /sys/firmware/efi/fw_platform_size)

if [ "$encryptFlag" == 'no' ]
then
  if [ "$BiosOrUefi" = '64' ]
  then
      grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
  elif [ "$BiosOrUefi" = '32' ]
  then
      grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
  else
      grub-install "$DISK"
  fi
  grub-mkconfig -o /boot/grub/grub.cfg
fi

#Generating locale conf
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "en_US ISO-8859-1" >> /etc/locale.gen
locale-gen

### Installing dwm window manager
read -r -p "Do you want to install DWM for window manager support ? write yes or no: " answer
echo

if [[ "$answer" = 'yes'  && "$User" = '0' ]]
then
    pacman -S git rofi lf xorg xorg-xinit base base-devel wget ntp feh picom calcurse task fzf nerd-fonts gnu-free-fonts ttf-font-awesome noto-fonts-emoji ttf-iosevka-nerd xdg-desktop-portal xdg-desktop-portal-gtk --noconfirm
    cd
    mkdir programs && cd programs
    git clone https://github.com/CarlosR759/dwm-rice
    git clone https://github.com/CarlosR759/dmenu-rice
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
    cd
    wget -O ~/.bashrc https://raw.githubusercontent.com/CarlosR759/bashrc/main/bashrc
    git clone https://github.com/CarlosR759/wallpapers
    echo "feh --bg-scale ~/wallpapers/container_ship.png" >> ~/.xinitrc
    echo "picom -b &" >> ~/.xinitrc
    echo "dwmblocks &" >> ~/.xinitrc
    echo "dwm 2> ~/.dwm.log" >> ~/.xinitrc
elif [[ "$answer" = 'yes' && "$User" != '0' ]]
then
    pacman -S git rofi lf xorg xorg-xinit base base-devel wget ntp feh picom calcurse task fzf nerd-fonts gnu-free-fonts ttf-font-awesome noto-fonts-emoji ttf-iosevka-nerd --noconfirm
    cd /home/"$User"
    mkdir programs && cd programs
    git clone https://github.com/CarlosR759/dwm-rice
    git clone https://github.com/CarlosR759/dmenu-rice
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
    cd /home/"$User"
    wget -O ~/.bashrc https://raw.githubusercontent.com/CarlosR759/bashrc/main/bashrc
    git clone https://github.com/CarlosR759/wallpapers
    echo "feh --bg-scale ~/wallpapers/container_ship.png" >> /home/"$User"/.xinitrc
    echo "picom -b &" >> /home/"$User"/.xinitrc
    echo "dwmblocks &" >> /home/"$User"/.xinitrc
    echo "dwm 2> ~/.dwm.log" >> /home/"$User"/.xinitrc
fi

### Installing Hyprland window manager
read -r -p "Do you want to install Hyprland window manager ? write yes or no: " hyprAnswer
echo

if [[ "$hyprAnswer" = 'yes'  && "$User" != '0' ]]
then
    pacman -S git hyprland hyprpaper hyprpicker hyprlock xdg-desktop-portal-hyprland hyprpolkitagent hyprsunset rofi lf calcurse fzf nerd-fonts gnu-free-fonts ttf-font-awesome noto-fonts-emoji ttf-iosevka-nerd --noconfirm
    mkdir -p /home/"$User"/.config/hypr/
    cd /home/"$User"/.config/hypr/
    git clone https://github.com/CarlosR759/HyprConfs
elif [[ "$hyprAnswer" = 'yes' && "$User" == '0' ]]
then
    pacman -S git hyprland hyprpaper hyprpicker hyprlock xdg-desktop-portal-hyprland hyprpolkitagent hyprsunset rofi lf calcurse fzf nerd-fonts gnu-free-fonts ttf-font-awesome noto-fonts-emoji ttf-iosevka-nerd --noconfirm
    mkdir -p /home/root/.config/hypr/
    cd /home/root/.config/hypr/
    git clone https://github.com/CarlosR759/HyprConfs
fi

systemctl enable ufw
rm -rf /chrootPart.sh
exit
