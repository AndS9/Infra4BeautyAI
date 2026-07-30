#!/bin/bash
set -e
# Running script only with root
# Mount disk
LUN=10

DEVICE=$(readlink -f /dev/disk/azure/scsi1/lun$LUN)
parted $DEVICE --script mklabel gpt
parted $DEVICE --script mkpart primary ext4 0% 100%
partprobe $DEVICE

TARGET_DISK="${DEVICE}1"
MOUNT_POINT="/mnt/dbstorage"
FSTYPE="ext4"
mkfs.$FSTYPE $TARGET_DISK
mkdir -p $MOUNT_POINT
mount $TARGET_DISK $MOUNT_POINT

UUID=$(blkid -o value -s UUID "$TARGET_DISK")
echo "UUID=$UUID $MOUNT_POINT $FSTYPE defaults 0 2" >> /etc/fstab