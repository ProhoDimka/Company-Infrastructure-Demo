#!/usr/bin/bash

#set -e

# Restore
sudo gitlab-ctl stop puma 2>&1 | systemd-cat -t "gitlab-restore"
sudo gitlab-ctl stop sidekiq 2>&1 | systemd-cat -t "gitlab-restore"

sleep 5
# Verify
sudo gitlab-ctl status 2>&1 | systemd-cat -t "gitlab-restore"
sudo gitlab-backup \
    restore \
    force=yes \
    BACKUP="$(sudo ls -lat /mnt/gitlab_data/gitlab_backups | awk '/tar/{ print $9 }' | head -n1 | sed 's/_gitlab_backup.tar//g')" 2>&1 \
    | systemd-cat -t "gitlab-restore"
sudo gitlab-ctl restart 2>&1 | systemd-cat -t "gitlab-restore"

exit 0
