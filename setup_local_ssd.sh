#!/bin/bash

SSD_PATH_PREFIX="/dev/disk/by-id/google-local-nvme-ssd-"
for i in $(seq 0 3); do
	SSD=${SSD_PATH_PREFIX}${i}
	fsck -y -M ${SSD} || mkfs.ext4 ${SSD}
done
