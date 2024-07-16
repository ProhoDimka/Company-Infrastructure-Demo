#!/usr/bin/bash

# We reset just oldest version

set -e

source ./k8s_cluster/.init.env

if [ "${K8S_CLUSTER_VERSIONS_COUNT}" == "all" ]; then
  K8S_CLUSTER_VERSIONS_COUNT=$(find k8s_cluster/ -iname "*.hosts" | wc -l)
fi
K8S_HOSTS_LIST="$(find k8s_cluster/ -iname "*.hosts" | sort | head -n"${K8S_CLUSTER_VERSIONS_COUNT}")"

echo "The action will perform on ${K8S_CLUSTER_VERSIONS_COUNT} versions:"
while IFS= read -r version; do
  echo "${version}"
done <<<"${K8S_HOSTS_LIST}"

CLUSTER_FILES_PATH=k8s_cluster
echo "Envars in init_or_join.sh:"
env | grep K8S

# We reset just oldest version or current if it's just one
K8S_HOSTS_RESET_LIST="$(echo "${K8S_HOSTS_LIST}" | head -n1)"
echo "K8S_HOSTS_RESET_LIST:"
echo "${K8S_HOSTS_RESET_LIST}"

while IFS= read -r hosts_file; do
  echo "Reset for hosts: ${hosts_file}"
  ansible-playbook -i "${hosts_file}" ${CLUSTER_FILES_PATH}/playbook_k8s_worker_reset.yaml
done <<<"${K8S_HOSTS_RESET_LIST}"

exit 0
