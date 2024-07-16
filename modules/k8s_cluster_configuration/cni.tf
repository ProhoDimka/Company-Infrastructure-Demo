resource "helm_release" "flannel" {
  name = "flannel"

  repository = "https://flannel-io.github.io/flannel/"
  chart      = "flannel"
  version    = var.flannel_cni_chart_version

  namespace = kubernetes_namespace.kube-flannel.metadata[0].name

  set {
    name  = "podCidr"
    value = var.flannel_cni_podCidr
  }
}

resource "kubernetes_namespace" "kube-flannel" {
  metadata {
    annotations = {
      name = "kube-flannel"
    }

    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
    }

    name = "kube-flannel"
  }
}