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


## Features

- Detects if your system is BIOS or UEFI by itself, then make grub installation with spec in mind.
- Create two partitions, one for boot and the rest for the system. It doesn't have swap partition.
- Parallel downloads enabled by default.
- Install some nice programs like lf, mostly terminal base for common ussage, no browser is installed by default.
- It does have alacritty and kitty for default terminals.
- You can create user account with or without sudo ussage or just use the root account.
- You can install my complete dwm rice if you want, with all my dotfiles bashrc and wallpapers automatically, or just live in TTY. If you don't know my rice check it out here: https://github.com/CarlosR759/dwm-rice
- NTP service enabled by default.
- Firewall ufw enabled by default but without policy applied.
- Install Linux LTS.
- And all the stuff needed for a basic Arch Linux installation!

## Usage

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
chmod 700 archInstaller.sh chrootPart.sh
```

and run the main script:

```sh
./archInstaller.sh
```

