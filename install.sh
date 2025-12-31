#!/bin/bash

# Get the directory of the current script
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define absolute paths
CHMOD_SCRIPT_PATH="${INSTALL_DIR}/chmod_local_ssd.sh"
SETUP_SCRIPT_PATH="${INSTALL_DIR}/setup_local_ssd.sh"

echo "INSTALL_DIR: $INSTALL_DIR"
echo "CHMOD_SCRIPT_PATH: $CHMOD_SCRIPT_PATH"
echo "SETUP_SCRIPT_PATH: $SETUP_SCRIPT_PATH"

# Create systemd service
SYSTEMD_EDITOR=tee systemctl edit --force --full setup_local_ssd.service <<EOF
[Unit]
Description=Create filesystem for Google Cloud local SSD
After=-.mount

[Service]
Type=oneshot
ExecStart=${SETUP_SCRIPT_PATH}
User=root
Restart=on-failure
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF

# Create chmod_local_ssd service
SYSTEMD_EDITOR=tee systemctl edit --force --full chmod_local_ssd.service <<EOF
[Unit]
Description=Make Local SSDs accessible by all users
Requires=local-fs.target
After=local-fs.target

[Service]
Type=oneshot
ExecStart=$CHMOD_SCRIPT_PATH
User=root
Restart=on-failure
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF


# Configure /etc/fstab
SSD_PATH_PREFIX="/dev/disk/by-id/google-local-nvme-ssd-"

for i in $(seq 0 3); do
  SSD_DEVICE="${SSD_PATH_PREFIX}${i}"
  MOUNT_POINT="${INSTALL_DIR}/local_ssd_mnt_${i}"
  mkdir ${MOUNT_POINT}

  if ! grep -qs "${SSD_DEVICE}" /etc/fstab; then
    echo "${SSD_DEVICE} ${MOUNT_POINT} ext4 defaults,x-systemd.wants=setup_local_ssd.service 0 1" | tee -a /etc/fstab
  fi
done

