# nixos-install

My personal NixOS install script using LVM and btrfs.

Meant for cloud servers that are mainly hosting podman.

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
nix-env -iA nixos.git nixos.perl
git clone https://github.com/leomeinel/nixos-install.git
vim /root/nixos-install/install.conf # Replace IPV6_ADDRESS
chmod +x /root/nixos-install/setup.sh
/root/nixos-install/setup.sh
reboot
```

:information_source: | Use `<...>.sh |& tee <logfile>.log` to create a log file.

:information_source: | Configure installation using `vim /root/nixos-install/install.conf`.

:information_source: | You can also change your system config in any `.nix` files.

## Post-installation (tty)

:information_source: | Set new passwords for every user via:

```sh
doas passwd $USERNAME
```
