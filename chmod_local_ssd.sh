#!/bin/bash

# Get the directory of the current script
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for i in $(seq 0 3); do
	MOUNT_POINT=${INSTALL_DIR}/local_ssd_mnt_${i}
	chmod 777 ${MOUNT_POINT}
done
