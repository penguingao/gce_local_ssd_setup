#!/bin/bash

# Get the directory of the current script
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for i in $(seq 0 3); do
	MOUNT_POINT=${INSTALL_DIR}/local_ssd_mnt_${i}
	RETRY_COUNT=1
	while [ ${RETRY_COUNT} -le 60 ]
	do
		mountpoint -q ${MOUNT_POINT} && chmod 777 ${MOUNT_POINT}
		if [ $? -ne 0 ]; then
			echo "${MOUNT_POINT} is not a mount point. Current retry count: ${RETRY_COUNT}"
			sleep 1
			((RETRY_COUNT++))
		else
			break
		fi
	done
done
