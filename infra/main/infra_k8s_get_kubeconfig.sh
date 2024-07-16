#!/usr/bin/bash

set -e

K8S_MAIN_VERSION=1.29.6
# for local debug
LOCAL_LAUNCH=${1:-false}

CLUSTER_FILES_PATH=k8s_cluster
source ./k8s_cluster/.init.env || true

env | grep K8S

# Check if master initialized
if [ "${LOCAL_LAUNCH}" == "false" ]; then
  echo "Check if first master in first hosts file is initialized."
  K8S_FIRST_MASTER_INITIALIZED=$(ansible-playbook -i "${CLUSTER_FILES_PATH}/${K8S_MAIN_VERSION}.hosts" \
    ${CLUSTER_FILES_PATH}/playbook_k8s_master_init_check.yaml >>/dev/null 2>&1 || echo "false")
  echo "K8S_FIRST_MASTER_INITIALIZED status: ${K8S_FIRST_MASTER_INITIALIZED:-ok}"
fi

# If master initialized - download kubeconfig
if [ "${K8S_FIRST_MASTER_INITIALIZED:-ok}" == "ok" ]; then

  mkdir -p "${CLUSTER_FILES_PATH}/from_main_master/.kube" >> /dev/null 2>&1 || true

  SECRET_NAME="k8s-${K8S_CLUSTER_NAME}-.kube/admin_config.conf"
  aws secretsmanager get-secret-value \
    --secret-id "${SECRET_NAME}" \
    --query SecretBinary \
    --output text \
    --region="${K8S_AWS_REGION}" | base64 --decode > "${CLUSTER_FILES_PATH}/from_main_master/.kube/admin_config.conf"
  echo "secret downloaded: ${SECRET_NAME}"

  if [ "${LOCAL_LAUNCH}" != "false" ]; then
    sed -i "s/${K8S_LB_IP_INT}/${K8S_LB_DNS}/g" "${CLUSTER_FILES_PATH}/from_main_master/.kube/admin_config.conf"
  fi
  export KUBE_CONFIG_PATH=${PWD}/${CLUSTER_FILES_PATH}/from_main_master/.kube/admin_config.conf

else
  echo "Cluster doesn't initialized."
  exit 1
fi
