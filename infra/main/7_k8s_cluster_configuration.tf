module "k8s_cluster_configuration" {
  source = "../../modules/k8s_cluster_configuration"

  # IAM User
  k8s_iam_user_name = module.k8s_cluster_equipment.k8s_iam_user_name

  # CNI Flannel
  flannel_cni_chart_version = "v0.25.4"
  flannel_cni_podCidr = "10.244.0.0/16"

  # CSI AWS
  snapshot_controller_version = "3.0.5"
  aws_ebs_csi_driver_chart_version = "2.32.0"
  aws_ebs_csi_driver_controller_replicas = "2"

  # Ingress NGINX
  ingress_nginx_chart_version = "4.10.1"

  # Cert-manager
  cert_manager_chart_version     = "v1.15.0"
  cert_issuer_name               = "letsencrypt-cluster-issuer"
  cert_issuer_email              = "admin@example-domain.com"
  cert_issuer_key_name           = "letsencrypt-cluster-issuer-key"
  cert_issuer_ingress_class_name = "nginx"

  # Hashicorp
  hc_consul_chart_version = "1.5.0"
  hc_vault_chart_version = "0.28.1"
  hc_vault_secrets_operator_chart_version = "0.7.1"

  # PostgreSQL Main
  postgresql_chart_version = "15.5.16"
/*  pg_main_roles = [
    "keycloack"
  ]*/
}