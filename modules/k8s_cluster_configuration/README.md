* CNI: flannel
* INGRESS: nginx (depends_on CNI)
* CSI: aws-ebs-csi-driver + snapshot (depends_on CNI, aws_iam_access_key)
* Cert-manager: LetsEncrypt ClusterIssuer (depends_on: INGRESS)
* Argo-CD (depends_on: INGRESS, CSI, Cert-manager)
* JFrog Artifactory OSS (depends_on: INGRESS, CSI, Cert-manager)
* JFrog Container Registry (depends_on: INGRESS, CSI, Cert-manager)

```shell
# https://github.com/flannel-io/flannel
kubectl create ns kube-flannel
kubectl label --overwrite ns kube-flannel pod-security.kubernetes.io/enforce=privileged
helm repo add flannel https://flannel-io.github.io/flannel/
helm install flannel --set podCidr="10.244.0.0/16" --namespace kube-flannel flannel/flannel

# https://github.com/kubernetes/ingress-nginx
helm repo add ingress-mginx https://kubernetes.github.io/ingress-nginx
helm install ingress-nginx/ingress-nginx \
  --namespace ingress-mginx \
  --version 4.10.1

kubectl create ns cert-manager
helm repo add jetstack https://charts.jetstack.io --force-update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.15.0 \
  --set crds.enabled=true \
  --set startupapicheck.timeout=3m \
  --set global.logLevel=6

helm repo add piraeus-charts https://piraeus.io/helm-charts/
helm search repo piraeus-char/snapshot-controller
helm upgrade piraeus-charts/snapshot-controller \
  --version 3.0.5 \
  --set controller.image.tag=v5.0.0 \
  --set webhook.image.tag=v5.0.0
  
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm pull --version=2.32.0 aws-ebs-csi-driver/aws-ebs-csi-driver --untar
helm repo update
helm upgrade --install aws-ebs-csi-driver \
    --namespace kube-system \
    aws-ebs-csi-driver/aws-ebs-csi-driver

# https://github.com/coredns/coredns
# https://github.com/coredns/deployment
# https://github.com/coredns/helm
helm repo add coredns https://coredns.github.io/helm
helm --namespace=kube-system install coredns coredns/coredns

helm repo add jfrog https://charts.jfrog.io/
# https://jfrog.com/community/download-artifactory-oss/
# https://jfrog.com/help/r/jfrog-artifactory-documentation
# https://artifacthub.io/packages/helm/jfrog/artifactory-oss
helm install -name artifactory jfrog/artifactory-oss
helm pull --version=107.84.17 jfrog/artifactory-oss --untar
# https://jfrog.com/download-jfrog-container-registry/
# https://jfrog.com/help/r/jfrog-artifactory-documentation/jfrog-container-registry
# https://artifacthub.io/packages/helm/jfrog/artifactory-jcr
helm install -name artifactory jfrog/artifactory-jcr
helm pull --version=107.84.17 jfrog/artifactory-jcr --untar

helm repo add argo-cd https://argoproj.github.io/argo-helm
helm pull --version=7.3.2 argo-cd --untar
helm install argo-cd charts/argo-cd/

# https://artifacthub.io/packages/helm/bitnami/postgresql
helm pull oci://registry-1.docker.io/bitnamicharts/postgresql \
  --version=15.5.16 \
  --untar

# https://backube.github.io/snapscheduler/install.html
helm repo add backube https://backube.github.io/helm-charts/
helm pull --version=3.4 backube/snapscheduler --untar
```

1. namespace kube-flannel
2. helm-chart flannel
3. namespace ingress-nginx
4. helm-chart nginx-ingress
  * service Type nodePort
     * httpNodePort: 30080
     * httpsNodePort: 30443