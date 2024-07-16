#!/usr/bin/bash

set -e

# Settings up new gitlab runner
ansible-playbook -i gitlab-master-runner/hosts gitlab-master-runner/playbook_gitlab_runner_apply.yaml

exit 0