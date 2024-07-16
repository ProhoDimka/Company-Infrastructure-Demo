locals {
  pg_data_sc_name  = "pg-main-sc"
  pg_data_pvc_name = "pg-main-pvc"
}

/*provider "postgresql" {
  host     = "${helm_release.postgresql-main.name}.${var.k8s_domain_name}"
  port     = 5432
  database = "postgres"
  username = "postgres"
  password = random_password.pg_password.result
}

resource "random_password" "pg_roles" {
  count       = length(var.pg_main_roles)
  length      = 16
  special     = true
  min_special = 1
  upper       = true
  min_upper   = 4
  lower       = true
  min_lower   = 4
  numeric     = true
  min_numeric = 3

  depends_on = [helm_release.postgresql-main]
}

resource "postgresql_role" "pg_roles" {
  count    = length(var.pg_main_roles)
  name     = var.pg_main_roles[count.index].user_name
  login    = true
  password = random_password.pg_roles[count.index]

  depends_on = [helm_release.postgresql-main]
}

resource "postgresql_database" "pg_roles" {
  count = length(var.pg_main_roles)
  name = var.pg_main_roles[count.index].db_name
  owner = postgresql_role.pg_roles[count.index].name

  depends_on = [helm_release.postgresql-main]
}*/

resource "helm_release" "postgresql-main" {
  name = "postgresql-main"

  chart   = "oci://registry-1.docker.io/bitnamicharts/postgresql"
  version = var.postgresql_chart_version

  namespace = kubernetes_namespace.postgresql-main.metadata[0].name

  values = [
    templatefile("helm_values/values_pg_main.yaml", {
      postgresPassword      = random_password.pg_password.result
      pgAdminCustomUser     = "pg_admin_user"
      pgAdminCustomUserPass = random_password.pg_password_admin_user.result
      pgAdminCustomDB       = "main-cluster-1"
      pgNodePort = tostring(var.pg_node_port_main)
      pgDataPVC             = local.pg_data_pvc_name
      pgDataStorageClass    = local.pg_data_sc_name
      PGDUMP_DIR            = "$${PGDUMP_DIR}"
    })
  ]

  depends_on = [
    helm_release.flannel,
    helm_release.aws-ebs-csi-driver,
    kubectl_manifest.pg_data_sc,
    kubectl_manifest.pg_data_pvc
  ]
}

resource "kubernetes_namespace" "postgresql-main" {
  metadata {
    annotations = {
      name = "postgresql-main"
    }

    name = "postgresql-main"
  }
}

resource "random_password" "pg_password" {
  length      = 16
  special     = true
  min_special = 1
  upper       = true
  min_upper   = 3
  lower       = true
  min_lower   = 4
  numeric     = true
  min_numeric = 4
}

resource "random_password" "pg_password_admin_user" {
  length      = 16
  special     = true
  min_special = 1
  upper       = true
  min_upper   = 3
  lower       = true
  min_lower   = 4
  numeric     = true
  min_numeric = 4
}

resource "kubectl_manifest" "pg_data_pvc" {
  yaml_body = <<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ${local.pg_data_pvc_name}
  namespace: ${kubernetes_namespace.postgresql-main.metadata[0].name}
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: ${local.pg_data_sc_name}
  resources:
    requests:
      storage: 5Gi
YAML
  depends_on = [
    helm_release.aws-ebs-csi-driver,
    kubectl_manifest.pg_data_sc
  ]
}

resource "kubectl_manifest" "pg_data_sc" {
  yaml_body = <<YAML
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ${local.pg_data_sc_name}
provisioner: ebs.csi.aws.com
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
YAML

  depends_on = [
    helm_release.aws-ebs-csi-driver
  ]
}