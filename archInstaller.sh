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
if [ "$encryptFlag" == 'no' ]
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
elif [ "$encryptFlag" == 'yes' ]
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
    if [[ "$DISK" == /dev/nvme* ]]
    then
      read  -s -p "Please insert partition pasword for encryption: " encryptPassword
      cryptsetup luksFormat "$DISK"p2 << EOF
$encryptPassword
$encryptPassword
EOF
      cryptsetup open "$DISK"p2 rootDrive << EOF
$encryptPassword
$encryptPassword
EOF
    elif [[ "$DISK" == /dev/sd* ]]
    then
      read  -s -p "Please insert partition pasword for encryption: " encryptPassword
      cryptsetup luksFormat "$DISK"2 << EOF
$encryptPassword
$encryptPassword
EOF
      cryptsetup open "$DISK"2 rootDrive << EOF
$encryptPassword
$encryptPassword
EOF
    elif [[ "$DISK" == /dev/vd* ]]
    then
      read  -s -p "Please insert partition pasword for encryption: " encryptPassword
      cryptsetup luksFormat "$DISK"2 << EOF
$encryptPassword
$encryptPassword
EOF
      cryptsetup open "$DISK"2 rootDrive << EOF
$encryptPassword
$encryptPassword
EOF
    fi
  elif [ "$BiosOrUefi" = '32' ]
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
    if [[ "$DISK" == /dev/nvme* ]]
    then
      read  -s -p "Please insert partition pasword for encryption: " encryptPassword
      cryptsetup luksFormat "$DISK"p2 << EOF
$encryptPassword
$encryptPassword
EOF
      cryptsetup open "$DISK"p2 rootDrive << EOF
$encryptPassword
$encryptPassword
EOF
    elif [[ "$DISK" == /dev/sd* ]]
    then
      read  -s -p "Please insert partition pasword for encryption: " encryptPassword
      cryptsetup luksFormat "$DISK"2 << EOF
$encryptPassword
$encryptPassword
EOF
      cryptsetup open "$DISK"2 rootDrive << EOF
$encryptPassword
$encryptPassword
EOF
    elif [[ "$DISK" == /dev/vd* ]]
    then
      read  -s -p "Please insert partition pasword for encryption: " encryptPassword
      cryptsetup luksFormat "$DISK"2 << EOF
$encryptPassword
$encryptPassword
EOF
      cryptsetup open "$DISK"2 rootDrive << EOF
$encryptPassword
$encryptPassword
EOF
    fi
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
    if [[ "$DISK" == /dev/nvme* ]]
    then
      read  -s -p "Please insert partition pasword for encryption: " encryptPassword
      cryptsetup luksFormat "$DISK"p2 << EOF
$encryptPassword
$encryptPassword
EOF
      cryptsetup open "$DISK"p2 rootDrive << EOF
$encryptPassword
$encryptPassword
EOF
    elif [[ "$DISK" == /dev/sd* ]]
    then
      read  -s -p "Please insert partition pasword for encryption: " encryptPassword
      cryptsetup luksFormat "$DISK"2 << EOF
$encryptPassword
$encryptPassword
EOF
      cryptsetup open "$DISK"2 rootDrive << EOF
$encryptPassword
$encryptPassword
EOF
    elif [[ "$DISK" == /dev/vd* ]]
    then
      read  -s -p "Please insert partition pasword for encryption: " encryptPassword
      cryptsetup luksFormat "$DISK"2 << EOF
$encryptPassword
$encryptPassword
EOF
      cryptsetup open "$DISK"2 rootDrive << EOF
$encryptPassword
$encryptPassword
EOF
    fi
  else
    echo "something went wrong when creating partitions. Please cancel the script with ctrl + c"
    sleep 3600
  fi
fi


###Checks if drive is sata or mvme to create file systems and mounting.
if [ "$encryptFlag" == 'no' ]
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
  elif [[ "$DISK" == /dev/vd* ]]
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
elif [ "$encryptFlag" == 'yes' ]
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
    elif [[ "$DISK" == /dev/vd* ]]
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
    pacstrap -K /mnt base linux linux-firmware intel-ucode efibootmgr grub man-db man-pages texinfo vi vim eza networkmanager ntp bat alacritty kitty sudo fastfetch ufw lvm2
