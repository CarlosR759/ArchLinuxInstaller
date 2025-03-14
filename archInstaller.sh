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
	echo
elif [ "$BiosOrUefi" = '32' ]
then
	echo "You are using a UEFI system that can only use systemd-boot or grub"
	echo
else
    BiosOrUefi='0'
    echo "You are using a BIOS system"
    echo
fi

#Updates the system clock
timedatectl

#Making the partitions for the system
echo "Selecting drive for installation"
lsblk

echo "You will need to select a drive for your arch linux installation: for example, if you need sda drive put the path like this: /dev/sda"
echo
read -r -p "Please insert your desire drive to make installation: " DISK
echo
read -r -p "Do you want to encrypt root partition? (yes/no) : " encryptFlag
echo
echo "Creating partitions on $DISK..."

### This if make the partitions for bios or uefi depending the case.
if [ "$encryptFlag" = 'no' ]
then
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
elif [ "$encryptFlag" = 'yes' ]
then
  if [ "$BiosOrUefi" = '64' ]
  then
    if [[ "$DISK" == /dev/nvme* ]]
    then
      cryptsetup luksFormat "$DISK"p1
      echo "Please introduce your password to open drive"
      crypsetup open "$DISK"p2 rootDrive
    elif [[ "$DISK" == /dev/sd* ]]; then
      cryptsetup luksFormat "$DISK"2
      echo "Please introduce your password to open drive"
      crypsetup open "$DISK"2 rootDrive
    fi
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
    if [[ "$DISK" == /dev/nvme* ]]
    then
      cryptsetup luksFormat "$DISK"p2
      echo "Please introduce your password to open drive"
      crypsetup open "$DISK"p2 rootDrive
    elif [[ "$DISK" == /dev/sd* ]]; then
      cryptsetup luksFormat "$DISK"2
      echo "Please introduce your password to open drive"
      crypsetup open "$DISK"2 rootDrive
    fi

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
    if [[ "$DISK" == /dev/nvme* ]]
    then
      cryptsetup luksFormat "$DISK"p2
      echo "Please introduce your password to open drive"
      crypsetup open "$DISK"p2 rootDrive
    elif [[ "$DISK" == /dev/sd* ]]; then
      cryptsetup luksFormat "$DISK"2
      echo "Please introduce your password to open drive"
      crypsetup open "$DISK"2 rootDrive
    fi

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
fi


###Checks if drive is sata or mvme to create file systems and mounting.
if [ "$encryptFlag" = 'no' ]
then
  if [[ "$DISK" == /dev/nvme* ]]
  then
    echo "Formatting partitions..."
    sudo mkfs.fat -F 32 "${DISK}"p1  # EFI System Partition (ESP)
    sudo mkfs.ext4 "${DISK}"p2       # Root partition

    # Mount the partitions for installation
    echo "Mounting partitions..."
    mount "${DISK}"p2 /mnt
    mkdir -p /mnt/boot
    mount "${DISK}"p1 /mnt/boot

  elif [[ "$DISK" == /dev/sd* ]]
  then
    echo "Formatting partitions..."
    sudo mkfs.fat -F 32 "${DISK}"1  # EFI System Partition (ESP)
    sudo mkfs.ext4 "${DISK}"2       # Root partition

    # Mount the partitions for installation
    echo "Mounting partitions..."
    mount "${DISK}"2 /mnt
    mkdir -p /mnt/boot
    mount "${DISK}"1 /mnt/boot
  elif [["$DISK" == /dev/vd* ]]
  then
    echo "Formatting partitions for virtual drive..."
    sudo mkfs.fat -F 32 "${DISK}"1  # EFI System Partition (ESP)
    sudo mkfs.ext4 "${DISK}"2       # Root partition

    # Mount the partitions for installation
    echo "Mounting partitions..."
    mount "${DISK}"2 /mnt
    mkdir -p /mnt/boot
    mount "${DISK}"1 /mnt/boot
  fi
elif [ "$encryptFlag" = 'yes' ]
then
    if [[ "$DISK" == /dev/nvme* ]]
    then
      echo "Formatting partitions..."
      sudo mkfs.fat -F 32 "${DISK}"p1  # EFI System Partition (ESP)
      sudo mkfs.ext4 /dev/mapper/rootDrive       # Root partition

      # Mount the partitions for installation
      echo "Mounting partitions..."
      mount /dev/mapper/rootDrive /mnt
      mkdir -p /mnt/boot
      mount "${DISK}"p1 /mnt/boot

    elif [[ "$DISK" == /dev/sd* ]]
    then
      echo "Formatting partitions..."
      sudo mkfs.fat -F 32 "${DISK}"1  # EFI System Partition (ESP)
      sudo mkfs.ext4 /dev/mapper/rootDrive       # Root partition

      # Mount the partitions for installation
      echo "Mounting partitions..."
      mount /dev/mapper/rootDrive /mnt
      mkdir -p /mnt/boot
      mount "${DISK}"1 /mnt/boot

    elif [["$DISK" == /dev/vd* ]]
    then
      echo "Formatting partitions for virtual drive..."
      sudo mkfs.fat -F 32 "${DISK}"1  # EFI System Partition (ESP)
      sudo mkfs.ext4 /dev/mapper/rootDrive       # Root partition

      # Mount the partitions for installation
      echo "Mounting partitions..."
      mount /dev/mapper/rootDrive /mnt
      mkdir -p /mnt/boot
      mount "${DISK}"1 /mnt/boot
    fi
fi
echo "Done. Proceeding with Arch Linux installation."

### Checks if cpu is intel, amd o virtualize
cpu_info=$(cat /proc/cpuinfo)
if echo "$cpu_info" | grep -iq 'intel'; then
    cpu_vendor="Intel"
elif echo "$cpu_info" | grep -iq 'amd'; then
    cpu_vendor="AMD"
else
    cpu_vendor="virtualMachine"
fi

### INSTALL LIST AND ARCH CHROOT ###
sed -i 's/^#ParallelDownloads = 5/ParallelDownloads = 5/' /etc/pacman.conf

if [ "$cpu_vendor" = "Intel" ]
then
    pacstrap -K /mnt base linux linux-firmware intel-ucode grub man-db man-pages texinfo vi vim eza networkmanager ntp bat alacritty kitty sudo fastfetch ufw
elif [ "$cpu_vendor" = "AMD" ]
then
    pacstrap -K /mnt base linux linux-firmware amd-ucode grub man-db man-pages texinfo vi vim eza networkmanager ntp bat alacritty kitty sudo fastfetch ufw
elif [ "$cpu_vendor" = "virtualMachine" ]
then
    pacstrap -K /mnt base linux linux-firmware grub man-db man-pages texinfo vi vim eza networkmanager ntp bat alacritty kitty sudo fastfetch ufw
fi


genfstab -U /mnt >> /mnt/etc/fstab
cp /root/ArchLinuxInstaller/chrootPart.sh /mnt/chrootPart.sh
arch-chroot /mnt ./chrootPart.sh "$DISK"

umount -R /mnt

echo "#####################################################"
echo "#                 CONGRATULATIONS!                  #"
echo "#####################################################"
echo " "
echo " "
echo "You arch linux installation is completed, just write reboot to reboot the system and start using it!"
echo "by the way, you have alacritty and kitty by default terminals"
echo "please use visudo to uncomment the wheel group if you want your user to have sudo privilege"
