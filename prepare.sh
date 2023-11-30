#!/usr/bin/env bash
###
# File: prepare.sh
# Author: Leopold Meinel (leo@meinel.dev)
# -----
# Copyright (c) 2023 Leopold Meinel & contributors
# SPDX ID: GPL-3.0-or-later
# URL: https://www.gnu.org/licenses/gpl-3.0-standalone.html
# -----
###

# Source config
SCRIPT_DIR="$(dirname -- "$(readlink -f -- "$0")")"
source "$SCRIPT_DIR/install.conf"

# Fail on error
set -e

# Define functions
sed_exit() {
    echo "ERROR: 'sed' didn't replace, report this @"
    echo "       https://github.com/leomeinel/arch-install/issues"
    exit 1
}

# Unmount everything from /mnt
mountpoint -q /mnt &&
    umount -AR /mnt

# Prompt user for RAID
read -rp "Set up RAID? (Type 'yes' in capital letters): " choice
case "$choice" in
YES)
    ## Detect disks
    readarray -t DISKS < <(lsblk -drnpo NAME -I 259,8,254 | tr -d "[:blank:]")
    DISKS_LENGTH="${#DISKS[@]}"
    for ((i = 0; i < DISKS_LENGTH; i++)); do
        udevadm info -q property --property=ID_BUS --value "${DISKS[$i]}" | grep -q "usb" &&
            {
                unset 'DISKS[$i]'
                continue
            }
        DISKS=("${DISKS[@]}")
    done
    [[ "${#DISKS[@]}" -lt 2 ]] &&
        {
            echo "ERROR: There are less than 2 disks attached!"
            exit 1
        }
    [[ "${#DISKS[@]}" -gt 2 ]] &&
        {
            echo "WARNING: There are more than 2 disks attached!"
            lsblk -drnpo SIZE,NAME,MODEL,LABEL -I 259,8,254
            ### Prompt user to select 2 RAID members
            read -rp "Which disk should be the first RAID member? (Type '/dev/sdX' fex.): " choice0
            read -rp "Which disk should be the second RAID member? (Type '/dev/sdY' fex.): " choice1
            if [[ "$(tr -d "[:space:]" <<<"$choice0")" != "$(tr -d "[:space:]" <<<"$choice1")" ]] && lsblk -drnpo SIZE,NAME,MODEL,LABEL -I 259,8,254 "$choice0" "$choice1"; then
                echo "Using $choice0 and $choice1 for installation."
                DISKS=("$choice0" "$choice1")
            else
                echo "ERROR: Drives not suitable for installation!"
                exit 1
            fi
        }
    ## Set size for partition of larger disk
    SIZE1="$(lsblk -drnbo SIZE "${DISKS[0]}" | tr -d "[:space:]")"
    SIZE2="$(lsblk -drnbo SIZE "${DISKS[1]}" | tr -d "[:space:]")"
    if [[ "$SIZE1" -eq "$SIZE2" ]]; then
        DISK1="${DISKS[0]}"
        DISK2="${DISKS[1]}"
        PART_SIZE=0
    else
        echo "WARNING: The attached disks don't have the same size!"
        echo "         The larger disk will have unpartitioned space remaining."
        if [[ "$SIZE1" -gt "$SIZE2" ]]; then
            DISK1="${DISKS[0]}"
            DISK2="${DISKS[1]}"
            PART_SIZE="$((-(("$SIZE1" - "$SIZE2") / 1024)))K"
        else
            DISK1="${DISKS[1]}"
            DISK2="${DISKS[0]}"
            PART_SIZE="$((-(("$SIZE2" - "$SIZE1") / 1024)))K"
        fi
    fi
    ## Prompt user to confirm erasure
    read -rp "Erase $DISK1 and $DISK2? (Type 'yes' in capital letters): " choice
    case "$choice" in
    YES)
        echo "Erasing $DISK1 and $DISK2..."
        ;;
    *)
        echo "ERROR: User aborted erasing ${DISK1} and ${DISK2}!"
        exit 1
        ;;
    esac
    ## Detect & erase old raid1 volumes
    if lsblk -rno TYPE | grep -q "raid1"; then
        OLD_DISK1P2="$(lsblk -rnpo TYPE,NAME "$DISK1" | grep "part" | sed 's/part//' | sed -n '2p' | tr -d "[:space:]")"
        OLD_DISK2P2="$(lsblk -rnpo TYPE,NAME "$DISK2" | grep "part" | sed 's/part//' | sed -n '2p' | tr -d "[:space:]")"
        OLD_RAID_0="$(lsblk -Mrnpo TYPE,NAME | grep "raid1" | sed 's/raid1//' | sed -n '1p' | tr -d "[:space:]")"
        sgdisk -Z "$OLD_RAID_0"
        mdadm --stop "$OLD_RAID_0"
        mdadm --zero-superblock "$OLD_DISK1P2"
        mdadm --zero-superblock "$OLD_DISK2P2"
    fi
    ;;
