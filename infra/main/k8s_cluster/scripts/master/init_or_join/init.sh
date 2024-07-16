#!/usr/bin/bash

set -e

source .init.env

env | grep K8S

sudo kubeadm init \
  --control-plane-endpoint "${K8S_LB_IP_INT}" \
  --apiserver-cert-extra-sans "${K8S_LB_DNS},${K8S_IP_DNS1},${K8S_IP_DNS2},${K8S_LB_IP_EXT},${K8S_LB_IP_INT_LIST}" \
  --pod-network-cidr 10.244.0.0/16 \
  --v=7

mkdir -p "${HOME}/etc/kubernetes/pki/etcd/" >> /dev/null 2>&1 || true
mkdir .kube >> /dev/null 2>&1 || true

sudo kubeadm token create $(sudo kubeadm token generate) --ttl=0 --print-join-command >k8s_join_command.sh
sudo cp /etc/kubernetes/admin.conf .kube/admin_config.conf
sudo chown ubuntu:ubuntu .kube/admin_config.conf
echo "export KUBECONFIG=~/.kube/admin_config.conf" | tee -a .bashrc
export KUBECONFIG=~/.kube/admin_config.conf
chmod +x k8s_join_command.sh

K8S_ETC_FILES_LIST=$(grep -i '/etc' "${HOME}/secrets_list.txt")

while IFS= read -r file; do
  sudo cp "${file}" "${HOME}${file}"
  sudo chown ubuntu:ubuntu "${HOME}${file}"
done <<<"${K8S_ETC_FILES_LIST}"

exit 0
