#!/usr/bin/bash

set -e

# copy secrets on its place
sudo chown ubuntu:ubuntu k8s_join_command.sh
chmod +x k8s_join_command.sh

sudo rm -rf /etc/kubernetes
sudo mv etc/kubernetes /etc
#sudo rm -rf etc

truncate -s-1 k8s_join_command.sh
echo -n "--control-plane --v=7" | tee -a k8s_join_command.sh
sudo ./k8s_join_command.sh

mkdir .kube >> /dev/null 2>&1 || true
sudo cp /etc/kubernetes/admin.conf .kube/admin_config.conf
sudo chown ubuntu:ubuntu .kube/admin_config.conf
echo "export KUBECONFIG=~/.kube/admin_config.conf" | tee -a .bashrc
export KUBECONFIG=~/.kube/admin_config.conf

exit 0
