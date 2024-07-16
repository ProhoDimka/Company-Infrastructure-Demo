#!/usr/bin/bash

set -e

# * Get info about default VPC in region
# * Create DNS zone and AWS certificate
terraform apply -auto-approve \
      -target module.vpc_default \
      -target module.account_dns_zone

terraform apply -auto-approve \
      -target module.lb_public_common.aws_eip.main

terraform apply -auto-approve \
      -target module.lb_public_common \
      -target module.ec2_instance_gitlab \
      -target module.ec2_instance_gitlab_runner  \
      -target module.k8s_cluster_equipment

# Settings up new gitlab host
ansible-playbook -i gitlab-master/hosts gitlab-master/playbook_gitlab_apply_restore.yaml

# Settings up new gitlab runner
ansible-playbook -i gitlab-master-runner/hosts gitlab-master-runner/playbook_gitlab_runner_apply.yaml

exit 0