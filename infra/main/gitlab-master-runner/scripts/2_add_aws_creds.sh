#!/usr/bin/bash

#set -e

export ACCESS_KEY=$1
export SECRET_KEY=$2

sudo mkdir /home/gitlab-runner/.aws
cat <<EOF | sudo tee /home/gitlab-runner/.aws/credentials
[gitlab-runner]
aws_access_key_id=${ACCESS_KEY}
aws_secret_access_key=${SECRET_KEY}
EOF

sudo chmod 600 /home/gitlab-runner/.aws/credentials
sudo chown -R gitlab-runner:gitlab-runner /home/gitlab-runner/.aws

exit 0
