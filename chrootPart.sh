#!/bin/bash

DISK="$1"
encryptFlag="$2"
WMAnswer="$3"
DesktopsAnswer="$4"
AllDesktopsAnswer="$5"
OneDesktopAnswer="$6"
Password='0'
answer='no'
oneDeskFlag='0' #Flag to trigger not asking to install more desktops if user decided to install just one.

psswd_check() {
    while true; do
        read -s -p "Enter password: " Password
        echo
        read -s -p "Confirm password: " Confirm
        echo

        if [ "$Password" == "$Confirm" ]; then
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

if [[ "${answer,,}" =~ ^(y|yes)$ ]]
then
    read -r -p "Please write your new user username: " User
    echo
    read -r -p "do you want to have your new user in wheel group to have sudo ussage? write yes or no: " wheel
    echo
    if [[ "${wheel,,}" =~ ^(y|yes)$ ]]
    then
        useradd -m "$User"
        usermod -aG wheel "$User"
       # sed -i 's/^#\s*%wheel\sALL=(ALL)\sALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
        sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
        echo "You will need to create your "$User" password now."
        psswd_check
        echo "$Password" | passwd --stdin "$User"
    fi
else
    echo "okey, another user will not be made"
    User='0' #This help in the last if block to check if a user was made or not
fi

#initcpio only for unencrypted devices. It avoids making it twice in the opposite case
if [[ "${encryptFlag,,}" =~ ^(n|no)$ ]]
then
    mkinitcpio -P
fi

# GRUB INSTALLATION AND CONFIGURATION
BiosOrUefi=$(cat /sys/firmware/efi/fw_platform_size)

if [[ "${encryptFlag,,}" =~ ^(n|no)$ ]]
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


if [[ "${WMAnswer,,}" =~ ^(y|yes)$ ]]
then
    ### Installing dwm window manager
    read -r -p "Do you want to install DWM for window manager support ? write yes or no: " answer
    echo
fi

if [[ "${answer,,}" =~ ^(y|yes)$  && "$User" = '0' ]]
then
    pacman -S rofi lf xorg xorg-xinit base base-devel ntp feh picom calcurse task fzf nerd-fonts gnu-free-fonts ttf-font-awesome noto-fonts-emoji ttf-iosevka-nerd xdg-desktop-portal xdg-desktop-portal-gtk --noconfirm
    cd
    mkdir programs && cd programs
    git clone https://github.com/CarlosR759/dwm-rice
    git clone https://github.com/CarlosR759/dmenu-rice
    git clone https://github.com/CarlosR759/dwmBlocks-rice

    cd ~/programs/dwm-rice
    make clean install
    cd ~/programs/dmenu-rice
    make clean install
    cd ~/programs/dwmBlocks-rice
    make clean install
    mkdir ~/.config
    cd ~/.config
    git clone https://github.com/CarlosR759/mydotfiles .
    cp /etc/X11/xinit/xinitrc ~/.xinitrc
    sed -i 's/^"$twm" &//' /home/root/.xinitrc
    sed -i 's/^"$xclock" -geometry 50x50-1+1 &//' /home/root/.xinitrc
    sed -i 's/^"$xterm" -geometry 80x50+494+51 &//' /home/root/.xinitrc
    sed -i 's/^"$xterm" -geometry 80x20+494-0 &//' /home/root/.xinitrc
    sed -i 's/^exec "$xterm" -geometry 80x66+0+0 -name login//' /home/root/.xinitrc
    cd
    wget -O ~/.bashrc https://raw.githubusercontent.com/CarlosR759/bashrc/main/bashrc
    git clone https://github.com/CarlosR759/wallpapers
    echo "feh --bg-scale ~/wallpapers/container_ship.png" >> /home/root/.xinitrc
    echo "picom -b &" >> /home/root/.xinitrc
    echo "dwmblocks &" >> /home/root/.xinitrc
    echo "dwm 2> ~/.dwm.log" >> /home/root/.xinitrc
elif [[ "${answer,,}" =~ ^(y|yes)$ && "$User" != '0' ]]
then
    pacman -S rofi lf xorg xorg-xinit base base-devel ntp feh picom calcurse task fzf nerd-fonts gnu-free-fonts ttf-font-awesome noto-fonts-emoji ttf-iosevka-nerd --noconfirm
    cd /home/"$User"
    mkdir programs && cd programs
    git clone https://github.com/CarlosR759/dwm-rice
    git clone https://github.com/CarlosR759/dmenu-rice
    git clone https://github.com/CarlosR759/dwmBlocks-rice

    cd /home/"$User"/programs/dwm-rice
    make clean install
    cd /home/"$User"/programs/dmenu-rice
    make clean install
    cd /home/"$User"/programs/dwmBlocks-rice
    make clean install
    mkdir /home/"$User"/.config
    cd /home/"$User"/.config
    git clone https://github.com/CarlosR759/mydotfiles .
    cp /etc/X11/xinit/xinitrc /home/"$User"/.xinitrc
    sed -i 's/^"$twm" &//' /home/"$User"/.xinitrc
    sed -i 's/^"$xclock" -geometry 50x50-1+1 &//' /home/"$User"/.xinitrc
    sed -i 's/^"$xterm" -geometry 80x50+494+51 &//' /home/"$User"/.xinitrc
    sed -i 's/^"$xterm" -geometry 80x20+494-0 &//' /home/"$User"/.xinitrc
    sed -i 's/^exec "$xterm" -geometry 80x66+0+0 -name login//' /home/"$User"/.xinitrc
    cd /home/"$User"
    wget -O ~/.bashrc https://raw.githubusercontent.com/CarlosR759/bashrc/main/bashrc
    git clone https://github.com/CarlosR759/wallpapers
    echo "feh --bg-scale ~/wallpapers/container_ship.png" >> /home/"$User"/.xinitrc
    echo "picom -b &" >> /home/"$User"/.xinitrc
    echo "dwmblocks &" >> /home/"$User"/.xinitrc
    echo "dwm 2> ~/.dwm.log" >> /home/"$User"/.xinitrc
fi

if [[ "${WMAnswer,,}" =~ ^(y|yes)$ ]]
then
    ### Installing Hyprland window manager
    read -r -p "Do you want to install Hyprland window manager ? write yes or no: " hyprAnswer
    echo
fi

if [[ "${hyprAnswer,,}" =~ ^(y|yes)$ && "$User" != '0' ]]
then
    pacman -S hyprland hyprpaper hyprpicker hyprlock xdg-desktop-portal-hyprland hyprpolkitagent hyprsunset mesa libglvnd rofi lf calcurse flameshot fzf nerd-fonts gnu-free-fonts ttf-font-awesome noto-fonts-emoji ttf-iosevka-nerd --noconfirm
    mkdir -p /home/"$User"/.config/
    cd /home/"$User"/.config/
    git clone https://github.com/CarlosR759/mydotfiles .
    mkdir /home/"$User"/.config/hypr/
    cd /home/"$User"/.config/hypr/
    git clone https://github.com/CarlosR759/HyprConfs .
    cd /home/"$User"/
    git clone https://github.com/CarlosR759/wallpapers
    cd /home/"$User"/
    wget -O /home/"$User"/.bashrc https://raw.githubusercontent.com/CarlosR759/bashrc/main/bashrc

    #Installing my eww bar
    pacman -S rust --noconfirm
    git clone https://github.com/elkowar/eww
    cd eww
    cargo build --release --no-default-features --features=wayland
    cd target/release
    chmod +x ./eww
    cp ./eww /usr/local/bin/
    mkdir  /home/"$User"/.config/eww/
    cd /home/"$User"/.config/eww/
    git clone https://github.com/CarlosR759/PotPlantCozzySysBar .
elif [[ "${hyprAnswer,,}" =~ ^(y|yes)$ && "$User" == '0' ]]
then
    pacman -S hyprland hyprpaper hyprpicker hyprlock xdg-desktop-portal-hyprland hyprpolkitagent hyprsunset mesa libglvnd rofi lf calcurse flameshot fzf nerd-fonts gnu-free-fonts ttf-font-awesome noto-fonts-emoji ttf-iosevka-nerd --noconfirm
    mkdir -p /home/root/.config/
    cd /home/root/.config/
    git clone https://github.com/CarlosR759/mydotfiles .
    mkdir /home/root/.config/hypr/
    cd /home/root/.config/hypr/
    git clone https://github.com/CarlosR759/HyprConfs .
    cd  /home/root/
    git clone https://github.com/CarlosR759/wallpapers
    cd /home/"$User"/
    wget -O /home/root/.bashrc https://raw.githubusercontent.com/CarlosR759/bashrc/main/bashrc

    #Installing my eww bar
    pacman -S rust --noconfirm
    git clone https://github.com/elkowar/eww
    cd eww
    cargo build --release --no-default-features --features=wayland
    cd target/release
    chmod +x ./eww
    cp ./eww /usr/local/bin/
    mkdir  /home/"$User"/.config/eww/
    cd /home/"$User"/.config/eww/
    git clone https://github.com/CarlosR759/PotPlantCozzySysBar .
fi

#Desktops installation section
if [[ "${DesktopsAnswer,,}" =~ ^(y|yes)$ ]]
then
    read -r -p "Do you want to install KDE desktop ? Write yes or no: " KdeAnswer
    echo
    if [[ "${KdeAnswer,,}" =~ ^(y|yes)$ ]]
    then
        pacman -S plasma --noconfirm
        systemctl enable sddm.service
        if [[ "${OneDesktopAnswer,,}" =~ ^(y|yes)$ ]]
        then
            oneDeskFlag='1'
        fi
    fi
    if [[ "$oneDeskFlag" == '0' ]]
    then
        read -r -p "Do you want to install Gnome desktop ? Write yes or no: " GnomeAnswer
        echo
    fi
    if [[ "${GnomeAnswer,,}" =~ ^(y|yes)$ && "$oneDeskFlag" == '0' ]]
    then
        pacman -S gnome --noconfirm
        systemctl enable gdm.service
        if [[ "${OneDesktopAnswer,,}" =~ ^(y|yes)$ ]]
        then
            oneDeskFlag='1'
        fi
    fi
    if [[ "$oneDeskFlag" == '0' ]]
    then
        read -r -p "Do you want to install Cosmic desktop ? Write yes or no: " CosmicAnswer
        echo
    fi
    if [[ "${CosmicAnswer,,}" =~ ^(y|yes)$ && "$oneDeskFlag" == '0' ]]
    then
        pacman -S cosmic --noconfirm
        systemctl enable cosmic-greeter.service
        if [[ "${OneDesktopAnswer,,}" =~ ^(y|yes)$ ]]
        then
            oneDeskFlag='1'
        fi
    fi
    if [[ "$oneDeskFlag" == '0' ]]
    then
        read -r -p "Do you want to install Xfce desktop ? Write yes or no: " XfceAnswer
        echo
    fi
    if [[ "${XfceAnswer,,}" =~ ^(y|yes)$ && "$oneDeskFlag" == '0' ]]
    then
        pacman -S xfce4 --noconfirm
        systemctl enable lightdm.service
        if [[ "${OneDesktopAnswer,,}" =~ ^(y|yes)$ ]]
        then
            oneDeskFlag='1'
        fi
    fi
    if [[ "$oneDeskFlag" == '0' ]]
    then
        read -r -p "Do you want to install mate desktop ? Write yes or no: " MateAnswer
        echo
    fi
    if [[ "${MateAnswer,,}" =~ ^(y|yes)$ && "$oneDeskFlag" == '0' ]]
    then
        pacman -S mate --noconfirm
        systemctl enable lightdm.service
    fi
fi


systemctl enable ufw
ufw default deny incoming
ufw default allow outgoing
ufw enable
rm -rf /chrootPart.sh
exit
