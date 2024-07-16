#!/usr/bin/bash

#set -e

# Back up commands
# sudo gitlab-backup create --trace
# sudo gitlab-ctl backup-etc --trace

# Restore
# sudo gitlab-ctl stop puma
# sudo gitlab-ctl stop sidekiq
## Verify
# sudo gitlab-ctl status
# sudo gitlab-backup restore
# sudo gitlab-ctl restart

LINES_CRON_CONF=$(sudo grep "^[^#]" /etc/crontab  | grep gitlab_backup_script | wc -l)

if [ "${LINES_CRON_CONF}" == "0" ]; then
  echo "30 1	* * *	root    /home/ubuntu/gitlab_backup_script.sh" | sudo tee -a /etc/crontab
  sudo systemctl restart cron
  echo "Cron configured for Gitlab backup."
fi

sudo mkdir -p /mnt/gitlab_data/gitlab_backups >> /dev/null 2>&1

exit 0
