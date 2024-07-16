module "k8s_cluster_equipment" {
  source = "../../modules/k8s_cluster_equipment"

  region = var.region

  # S3 bucket for volumes backups
  s3_bucket_for_backups_name = "example-domain-com-main-cluster-1"
}