elif [ "$cpu_vendor" = "AMD" ]
then
    pacstrap -K /mnt base linux linux-firmware amd-ucode grub efibootmgr man-db man-pages texinfo vi vim eza networkmanager ntp bat alacritty kitty sudo fastfetch ufw lvm2
elif [ "$cpu_vendor" = "virtualMachine" ]
then
    pacstrap -K /mnt base linux linux-firmware grub efibootmgr man-db man-pages texinfo vi vim eza networkmanager ntp bat alacritty kitty sudo fastfetch ufw lvm2
fi


genfstab -U /mnt >> /mnt/etc/fstab
cp /root/ArchLinuxInstaller/chrootPart.sh /mnt/chrootPart.sh
arch-chroot /mnt /chrootPart.sh "$DISK" "$encryptFlag"

#Setting up lusk partition for booting up
partitionLuskID=$(blkid | awk -F'"' 'NR == 3 { print $2 }') #Same as before
partitionHardwareID=$(blkid | awk -F'"' 'NR == 4 { print $2 }') #These lines assumes that always the second drive is encrypted

echo "Checking partition variables: "
echo "$partitionHardwareID"
echo "$partitionLuskID"

#sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/\(\".*\"\)/\1 cryptdevices=UUID=$partitionLuskID:cryptlvm root=UUID=$partitionHardwareID/" /mnt/etc/default/grub
#sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/\(\".*\"\)/\1 cryptdevices=UUID=$partitionLuskID:cryptlvm root=UUID=$partitionHardwareID/" /mnt/etc/default/grub
sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/\"$/ cryptdevice=UUID=$partitionHardwareID:cryptlvm root=UUID=$partitionLuskID\"/" /mnt/etc/default/grub
#sed -i "/^HOOKS=/ s/\(([^)]*)\)/(\1 encrypt lvm2)/" /mnt/etc/mkinitcpio.conf Delete this in the future.
sed -i "/^HOOKS=/ s/\([^)]*\)/\1 encrypt lvm2/" /mnt/etc/mkinitcpio.conf

cp /root/ArchLinuxInstaller/endingSetup.sh /mnt/endingSetup.sh

echo "Checking variables before chrooting: "
echo "DISK: $DISK"
echo "BiosOrUefi: $BiosOrUefi"
sleep 10
arch-chroot /mnt /endingSetup.sh "$DISK" "$BiosOrUefi"

umount -R /mnt

echo "#####################################################"
echo "#                 CONGRATULATIONS!                  #"
echo "#####################################################"
echo " "
echo " "
echo "You arch linux installation is completed, just write reboot to reboot the system and start using it!"
echo "by the way, you have alacritty and kitty by default terminals"
echo "please use visudo to uncomment the wheel group if you want your user to have sudo privilege"

if [ "$encryptFlag" == "yes" ]
then
    mount /dev/mapper/rootDrive /mnt
    mount /dev/vda1 /mnt/boot
    echo "PLEASE READ THIS!!!"
    echo "You have installed the encrypt root partition. But you don't have grub, you will need to install it with the propper UUID to boot properly."
    echo "To do that make this:"
    echo "1) check if your drives are mounted with lsblk"
    echo "2) blkid >> /etc/default/grub"
    echo "3) Chroot with arch-chroot /mnt"
    echo "4) Select  the UUID of the for crypto_LUKS in the bottom of /etc/default/grub and decrypted drive UUID"
    echo "5) In GRUB_CMDLINE_LINUX_DEFAULT add cryptdevice=UUID=<yourUUID>:cryptlvm root=UUID=<UUIDofDecryptedPartition>"
    echo "6) In /etc/mkinitcpio.conf add in the HOOKS line: encrypt lvm2"
    echo "7) run mkinitcpio -P "
    echo "8) Install grub like grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB  or for bios systems: grub-install ""$DISK"" "
    echo "9) finally grub-mkconfig -o /boot/grub/grub.cfg"
    echo "Then exit and reboot"
fi
