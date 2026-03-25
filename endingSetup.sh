#!/bin/bash

#This script only get activated when user selected to encrypt device,
#so this last part is needed to get inside with chroot /mnt again and for
# that this script is for, to update mkinitcpio and grub with
# the latestest changes made without loosing root permission from the first script
# during the whole installation process.

DISK="$1"
BiosOrUefi="$2"


pacman -S cryptsetup --noconfirm


mkinitcpio -P

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

exit
