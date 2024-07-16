#
# https://github.com/kubernetes-csi/external-snapshotter#usage
# https://github.com/kubernetes-sigs/aws-ebs-csi-driver?tab=readme-ov-file#documentation

resource "kubectl_manifest" "aws-ebs-csi-driver-iam-secret" {
  yaml_body = <<YAML
apiVersion: v1
data:
  key_id: ${base64encode(aws_iam_access_key.k8s.id)}
  access_key: ${base64encode(aws_iam_access_key.k8s.secret)}
kind: Secret
metadata:
  name: aws-secret
  namespace: kube-system
type: Opaque
YAML
}

resource "helm_release" "snapshot-controller" {
  name = "snapshot-controller"

  repository = "https://piraeus.io/helm-charts/"
  chart      = "snapshot-controller"
  version    = var.snapshot_controller_version
  namespace = "kube-system"

  depends_on = [
    helm_release.flannel
  ]
}

resource "helm_release" "aws-ebs-csi-driver" {
  name = "aws-ebs-csi-driver"

  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  version    = var.aws_ebs_csi_driver_chart_version

  namespace = "kube-system"

  set {
    name  = "controller.replicaCount"
    value = var.aws_ebs_csi_driver_controller_replicas
  }

  depends_on = [
    helm_release.flannel,
    helm_release.snapshot-controller,
    kubectl_manifest.aws-ebs-csi-driver-iam-secret
  ]
}