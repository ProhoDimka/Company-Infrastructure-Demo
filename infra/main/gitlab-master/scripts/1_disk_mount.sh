#!/usr/bin/bash

#set -e

export GITLAB_MOUNT_VOLUME=$1
export GITLAB_MOUNT_VOLUME_SIZE=$2
export GITLAB_MOUNT_PATH=$3

# Check if volume filesystem has already created
GITLAB_VOLUME_CREATED=$(lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,UUID | grep "${GITLAB_MOUNT_VOLUME}.*${GITLAB_MOUNT_VOLUME_SIZE}" | awk '{print $2}')
GITLAB_MOUNT_VOLUME_NAME=$(lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,UUID | grep "${GITLAB_MOUNT_VOLUME}.*${GITLAB_MOUNT_VOLUME_SIZE}" | awk '{print $1}')
if [ "${GITLAB_VOLUME_CREATED}" == 'ext4' ]; then
  echo "Filesystem for gitlab data volume already created"
else
  sudo mkfs.ext4 "/dev/${GITLAB_MOUNT_VOLUME_NAME}"
  echo "Filesystem for gitlab data volume was created"
  lsblk -o NAME,FSTYPE,MOUNTPOINT,UUID
fi
# Sleep because UUID is creating in progress
sleep 5
lsblk -o NAME,FSTYPE,MOUNTPOINT,UUID

# Get UID
GITLAB_DATA_VOLUME_UID=$(lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,UUID | grep "${GITLAB_MOUNT_VOLUME}.*${GITLAB_MOUNT_VOLUME_SIZE}" | awk '{print $4}')
if [ -z "${GITLAB_DATA_VOLUME_UID}" ]; then
  echo "UID wasn't found"
  exit 1
fi

# Check if volume already in /etc/fstab and mount if doesn't exist
IS_UID_IN_FSTAB=$(sudo cat /etc/fstab | grep "${GITLAB_DATA_VOLUME_UID}")
if [ -z "${IS_UID_IN_FSTAB}" ]; then
  sudo mkdir -p "${GITLAB_MOUNT_PATH}"
  sudo mount "/dev/${GITLAB_MOUNT_VOLUME_NAME}" "${GITLAB_MOUNT_PATH}" || exit 1
  echo "UUID=${GITLAB_DATA_VOLUME_UID}	${GITLAB_MOUNT_PATH}	ext4	defaults	0 0" | sudo tee -a /etc/fstab
  echo "UUID=${GITLAB_DATA_VOLUME_UID} was mounted to ${GITLAB_MOUNT_PATH}"
fi

exit 0