*)
    ## Prompt user for disk
    ## NOTE: USB will be valid to allow external SSDs
    lsblk -drnpo SIZE,NAME,MODEL,LABEL -I 259,8,254
    read -rp "Which disk do you want to erase? (Type '/dev/sdX' fex.): " choice
    if lsblk -drnpo SIZE,NAME,MODEL,LABEL -I 259,8,254 "$choice"; then
        echo "Erasing $choice..."
        DISK1="$choice"
    else
        echo "ERROR: Drive not suitable for installation!"
        exit 1
    fi
    ## Deactivate all vgs
    vgchange -an
    ## Detect, close & erase old volumes
    OLD_DISK1P2="$(lsblk -rnpo TYPE,NAME "$DISK1" | grep "part" | sed 's/part//' | sed -n '2p' | tr -d "[:space:]")"
    sgdisk -Z "$OLD_DISK1P2"
    ;;
esac

# Load $KEYMAP
loadkeys "$KEYMAP"

# Erase & partition disks
sgdisk -Z "$DISK1"
sgdisk -n 0:0:+1G -t 1:ef00 "$DISK1"
if [[ -n "$DISK2" ]]; then
    sgdisk -n 0:0:"$PART_SIZE" -t 2:fd00 "$DISK1"
    sgdisk -Z "$DISK2"
    sgdisk -n 0:0:+1G -t 1:ef00 "$DISK2"
    sgdisk -n 0:0:0 -t 2:fd00 "$DISK2"
else
    sgdisk -n 0:0:0 -t 2:8300 "$DISK1"
fi

# Configure raid
DISK1P1="$(lsblk -rnpo TYPE,NAME "$DISK1" | grep "part" | sed 's/part//' | sed -n '1p' | tr -d "[:space:]")"
DISK1P2="$(lsblk -rnpo TYPE,NAME "$DISK1" | grep "part" | sed 's/part//' | sed -n '2p' | tr -d "[:space:]")"
if [[ -n "$DISK2" ]]; then
    DISK2P1="$(lsblk -rnpo TYPE,NAME "$DISK2" | grep "part" | sed 's/part//' | sed -n '1p' | tr -d "[:space:]")"
    DISK2P2="$(lsblk -rnpo TYPE,NAME "$DISK2" | grep "part" | sed 's/part//' | sed -n '2p' | tr -d "[:space:]")"
    ## Configure raid1
    mdadm --create --verbose --level=1 --metadata=1.2 --raid-devices=2 --homehost=any --name=md0 /dev/md/md0 "$DISK1P2" "$DISK2P2"
    ## Configure lvm
    cryptsetup open --type plain -d /dev/urandom /dev/md/md0 to_be_wiped
    cryptsetup close to_be_wiped
    pvcreate /dev/md/md0
    vgcreate vg0 /dev/md/md0
else
    ## Configure lvm
    cryptsetup open --type plain -d /dev/urandom "$DISK1P2" to_be_wiped
    cryptsetup close to_be_wiped
    pvcreate "$DISK1P2"
    vgcreate vg0 "$DISK1P2"
fi

# Configure lvm
lvcreate -l "${DISK_ALLOCATION[0]}" vg0 -n lv0
lvcreate -l "${DISK_ALLOCATION[1]}" vg0 -n lv1
lvcreate -l "${DISK_ALLOCATION[2]}" vg0 -n lv2
lvcreate -l "${DISK_ALLOCATION[3]}" vg0 -n lv3

# Format efi
mkfs.fat -n EFI -F32 "$DISK1P1"
[[ -n "$DISK2" ]] &&
    mkfs.fat -n EFI -F32 "$DISK2P1"

# Configure mounts
## Create subvolumes
SUBVOLUMES_LENGTH="${#SUBVOLUMES[@]}"
[[ "$SUBVOLUMES_LENGTH" -ne "${#CONFIGS[@]}" ]] &&
    {
        echo "ERROR: SUBVOLUMES and CONFIGS aren't the same length!"
        exit 1
    }
