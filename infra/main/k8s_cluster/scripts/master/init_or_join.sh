#!/usr/bin/bash

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
SECRET_FILE_PATH=${CLUSTER_FILES_PATH}/secrets_list.txt
# Get first secret file name from list to check if secrets exists in AWS
FIRST_SECRET_IN_LIST=$(head -n1 ${SECRET_FILE_PATH} | sed 's/^\///g')
echo "Envars in init_or_join.sh:"
env | grep K8S
# How to check value with AWS CLI:
# $ aws secretsmanager get-secret-value --secret-id=ca_key_pair --region=ap-south-1 | grep SecretBinary | sed -e 's/    "SecretBinary": "//g' | sed -e 's/",//g' | base64 --decode | jq -r ".crt" > ca/crt.crt

echo "Try to find secret with key: k8s-${K8S_CLUSTER_NAME}-${FIRST_SECRET_IN_LIST}"
K8S_SECRETS_NOT_EXIST=$(aws secretsmanager get-secret-value \
  --secret-id="k8s-${K8S_CLUSTER_NAME}-${FIRST_SECRET_IN_LIST}" \
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

  echo "Init cluster playbook with masters[0] in hosts file: $(echo "${K8S_HOSTS_LIST}" | head -n1)"
  echo "##################"
  cat "$(echo "${K8S_HOSTS_LIST}" | head -n1)"
  echo "##################"
  ansible-playbook -i "$(echo "${K8S_HOSTS_LIST}" | head -n1)" ${CLUSTER_FILES_PATH}/playbook_k8s_master_init.yaml

  # if secrets not exist - create. else - update.
  if [ "${K8S_SECRETS_NOT_EXIST}" == "true" ]; then
    # Upload secrets to AWS
    while read -r secret_path; do
      SECRET_NAME="k8s-${K8S_CLUSTER_NAME}-${secret_path}"
      aws secretsmanager create-secret \
        --name "${SECRET_NAME}" \
        --secret-binary "fileb://${CLUSTER_FILES_PATH}/from_main_master/${secret_path}" \
        --region="${K8S_AWS_REGION}"
      echo "secret uploaded: ${SECRET_NAME}"
    done <<<"$(cat ${SECRET_FILE_PATH} | sed 's/^\///g')"
  else
    # Update secrets to AWS
    while read -r secret_path; do
      SECRET_NAME="k8s-${K8S_CLUSTER_NAME}-${secret_path}"
      aws secretsmanager update-secret \
        --secret-id "${SECRET_NAME}" \
        --secret-binary "fileb://${CLUSTER_FILES_PATH}/from_main_master/${secret_path}" \
        --region="${K8S_AWS_REGION}"
      echo "secret updated: ${SECRET_NAME}"
    done <<<"$(cat ${SECRET_FILE_PATH} | sed 's/^\///g')"
  fi

else
  mkdir -p "${CLUSTER_FILES_PATH}/from_main_master/.kube/" >>/dev/null 2>&1 | true
  mkdir -p "${CLUSTER_FILES_PATH}/from_main_master/etc/kubernetes/pki/etcd/" >>/dev/null 2>&1 | true
  # Download secrets from AWS if cluster initialized and secrets exist
  while read -r secret_path; do
    SECRET_NAME="k8s-${K8S_CLUSTER_NAME}-${secret_path}"
    aws secretsmanager get-secret-value \
      --secret-id "${SECRET_NAME}" \
      --query SecretBinary \
      --output text \
      --region="${K8S_AWS_REGION}" | base64 --decode >"${CLUSTER_FILES_PATH}/from_main_master/${secret_path}"
    echo "secret downloaded: ${SECRET_NAME}"
  done <<<"$(cat ${SECRET_FILE_PATH} | sed 's/^\///g')"
fi

echo "Join hosts list:"
echo "${K8S_HOSTS_LIST}"

while IFS= read -r hosts_file; do
  echo "Join for hosts: ${hosts_file}"
  ansible-playbook -i "${hosts_file}" ${CLUSTER_FILES_PATH}/playbook_k8s_master_join.yaml
done <<<"${K8S_HOSTS_LIST}"

exit 0
