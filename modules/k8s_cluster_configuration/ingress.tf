resource "helm_release" "nginx-ingress" {
  name = "nginx-ingress"

  repository   = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  version = var.ingress_nginx_chart_version

  namespace = kubernetes_namespace.ingress-nginx.metadata[0].name

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }
  set {
    name  = "controller.service.nodePorts.http"
    value = "30080"
  }
  set {
    name  = "controller.service.nodePorts.https"
    value = "30443"
  }
  set {
    name  = "controller.admissionWebhooks.certManager.enabled"
    value = "false"
  }
  set {
    name  = "controller.admissionWebhooks.certManager.admissionCert.duration"
    value = "3m"
  }
  set {
    name  = "controller.admissionWebhooks.certManager.admissionCert.issuerRef.name"
    value = var.cert_issuer_name
  }
  set {
    name  = "controller.admissionWebhooks.certManager.admissionCert.issuerRef.kind"
    value = "ClusterIssuer"
  }
  set {
    name  = "controller.ingressClassResource.default"
    value = "true"
  }
  set {
    name  = "controller.config.ssl-redirect"
    value = "false"
  }
  set {
    name  = "controller.config.force-ssl-redirect"
    value = "false"
  }
#   set {
#     name  = "controller.annotations.nginx\\.ingress\\.kubernetes\\.io/force-ssl-redirect"
#     value = "\"false\""
#   }

  depends_on = [helm_release.flannel]
}

resource "kubernetes_namespace" "ingress-nginx" {
  metadata {
    annotations = {
      name = "ingress-nginx"
    }

    name = "ingress-nginx"
  }
}