create_subs0() {
    mkfs.btrfs -L "$3" "$4"
    mount "$4" /mnt
    btrfs subvolume create "/mnt/@$2"
    btrfs subvolume create "/mnt/@${2}_snapshots"
    create_subs1 "$1"
    umount /mnt
}
create_subs1() {
    for ((a = 0; a < SUBVOLUMES_LENGTH; a++)); do
        if [[ "${SUBVOLUMES[$a]}" != "$1" ]] && grep -nq "^$1" <<<"${SUBVOLUMES[$a]}"; then
            btrfs subvolume create "/mnt/@${CONFIGS[$a]}"
            btrfs subvolume create "/mnt/@${CONFIGS[$a]}_snapshots"
        fi
    done
}
for ((i = 0; i < SUBVOLUMES_LENGTH; i++)); do
    case "${SUBVOLUMES[$i]}" in
    "/")
        mkfs.btrfs -L ROOT /dev/mapper/vg0-lv0
        mount /dev/mapper/vg0-lv0 /mnt
        btrfs subvolume create /mnt/@
        btrfs subvolume create /mnt/@snapshots
        umount /mnt
        ;;
    "/nix/")
        create_subs0 "${SUBVOLUMES[$i]}" "${CONFIGS[$i]}" "NIX" "/dev/mapper/vg0-lv1"
        ;;
    "/var/")
        create_subs0 "${SUBVOLUMES[$i]}" "${CONFIGS[$i]}" "VAR" "/dev/mapper/vg0-lv2"
        ;;
    "/home/")
        create_subs0 "${SUBVOLUMES[$i]}" "${CONFIGS[$i]}" "HOME" "/dev/mapper/vg0-lv3"
        ;;
    esac
done
## Mount subvolumes
OPTIONS0="noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=/@"
OPTIONS1="nodev,noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=/@"
OPTIONS2="nodev,nosuid,noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=/@"
OPTIONS3="noexec,nodev,nosuid,noatime,space_cache=v2,compress=zstd,ssd,discard=async,subvol=/@"
mount_subs0() {
    mount --mkdir -o "$3$2" "$4" "/mnt$1"
    mount --mkdir -o "$OPTIONS3${2}_snapshots" "$4" "/mnt$1.snapshots"
    mount_subs1 "$1" "$3" "$4"
}
mount_subs1() {
    for ((a = 0; a < SUBVOLUMES_LENGTH; a++)); do
        if [[ "${SUBVOLUMES[$a]}" != "$1" ]] && grep -nq "^$1" <<<"${SUBVOLUMES[$a]}"; then
            if grep -nq "^${1}lib/" <<<"${SUBVOLUMES[$a]}" && ! grep -nq "^${1}lib/flatpak/" <<<"${SUBVOLUMES[$a]}"; then
                mount --mkdir -o "$OPTIONS3${CONFIGS[$a]}" "$3" "/mnt${SUBVOLUMES[$a]}"
            else
                mount --mkdir -o "$2${CONFIGS[$a]}" "$3" "/mnt${SUBVOLUMES[$a]}"
            fi
            mount --mkdir -o "$OPTIONS3${CONFIGS[$a]}_snapshots" "$3" "/mnt${SUBVOLUMES[$a]}.snapshots"
        fi
    done
}
for ((i = 0; i < SUBVOLUMES_LENGTH; i++)); do
    case "${SUBVOLUMES[$i]}" in
    "/")
        mount -o "$OPTIONS0" /dev/mapper/vg0-lv0 "/mnt${SUBVOLUMES[$i]}"
        mount --mkdir -o "${OPTIONS3}snapshots" /dev/mapper/vg0-lv0 "/mnt${SUBVOLUMES[$i]}.snapshots"
        ;;
    "/nix/")
        mount_subs0 "${SUBVOLUMES[$i]}" "${CONFIGS[$i]}" "$OPTIONS1" "/dev/mapper/vg0-lv1"
        ;;
    "/var/")
        mount_subs0 "${SUBVOLUMES[$i]}" "${CONFIGS[$i]}" "$OPTIONS2" "/dev/mapper/vg0-lv2"
        ;;
    "/home/")
        mount_subs0 "${SUBVOLUMES[$i]}" "${CONFIGS[$i]}" "$OPTIONS2" "/dev/mapper/vg0-lv3"
        ;;
    esac
done
chmod 775 /mnt/var/games
## /efi
mount --mkdir -o noexec,nodev,nosuid,noatime,fmask=0077,dmask=0077 "$DISK1P1" /mnt/efi
[[ -n "$DISK2" ]] &&
    mount --mkdir -o noexec,nodev,nosuid,noatime,fmask=0077,dmask=0077 "$DISK2P1" /mnt/.efi.bak
## /boot
mkdir -p /mnt/boot