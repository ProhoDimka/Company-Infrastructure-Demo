#!/usr/bin/bash

#set -e

# Back up commands
# sudo gitlab-backup create --trace
# sudo gitlab-ctl backup-etc --trace

echo "Starting Gitlab repos backup..." | systemd-cat -t "gitlab-backup"
sudo gitlab-backup create --trace | systemd-cat -t "gitlab-backup"
sudo gitlab-ctl backup-etc | systemd-cat -t "gitlab-backup-etc"

exit 0
