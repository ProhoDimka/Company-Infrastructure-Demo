resource "helm_release" "cert-manager" {
  name = "cert-manager"

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = var.cert_manager_chart_version

  namespace = kubernetes_namespace.cert-manager.metadata[0].name

  set {
    name  = "crds.enabled"
    value = "true"
  }

  set {
    name  = "startupapicheck.timeout"
    value = "3m"
  }

  set {
    name  = "global.logLevel"
    value = "6"
  }

  depends_on = [helm_release.nginx-ingress]
}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    annotations = {
      name = "cert-manager"
    }

    name = "cert-manager"
  }
}

resource "kubectl_manifest" "letsencrypt-cluster-issuer" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${var.cert_issuer_name}
spec:
  acme:
    # You must replace this email address with your own.
    # Let's Encrypt will use this to contact you about expiring
    # certificates, and issues related to your account.
    email: ${var.cert_issuer_email}
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Secret resource that will be used to store the account's private key.
      name: ${var.cert_issuer_key_name}
    # Add a single challenge solver, HTTP01 using nginx
    solvers:
      - http01:
          ingress:
            ingressClassName: ${var.cert_issuer_ingress_class_name}
YAML
  depends_on = [helm_release.cert-manager]
}