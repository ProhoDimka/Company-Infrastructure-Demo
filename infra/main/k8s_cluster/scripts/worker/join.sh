#!/usr/bin/bash

set -e

CLUSTER_FILES_PATH=k8s_cluster
source ./k8s_cluster/.init.env

if [ "${K8S_CLUSTER_VERSIONS_COUNT}" == "all" ]; then
  K8S_CLUSTER_VERSIONS_COUNT=$(find ${CLUSTER_FILES_PATH}/ -iname "*.hosts" | wc -l)
fi

K8S_HOSTS_LIST="$(find ${CLUSTER_FILES_PATH}/ -iname "*.hosts" | sort | head -n"${K8S_CLUSTER_VERSIONS_COUNT}")"

echo "The action will perform on ${K8S_CLUSTER_VERSIONS_COUNT} versions:"
while IFS= read -r version; do
  echo "${version}"
done <<<"${K8S_HOSTS_LIST}"

echo "Envars in init_or_join.sh:"
env | grep K8S
# How to check value with AWS CLI:
# $ aws secretsmanager get-secret-value --secret-id=ca_key_pair --region=ap-south-1 | grep SecretBinary | sed -e 's/    "SecretBinary": "//g' | sed -e 's/",//g' | base64 --decode | jq -r ".crt" > ca/crt.crt

echo "Try to find secret with key: k8s-${K8S_CLUSTER_NAME}-k8s_join_command.sh"
K8S_SECRETS_NOT_EXIST=$(aws secretsmanager get-secret-value \
  --secret-id="k8s-${K8S_CLUSTER_NAME}-k8s_join_command.sh" \
  --query SecretBinary \
  --output text \
  --region="${K8S_AWS_REGION}" >>/dev/null 2>&1 ||
  echo true)
echo "K8S_SECRETS_NOT_EXIST status: ${K8S_SECRETS_NOT_EXIST}"

echo "Check if first master in first hosts file is initialized."
K8S_FIRST_MASTER_INITIALIZED=$(ansible-playbook -i "$(echo "${K8S_HOSTS_LIST}" | head -n1)" \
  ${CLUSTER_FILES_PATH}/playbook_k8s_master_init_check.yaml >> /dev/null 2>&1 || echo "false")
echo "K8S_FIRST_MASTER_INITIALIZED status: ${K8S_FIRST_MASTER_INITIALIZED:-ok}"

# If first master doesn't initialized - init step
if [ "${K8S_FIRST_MASTER_INITIALIZED}" == "false" ]; then
  echo "Cluster doesn't initialized."
  exit 1
fi

mkdir -p "${CLUSTER_FILES_PATH}/from_main_master/.kube/" >>/dev/null 2>&1 || true

SECRET_NAME="k8s-${K8S_CLUSTER_NAME}-k8s_join_command.sh"
aws secretsmanager get-secret-value \
  --secret-id "${SECRET_NAME}" \
  --query SecretBinary \
  --output text \
  --region="${K8S_AWS_REGION}" | base64 --decode >"${CLUSTER_FILES_PATH}/from_main_master/k8s_join_command.sh"
echo "secret downloaded: ${SECRET_NAME}"
SECRET_NAME="k8s-${K8S_CLUSTER_NAME}-.kube/admin_config.conf"
aws secretsmanager get-secret-value \
  --secret-id "${SECRET_NAME}" \
  --query SecretBinary \
  --output text \
  --region="${K8S_AWS_REGION}" | base64 --decode >"${CLUSTER_FILES_PATH}/from_main_master/.kube/admin_config.conf"
echo "secret downloaded: ${SECRET_NAME}"

echo "Join hosts list:"
echo "${K8S_HOSTS_LIST}"

while IFS= read -r hosts_file; do
  echo "Join for hosts: ${hosts_file}"
  ansible-playbook -i "${hosts_file}" ${CLUSTER_FILES_PATH}/playbook_k8s_worker_join.yaml
done <<<"${K8S_HOSTS_LIST}"

exit 0
