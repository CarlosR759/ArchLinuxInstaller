<div align="center">
	<a href="https://archlinux.org/"><img alt="Arch" src="https://upload.wikimedia.org/wikipedia/commons/f/f9/Archlinux-logo-standard-version.svg" width="260" height="120"></a>
</div>

<h2 align="center">
	ArchLinuxInstaller 


</h2>

<p align="center">
	My custom arch linux installation that includes window manager if you want!
</p>

## Prerequisites

Arch linux iso running in your computer and a clean drive to work with it. That's all
Also please read all this readme file first before doing something ^^ ! 

## Features

- Detects if your system is BIOS or UEFI by itself, then make grub installation with spec in mind.
- Create two partitions, one for boot and the rest for the system. It doesn't add swap partition.
- Parallel downloads enabled by default for pacman.
- Install some nice programs like lf, mostly terminal base for common ussage, no browser is installed by default.
- It does have alacritty and kitty for default terminals.
- You can create user account with or without sudo ussage or just use the root account.
- You can install my complete dwm rice if you want to use Xorg WM, with all my dotfiles bashrc and wallpapers automatically, or just live in TTY. If you don't know my rice check it out here: https://github.com/CarlosR759/dwm-rice
- You can install Hyprland for Wayland WM, it does adds my conf files from https://github.com/CarlosR759/HyprConfs 
- Custom dwmblocks system bar for DWM.
- Custom eww self made system bar for Hyprland.
- Desktops available for installation: KDE, Gnome, Cosmic, Xfc and Mate.
- NTP service enabled by default.
- Firewall ufw enabled by default with all incoming traffic denied and all outgoing open.
- Window managers with Vim keybindings to move windows.
- Install Linux LTS.
- And all the stuff needed for a basic Arch Linux installation!

## Usage

This scripts demands to have your SDD or HDD without any created partitions, so you will need to erase them. So after booting the arch iso you will need to do that if you are using an used drive or something new but that comes with an preinstalled OS. 

To do that for SSD is a little bit tricky, because SSD have different commands to do it, ones with format and some others with sanitize.
Also SATA SSD have another way to do it.

If you want to be lazzy, most probably if you have a normal grade SSD NVME drive, then one of the following commands will work: 

```
nvme format /dev/nvme0 -s 1 -n 0xffffffff
```

```
nvme format /dev/nvme0 -s 2 -n 0xffffffff
```

But I highly recomend to check this first: https://wiki.archlinux.org/title/Solid_state_drive/Memory_cell_clearing#NVMe_drive and understand what you are doing in the commands, also you if by some reason SSD NVME only supports sanitize then you will need to read the part for that: https://wiki.archlinux.org/title/Solid_state_drive/Memory_cell_clearing#Sanitize_command


For SSD SATA based drives, you can know how to erase the partitions reading this: https://wiki.archlinux.org/title/Securely_wipe_disk#hdparm

But also you can use 

```
fdisk /dev/yourDriveYouWantToDelete
```

and press d and delete the partitions, then after deleting probably the both partitions, press w to write and quit.

> [!IMPORTANT]
> - Deleting with the fdisk methods works for all devices, is probably the most easy way to go no matter if you are using SSD SATA, SSD NVME or HDD. Because in practice you are just destroying the partitions inside the drive. The other methods assure that complete deletion of all remaning data occours, fdisk one doesn't. So in tldr: Just pick your poison and carry on.


For HDD you can use the fdisk approach but if you want to delete everything you just can go with: 

```
dd if=/dev/zero of=/dev/sdX bs=4096 status=progress
```

More info about HDD over here also: https://wiki.archlinux.org/title/Securely_wipe_disk#dd

After deleting the partions you can do 

```
sync
```

To update the current state of drives into your Arch Linux iso, and check it with 

```
lsblk
```

To see if there are deleted.

> [!NOTE]
> - If by some reason you still see that after lsblk the partition still exists, you could just reboot the system and check again if those exists. Some times it does happens that the iso booting doesn't catch the info, more if you don't do the sync command, but in practice you can just go and launch the script without rebooting the system. But if you want to be sure 100% and want to avoid any bugs, just reboot.

### Using the script

After launching Arch iso and have access to shell, you will need to update the repos database and install git

```sh
pacman -Sy && pacman -S git --noconfirm
```

After that you can clone this repo with:

```sh
git clone https://github.com/CarlosR759/ArchLinuxInstaller && cd ArchLinuxInstaller
```

Change the script to be able to execute:

```sh
chmod 700 archInstaller.sh chrootPart.sh endingSetup.sh
```

and run the main script:

```sh
./archInstaller.sh
```

And enjoy your new Arch machine after rebooting ^^


> [!TIP]
> - By default you can launch terminals with <kbd>Super/Windows</kbd> + <kbd>Enter</kbd> in both DWM and Hyprland. The default terminal is Alacritty, but if you want to add another one like Ghostty you can, but you will need to change the config files of Hyprland and change config.h in DWM and compile it again, so you can add another terminal with another keybinding or replacing the current one with another similar program.
> - You can kill your dwm session with <kbd>Super/Windows</kbd> + <kbd>Shift</kbd> + <kbd>Q</kbd>
> - For keybindings changes made it in config.h in DWM.
> - For keybindings changes made it in ~/.config/hypr/hyprland.conf for Hyprland.


> [!IMPORTANT]
> - If you launch hyprland by virtual machine, most probably hyprpaper is not going to work, because it needs hardware accelration through gpu in order to work. In should consider to add a pci passthrough of gpu if you can. 

> [!IMPORTANT]
> - If you need to change the timezone because you don't live where I live, then you need to go first into chrootPart.ch into line 22 and change the path of /usr/share/zoneinfo/ and append the appropiate one for yourself.


## FAQ

#### Can i just install one desktop or window manager ?

<details>
  <summary></summary>
      Yes you can. The script is made in mind so you can install and choose any option you want, usage of window managers or desktops are not mandatory.
</details>


#### Can i just live in a TTY terminal ? 

<details>
  <summary></summary>
      Yes, you can live just in a terminal. You just need to write no in any question that ask for WM/Desktop installation.
</details>


#### I found an issue in the script. Can i send it back so it can be fixed ?

<details>
  <summary></summary>

  Yes, I only need a description to make the bug reproducible if you found something. Just send the problem into issues and with an explanation on how to make it reproducible the error. For that you must try more than once the installation, so I can be sure that it wasn't an ISO environment initialization error, which sometimes can happen. So always try it twice, to confirm that it's a reproducible bug and not also an ISO init issue.

  You can also try to make a pull request if you want, but please do not add new software to the Arch Installation, this script tries to be minimal as possible, so it can end in a point from which the users can choose how to continue modifying their machines.
</details>
