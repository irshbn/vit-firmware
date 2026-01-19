#!/usr/bin/env bash
set -e

PART=$(blkid -t LABEL=home -o device)
DISK="${PART%%p[0-9]*}"
PARTNUM="${PART##*[!0-9]}"
echo "Resizing $PART..."

# Resize the partition
# This uses parted to resize the partition to the maximum size
parted $DISK --script resizepart $PARTNUM 100%

# Re-read partition table
partprobe $DISK
# Resize the filesystem
e2fsck -y -f "$PART"
resize2fs "$PART"

# Disable service so it doesn’t run again
systemctl disable grow-home.service
echo "Resize complete."
