variable "cert_issuer_name" {
  type    = string
  default = "letsencrypt-cluster-issuer"
}

variable "k8s_domain_name" {
  type    = string
  default = "example-domain.com"
}

variable "cert_issuer_email" {
  type    = string
  default = "owner@example.org"
}

variable "cert_issuer_key_name" {
  type    = string
  default = "letsencrypt-cluster-issuer-key"
}

variable "flannel_cni_podCidr" {
  type    = string
  default = "10.244.0.0/16"
}

variable "flannel_cni_chart_version" {
  type    = string
  default = "v0.25.4"
}

variable "ingress_nginx_chart_version" {
  type    = string
  default = "4.10.1"
}

variable "argo_cd_chart_version" {
  type    = string
  default = "7.3.2"
}

variable "postgresql_chart_version" {
  type    = string
  default = "15.5.16"
}

variable "cert_manager_chart_version" {
  type    = string
  default = "v1.15.0"
}

variable "snapshot_controller_version" {
  type    = string
  default = "3.0.5"
}

variable "aws_ebs_csi_driver_chart_version" {
  type    = string
  default = "2.32.0"
}

variable "hc_consul_chart_version" {
  type    = string
  default = "1.5.0"
}

variable "hc_vault_chart_version" {
  type    = string
  default = "0.28.1"
}

variable "hc_vault_secrets_operator_chart_version" {
  type    = string
  default = "0.7.1"
}

variable "cert_issuer_ingress_class_name" {
  type    = string
  default = "nginx"
}

variable "k8s_iam_user_name" {
  type    = string
  default = "k8s_admin_cluster_1"
}

variable "aws_ebs_csi_driver_controller_replicas" {
  type    = string
  default = "3"
}

variable "pg_node_port_main" {
  type    = number
  default = 32432
}

# variable "pg_main_roles" {
#   type = list(object({
#     user_name = string
#     db_name = string
#   }))
#   default = [
#     {
#       user_name = "keycloack"
#       db_name   = "keycloack"
#     }
#   ]
# }