#!/usr/bin/bash

set -e

## Apply cluster to get hosts file
terraform apply -auto-approve \
  -target module.lb_public_common \
  -target module.k8s_cluster_1_29_6

exit 0
