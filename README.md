# nixos-install

My personal NixOS install script using LVM and btrfs.

Meant for aarch64-linux Hetzner Cloud servers that are mainly hosting docker.

## Info

:information_source: | Expect errors to occur during the installation. They only matter if any of the scripts don't finish successfully.

:information_source: | I recommend disks with at least 32GB (change $DISK_ALLOCATION in install.conf otherwise).

:warning: | All data on selected disks will be wiped!

:exclamation: | Follow [these instructions](https://github.com/leomeinel/nixos-install/blob/server/virt-manager.md) for virt-manager.

## Pre-installation

:information_source: | Follow the `Installation` section of this [guide](https://nixos.org/manual/nixos/stable/#sec-installation-manual) until (including) the [`Networking in the installer`](https://nixos.org/manual/nixos/stable/#sec-installation-manual-networking) section. Use the `Minimal ISO image`.

## Installation

```sh
sudo -i
nix-env -iA nixos.git
git clone https://github.com/leomeinel/nixos-install.git
chmod +x /root/nixos-install/prepare.sh
/root/nixos-install/prepare.sh
nixos-install --no-root-password --flake /root/nixos-install/#red
umount -AR /mnt
reboot
```

:information_source: | Use `<...>.sh |& tee <logfile>.log` to create a log file.

:information_source: | Configure installation using `vim /root/nixos-install/install.conf`.

:information_source: | Configure NixOS using `vim /root/nixos-install/flake.nix` `vim /root/nixos-install/nixos/configuration.nix` `vim /root/nixos-install/nixos/hardware-configuration.nix`.
