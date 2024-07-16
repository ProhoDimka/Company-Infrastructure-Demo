packer init packer_ubuntu.pkr.hcl
packer validate packer_ubuntu.pkr.hcl
packer fmt packer_ubuntu.pkr.hcl
packer build packer_ubuntu.pkr.hcl

```shell
### INIT First master node SETUP IPs
export K8S_MASTER_IP=172.31.19.204
export K8S_LB_IP_INT=172.31.19.251
export K8S_LB_IP_EXT=13.234.92.143
export K8S_LB_DNS=k8s-cluster-1-lb-a58a82a70c5fc33b.elb.ap-south-1.amazonaws.com
export K8S_IP_DNS1=k8s.pilot.main.example-domain.com
export K8S_IP_DNS2=cluster-1.k8s.pilot.main.example-domain.com
#--apiserver-advertise-address ${K8S_MASTER_IP} \
sudo kubeadm init \
    --control-plane-endpoint ${K8S_LB_IP_INT} \
    --apiserver-cert-extra-sans ${K8S_LB_DNS},${K8S_IP_DNS1},${K8S_IP_DNS2},${K8S_LB_IP_EXT},${K8S_LB_IP_INT} \
    --pod-network-cidr 10.244.0.0/16 \
    --v=7

#sudo kubeadm token list | grep forever | if [ $(wc -l) != "0" ]; then echo "true"; else echo "k8s join token doesn't exist" && exit 1; fi
#K8S_JOIN_TOKEN=$(sudo kubeadm token list | grep forever | cut -d' ' -f1)
sudo kubeadm token create $(sudo kubeadm token generate) --ttl=0 --print-join-command > k8s_join_command.sh
mkdir .kube
sudo cp /etc/kubernetes/admin.conf .kube/admin_config.conf
sudo chown ubuntu:ubuntu .kube/admin_config.conf
echo "export KUBECONFIG=~/.kube/admin_config.conf" | tee -a .bashrc
export KUBECONFIG=~/.kube/admin_config.conf
chmod +x k8s_join_command.sh
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  ubuntu@ip-172-31-27-118.ap-south-1.compute.internal 'mkdir -p ~/.kube/masters/pki/etcd' || exit 0
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  ubuntu@ip-172-31-27-118.ap-south-1.compute.internal 'mkdir -p ~/.kube/masters/kubelet' || exit 0
sudo scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -i .ssh/id_rsa /etc/kubernetes/pki/ca.crt ubuntu@ip-172-31-27-118.ap-south-1.compute.internal:~/.kube/masters/pki/
sudo scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -i .ssh/id_rsa /etc/kubernetes/pki/ca.key ubuntu@ip-172-31-27-118.ap-south-1.compute.internal:~/.kube/masters/pki/
sudo scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -i .ssh/id_rsa /etc/kubernetes/pki/sa.pub ubuntu@ip-172-31-27-118.ap-south-1.compute.internal:~/.kube/masters/pki/
sudo scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -i .ssh/id_rsa /etc/kubernetes/pki/sa.key ubuntu@ip-172-31-27-118.ap-south-1.compute.internal:~/.kube/masters/pki/
sudo scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -i .ssh/id_rsa /etc/kubernetes/pki/front-proxy-ca.crt ubuntu@ip-172-31-27-118.ap-south-1.compute.internal:~/.kube/masters/pki/
sudo scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -i .ssh/id_rsa /etc/kubernetes/pki/front-proxy-ca.key ubuntu@ip-172-31-27-118.ap-south-1.compute.internal:~/.kube/masters/pki/
sudo scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -i .ssh/id_rsa /etc/kubernetes/pki/etcd/ca.crt ubuntu@ip-172-31-27-118.ap-south-1.compute.internal:~/.kube/masters/pki/etcd/
sudo scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -i .ssh/id_rsa /etc/kubernetes/pki/etcd/ca.key ubuntu@ip-172-31-27-118.ap-south-1.compute.internal:~/.kube/masters/pki/etcd/

sudo scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -i .ssh/id_rsa k8s_join_command.sh ubuntu@ip-172-31-27-118.ap-south-1.compute.internal:~/.kube/masters/
sudo scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -i .ssh/id_rsa .kube/admin_config.conf ubuntu@ip-172-31-27-118.ap-south-1.compute.internal:~/.kube/masters/
### On every next master node
sudo mkdir -p /etc/kubernetes/pki/etcd
sudo scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -i .ssh/id_rsa ubuntu@ip-172-31-27-118.ap-south-1.compute.internal:~/.kube/masters/pki/ca.crt /etc/kubernetes/pki/
sudo scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -i .ssh/id_rsa ubuntu@ip-172-31-27-118.ap-south-1.compute.internal:~/.kube/masters/pki/ca.key /etc/kubernetes/pki/
sudo scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -i .ssh/id_rsa ubuntu@ip-172-31-27-118.ap-south-1.compute.internal:~/.kube/masters/pki/sa.pub /etc/kubernetes/pki/
sudo scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -i .ssh/id_rsa ubuntu@ip-172-31-27-118.ap-south-1.compute.internal:~/.kube/masters/pki/sa.key /etc/kubernetes/pki/
sudo scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -i .ssh/id_rsa ubuntu@ip-172-31-27-118.ap-south-1.compute.internal:~/.kube/masters/pki/front-proxy-ca.crt /etc/kubernetes/pki/
sudo scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -i .ssh/id_rsa ubuntu@ip-172-31-27-118.ap-south-1.compute.internal:~/.kube/masters/pki/front-proxy-ca.key /etc/kubernetes/pki/
sudo scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -i .ssh/id_rsa ubuntu@ip-172-31-27-118.ap-south-1.compute.internal:~/.kube/masters/pki/etcd/ca.crt /etc/kubernetes/pki/etcd/
sudo scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -i .ssh/id_rsa ubuntu@ip-172-31-27-118.ap-south-1.compute.internal:~/.kube/masters/pki/etcd/ca.key /etc/kubernetes/pki/etcd/

sudo scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -i .ssh/id_rsa ubuntu@ip-172-31-27-118.ap-south-1.compute.internal:~/.kube/masters/k8s_join_command.sh ~/
sudo chown ubuntu:ubuntu k8s_join_command.sh
truncate -s-1 k8s_join_command.sh
echo -n "--control-plane --v=7" | tee -a k8s_join_command.sh
sudo ./k8s_join_command.sh

mkdir .kube
sudo cp /etc/kubernetes/admin.conf .kube/admin_config.conf
sudo chown ubuntu:ubuntu .kube/admin_config.conf
echo "export KUBECONFIG=~/.kube/admin_config.conf" | tee -a .bashrc
export KUBECONFIG=~/.kube/admin_config.conf
```
-------------------



curl https://172.31.16.96:6443/healthz?timeout=10s
curl https://localhost:6443/healthz?timeout=10s
curl https://172.31.9.153:6443/healthz?timeout=10s

curl https://k8s-cluster-1-lb-56561a1119d756d8.elb.ap-south-1.amazonaws.com:6443/healthz?timeout=10s

s3://k8s.cluster-1.dev.k8s/lb/logs