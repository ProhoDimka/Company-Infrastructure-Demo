#!/usr/bin/bash

#set -e

if [ "$(sudo systemctl status gitlab-runner.service 2>&1 | grep active | wc -l)" == "1" ]; then
  exit 0
fi

DEPLOY_ARCH_TYPE="$(dpkg --print-architecture)"
# Version from https://gitlab.com/gitlab-org/gitlab-runner/-/tags
RUNNER_VERSION="v16.11.2"
#RUNNER_JOIN_TOKEN="${1}"

# Download the binary for your system
sudo curl -L --output /usr/local/bin/gitlab-runner \
  "https://gitlab-runner-downloads.s3.amazonaws.com/${RUNNER_VERSION}/binaries/gitlab-runner-linux-${DEPLOY_ARCH_TYPE}"

# Give it permission to execute
sudo chmod +x /usr/local/bin/gitlab-runner

# Install and run as a service
sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
sudo gitlab-runner start

sudo gitlab-runner register \
    --non-interactive \
    --url "https://gitlab-master.example-domain.com/ " \
    --registration-token "${RUNNER_JOIN_TOKEN}" \
    --executor "shell" \
    --shell "bash" \
    --limit 1 \
    --description "Main infrastructure runner" \
    --tag-list "infra-shell-bash-runner" \
    --run-untagged="true" \
    --locked="false" \
    --access-level="not_protected"

# --clone-url "https://gitlab-master.example-domain.com" \

sudo sed -i 's/concurrent.*/concurrent = 1/' /etc/gitlab-runner/config.toml
sudo rm -f /home/gitlab-runner/.bash_logout >> /dev/null 2>&1 || echo -n ""

sudo gitlab-runner restart

exit 0
