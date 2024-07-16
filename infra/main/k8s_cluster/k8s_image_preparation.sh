#!/usr/bin/bash

export K8S_DEPLOY_VERSION=1.29.6-1.1
export K8S_DEPLOY_VERSION_INSTALL=v1.29.6
export K8S_DEPLOY_VERSION_INSTALL_MINOR=v1.29
export K8S_DEPLOY_CONTAINERD_VERSION=1.7.14
export K8S_DEPLOY_RUNC_VERSION=1.1.12
export K8S_DEPLOY_CNI_PLUGINS_VERSION=1.5.0
if [[ "$(dpkg --print-architecture)" == "aarch64" ]]; then
  export K8S_DEPLOY_ARCH_TYPE="arm64"
else
  # shellcheck disable=SC2155
  export K8S_DEPLOY_ARCH_TYPE="$(dpkg --print-architecture)"
fi
export K8S_DEPLOY_CONTAINERD_FILENAME=containerd-${K8S_DEPLOY_CONTAINERD_VERSION}-linux-${K8S_DEPLOY_ARCH_TYPE}.tar.gz
export K8S_DEPLOY_CNI_PLUGINS_FILE=cni-plugins-linux-${K8S_DEPLOY_ARCH_TYPE}-v${K8S_DEPLOY_CNI_PLUGINS_VERSION}.tgz

if test -f "${HOME}/.ssh/id_rsa.pub"; then
  cat "${HOME}/.ssh/id_rsa.pub" | tee "${HOME}/.ssh/authorized_keys"
  chmod 700 "${HOME}/.ssh"
  chmod 600 "${HOME}/.ssh/*"
  chmod 644 -f "${HOME}/.ssh/*.pub" "${HOME}/.ssh/authorized_keys" "${HOME}/.ssh/known_hosts" "${HOME}/.ssh/config"
fi

swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab
sudo cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
#sudo modprobe overlay
sudo modprobe br_netfilter
sudo sysctl --system

sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gnupg

# K8s repo for k8s installation
curl -fsSL https://pkgs.k8s.io/core:/stable:/${K8S_DEPLOY_VERSION_INSTALL_MINOR}/deb/Release.key \
    | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg]\
  https://pkgs.k8s.io/core:/stable:/${K8S_DEPLOY_VERSION_INSTALL_MINOR}/deb/ /" \
    | sudo tee -a /etc/apt/sources.list.d/kubernetes.list
sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list


### ContainerD Docs:
# https://github.com/containerd/containerd/blob/main/docs/getting-started.md
wget "https://github.com/containerd/containerd/releases/download/v${K8S_DEPLOY_CONTAINERD_VERSION}/${K8S_DEPLOY_CONTAINERD_FILENAME}"
sudo tar xvf "${K8S_DEPLOY_CONTAINERD_FILENAME}" --directory /usr/local/
sudo mkdir /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
### RunC release page:
# https://github.com/opencontainers/runc/tags
wget "https://github.com/opencontainers/runc/releases/download/v${K8S_DEPLOY_RUNC_VERSION}/runc.${K8S_DEPLOY_ARCH_TYPE}"
sudo install -m 755 "runc.${K8S_DEPLOY_ARCH_TYPE}" /usr/local/sbin/runc
### CniPlugins release page:
# https://github.com/containernetworking/plugins/releases
wget "https://github.com/containernetworking/plugins/releases/download/v${K8S_DEPLOY_CNI_PLUGINS_VERSION}/${K8S_DEPLOY_CNI_PLUGINS_FILE}"
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin "${K8S_DEPLOY_CNI_PLUGINS_FILE}"
### Launch containerd.service
curl -fsSL https://raw.githubusercontent.com/containerd/containerd/main/containerd.service \
    | sudo tee /etc/systemd/system/containerd.service
sudo systemctl daemon-reload
sudo systemctl enable containerd.service
sudo systemctl restart containerd.service

sudo apt update
sudo apt install -y kubeadm=${K8S_DEPLOY_VERSION} kubectl=${K8S_DEPLOY_VERSION} kubelet=${K8S_DEPLOY_VERSION}
sudo apt-mark hold kubeadm kubectl kubelet

sudo systemctl daemon-reload
sudo systemctl enable kubelet
sudo systemctl restart kubelet

cat <<EOF | sudo tee /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 5
debug: false
pull-image-on-create: false
EOF

sudo kubeadm config images pull --v=7

### FIX BUG because kubeadm pulled pause:3.9
sudo sed -i -e 's/pause:3.8/pause:3.9/g' /etc/containerd/config.toml

exit 0