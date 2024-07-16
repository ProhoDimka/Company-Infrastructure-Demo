#!/usr/bin/bash

set -e

source ./k8s_cluster/.init.env
CLUSTER_FILES_PATH=k8s_cluster

if [ "${K8S_CLUSTER_VERSIONS_COUNT}" == "all" ]; then
  K8S_CLUSTER_VERSIONS_COUNT=$(find k8s_cluster/ -iname "*.hosts" | wc -l)
fi
K8S_HOSTS_LIST="$(find k8s_cluster/ -iname "*.hosts" | sort | head -n"${K8S_CLUSTER_VERSIONS_COUNT}")"

echo "The action will perform on ${K8S_CLUSTER_VERSIONS_COUNT} versions:"
while IFS= read -r version; do
  echo "${version}"
done <<<"${K8S_HOSTS_LIST}"

echo "Check if we trying reset old version."
if [ "${K8S_CLUSTER_VERSIONS_COUNT}" == "1" ]; then echo "error K8S_CLUSTER_VERSIONS_COUNT" && exit 1; fi

echo "Check if first master with latest version is initialized."
K8S_FIRST_LATEST_MASTER_INITIALIZED=$(ansible-playbook -i "$(echo "${K8S_HOSTS_LIST}" | tail -n1)" \
  ${CLUSTER_FILES_PATH}/playbook_k8s_master_init_check.yaml >>/dev/null 2>&1 || echo "false")
echo "K8S_FIRST_LATEST_MASTER_INITIALIZED status: ${K8S_FIRST_LATEST_MASTER_INITIALIZED:-ok}"
if [ "${K8S_FIRST_LATEST_MASTER_INITIALIZED}" == "false" ]; then echo "error K8S_FIRST_LATEST_MASTER_INITIALIZED" && exit 1; fi

K8S_HOSTS_RESET_LIST="$(echo "${K8S_HOSTS_LIST}" | sed '$d')"
echo "K8S_HOSTS_RESET_LIST:"
echo "${K8S_HOSTS_RESET_LIST}"

while IFS= read -r hosts_file; do
  echo "Reset for hosts: ${hosts_file}"
  ansible-playbook -i "${hosts_file}" ${CLUSTER_FILES_PATH}/playbook_k8s_master_reset.yaml
done <<<"${K8S_HOSTS_RESET_LIST}"

exit 0