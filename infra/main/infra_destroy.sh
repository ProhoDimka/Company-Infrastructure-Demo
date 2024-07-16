#!/usr/bin/bash

set -e

source infra_destroy_k8s_configure.sh

# Backup before destroy
ansible-playbook -i gitlab-master/hosts gitlab-master/playbook_gitlab_destroy_backup.yaml

terraform destroy -auto-approve \
      -target module.k8s_cluster_1_29_6

terraform destroy -auto-approve \
      -target module.ec2_instance_gitlab.aws_instance.main \
      -target module.ec2_instance_gitlab_runner

terraform destroy -auto-approve \
      -target module.ec2_instance_gitlab.aws_eip.main \
      -target module.ec2_instance_gitlab.aws_route53_record.instance_records \
      -target module.ec2_instance_gitlab.aws_iam_user.main \
      -target module.ec2_instance_gitlab.aws_key_pair.main \
      -target module.ec2_instance_gitlab.aws_security_group.main  \
      -target module.ec2_instance_gitlab.aws_security_group_rule.main  \
      -target module.lb_public_common.aws_lb.main  \
      -target module.lb_public_common.aws_lb_listener.main \
      -target module.lb_public_common.aws_eip.main

terraform destroy -auto-approve \
      -target module.vpc_default.aws_nat_gateway.main \
      -target module.vpc_default.aws_eip.main

exit 0