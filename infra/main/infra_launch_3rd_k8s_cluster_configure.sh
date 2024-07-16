#!/usr/bin/bash

set -e

source ./infra_k8s_get_kubeconfig.sh

# Apply cluster configuration
terraform apply -auto-approve \
  -target module.k8s_cluster_configuration

exit 0
