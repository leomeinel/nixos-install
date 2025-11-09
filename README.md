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

## Notes

### auditd

The rules in `/nixos/configs/security.nix` are modified but achieve similar results to this on a non-nix system:

```sh
ln -sf /usr/share/audit-rules/10-base-config.rules /etc/audit/rules.d/
ln -sf /usr/share/audit-rules/11-loginuid.rules /etc/audit/rules.d/
ln -sf /usr/share/audit-rules/12-ignore-error.rules /etc/audit/rules.d/
ln -sf /usr/share/audit-rules/21-no32bit.rules /etc/audit/rules.d/
ln -sf /usr/share/audit-rules/23-ignore-filesystems.rules /etc/audit/rules.d/
ln -sf /usr/share/audit-rules/30-ospp-v42-1-create-failed.rules /etc/audit/rules.d/
ln -sf /usr/share/audit-rules/30-ospp-v42-2-modify-failed.rules /etc/audit/rules.d/
ln -sf /usr/share/audit-rules/30-ospp-v42-3-access-failed.rules /etc/audit/rules.d/
ln -sf /usr/share/audit-rules/30-ospp-v42-4-delete-failed.rules /etc/audit/rules.d/
ln -sf /usr/share/audit-rules/30-ospp-v42-5-perm-change-failed.rules /etc/audit/rules.d/
ln -sf /usr/share/audit-rules/30-ospp-v42-6-owner-change-failed.rules /etc/audit/rules.d/
ln -sf /usr/share/audit-rules/30-ospp-v42.rules /etc/audit/rules.d/
ln -sf /usr/share/audit-rules/32-power-abuse.rules /etc/audit/rules.d/
ln -sf /usr/share/audit-rules/41-containers.rules /etc/audit/rules.d/
ln -sf /usr/share/audit-rules/42-injection.rules /etc/audit/rules.d/
ln -sf /usr/share/audit-rules/43-module-load.rules /etc/audit/rules.d/
ln -sf /usr/share/audit-rules/44-installers.rules /etc/audit/rules.d/
# Also included are: https://github.com/leomeinel/arch-install/tree/main/etc/audit/rules.d
# See: https://github.com/leomeinel/arch-install/blob/main/setup.sh#L445
FILE=/etc/audit/rules.d/31-arch-install-privileged.rules
{
    find "$(readlink -f /run/wrappers/bin)" -type f -perm -04000 2>/dev/null | awk '{ printf "-a always,exit -F arch=b64 -F path=%s -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged\n", $1 }' | sed "s|/run/wrappers/wrappers\.[^/]*/|/run/wrappers/bin|"
    filecap "$(readlink -f /run/wrappers/bin)" 2>/dev/null | sed '1d' | awk '{ printf "-a always,exit -F arch=b64 -F path=%s -F perm=x -F auid>=1000 -F auid!=unset -F key=privileged\n", $2 }' | sed "s|/run/wrappers/wrappers\.[^/]*/|/run/wrappers/bin|"
} | sort -u >"${FILE}"
```
