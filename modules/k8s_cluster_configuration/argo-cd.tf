/*
resource "helm_release" "argo-cd" {
  name = "argo-cd"

  repository = "https://argoproj.github.io/argo-helm"
  chart   = "argo-cd"
  version = var.argo_cd_chart_version

  namespace = kubernetes_namespace.argo-cd.metadata[0].name

  set {
    name  = "global.domain"
    value = "argo-cd.${var.k8s_domain_name}"
  }
  set {
    name  = "configs.params.server\\.insecure"
    value = "true"
  }
  set {
    name  = "server.ingress.enabled"
    value = "true"
  }
  set {
    name  = "server.ingress.ingressClassName"
    value = "nginx"
  }
  set {
    name  = "server.ingress.hostname"
    value = "argo-cd.${var.k8s_domain_name}"
  }
  set {
    name  = "server.ingress.tls"
    value = "true"
  }
  set {
    name  = "server.ingress.annotations.cert-manager\\.io/cluster-issuer"
    value = "letsencrypt-cluster-issuer"
  }
  set {
    name  = "server.ingressGrpc.enabled"
    value = "true"
  }
  set {
    name  = "server.ingressGrpc.ingressClassName"
    value = "nginx"
  }
  set {
    name  = "server.ingressGrpc.hostname"
    value = "argo-cd-grpc.${var.k8s_domain_name}"
  }
  set {
    name  = "server.ingressGrpc.tls"
    value = "true"
  }
  set {
    name  = "server.ingressGrpc.annotations.cert-manager\\.io/cluster-issuer"
    value = "letsencrypt-cluster-issuer"
  }
  set {
    name  = "applicationSet.ingress.enabled"
    value = "true"
  }
  set {
    name  = "applicationSet.ingress.ingressClassName"
    value = "nginx"
  }
  set {
    name  = "applicationSet.ingress.hostname"
    value = "argo-cd-app-set.${var.k8s_domain_name}"
  }
  set {
    name  = "applicationSet.ingress.tls"
    value = "true"
  }
  set {
    name  = "applicationSet.ingress.annotations.cert-manager\\.io/cluster-issuer"
    value = "letsencrypt-cluster-issuer"
  }

  depends_on = [
    helm_release.cert-manager,
    helm_release.aws-ebs-csi-driver
  ]
}

resource "kubernetes_namespace" "argo-cd" {
  metadata {
    annotations = {
      name = "argo-cd"
    }

    name = "argo-cd"
  }
}
*/