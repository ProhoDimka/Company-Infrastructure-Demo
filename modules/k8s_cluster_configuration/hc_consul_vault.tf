locals {
  hc_consul_sc_name = "hc-consul-sc"
  hc_vault_sc_name  = "hc-vault-sc"
}

resource "helm_release" "hc-consul" {
  name = "consul"

  repository = "https://helm.releases.hashicorp.com"
  chart      = "consul"
  version    = var.hc_consul_chart_version

  namespace = kubernetes_namespace.hashicorp.metadata[0].name

  values = [
    templatefile("helm_values/values_hc_consul.yaml", {
      serverStorageCapacity  = "3Gi"
      serverStorageClassName = local.hc_consul_sc_name
      isClientEnabled        = true
      bootstrapExpect        = 1
      HOSTNAME               = "$${HOSTNAME}"
      HOST_IP                = "$${HOST_IP}"
    })
  ]

  depends_on = [
    helm_release.flannel,
    helm_release.aws-ebs-csi-driver,
    helm_release.cert-manager,
    helm_release.postgresql-main,
    kubectl_manifest.hc_consul_sc
  ]
}

resource "helm_release" "hc-vault" {
  name = "vault"

  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault"
  version    = var.hc_vault_chart_version

  namespace = kubernetes_namespace.hashicorp.metadata[0].name

  values = [
    templatefile("helm_values/values_hc_vault.yaml", {
      isServerIngressEnabled = true
      serverIngressAnnotations = <<YAML

        cert-manager.io/cluster-issuer: letsencrypt-cluster-issuer
YAML
      serverIngressHostname  = "vault.example-domain.com"
      serverIngressTlsList = <<YAML

      - hosts:
        - "vault.example-domain.com"
        secretName: "ingress-vault-server-cert-secret"
YAML
      serverStorageCapacity  = "2Gi"
      serverStorageClassName = local.hc_vault_sc_name
      isHaEnabled            = true
      haReplicas             = 1
    })
  ]

  depends_on = [
    helm_release.flannel,
    helm_release.aws-ebs-csi-driver,
    helm_release.hc-consul,
    kubectl_manifest.hc_vault_sc
  ]
}

resource "helm_release" "hc-vault-secrets-operator" {
  name = "vault-secrets-operator"

  repository = "https://helm.releases.hashicorp.com"
  chart      = "vault-secrets-operator"
  version    = var.hc_vault_secrets_operator_chart_version

  namespace = kubernetes_namespace.hashicorp.metadata[0].name

  values = [
    templatefile("helm_values/values_hc_vault_secrets_operator.yaml", {
      isEnabledDefaultVaultConnection = true
      defaultVaultConnectionAddress = "http://vault:8200"
    })
  ]

  depends_on = [
    helm_release.hc-vault
  ]
}

resource "kubernetes_namespace" "hashicorp" {
  metadata {
    annotations = {
      name = "hashicorp"
    }

    name = "hashicorp"
  }
}

resource "kubectl_manifest" "hc_consul_sc" {
  yaml_body = <<YAML
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ${local.hc_consul_sc_name}
provisioner: ebs.csi.aws.com
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
YAML

  depends_on = [
    helm_release.aws-ebs-csi-driver
  ]
}

resource "kubectl_manifest" "hc_vault_sc" {
  yaml_body = <<YAML
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ${local.hc_vault_sc_name}
provisioner: ebs.csi.aws.com
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
YAML

  depends_on = [
    helm_release.aws-ebs-csi-driver
  ]
}