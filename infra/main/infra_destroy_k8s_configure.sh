#!/usr/bin/bash

set -e

source infra_k8s_get_kubeconfig.sh

# Destroy cluster configuration

terraform destroy -auto-approve \
  -target module.k8s_cluster_configuration.helm_release.hc-vault-secrets-operator
terraform destroy -auto-approve \
  -target module.k8s_cluster_configuration.helm_release.hc-vault
terraform destroy -auto-approve \
  -target module.k8s_cluster_configuration.helm_release.hc-consul
terraform destroy -auto-approve \
  -target module.k8s_cluster_configuration.helm_release.postgresql-main

terraform destroy -auto-approve \
  -target module.k8s_cluster_configuration.kubectl_manifest.hc_consul_sc \
  -target module.k8s_cluster_configuration.kubectl_manifest.hc_vault_sc \
  -target module.k8s_cluster_configuration.kubectl_manifest.pg_data_pvc \
  -target module.k8s_cluster_configuration.kubectl_manifest.pg_data_sc

terraform destroy -auto-approve \
  -target module.k8s_cluster_configuration

#exit 0