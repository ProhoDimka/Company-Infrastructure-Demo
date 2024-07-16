variable "region" {
  description = "Region"
  type        = string
  default     = "eu-central-1"
}

variable "s3_bucket_for_backups_name" {
  type    = string
  default = ""
}

variable "k8s_iam_user_name" {
  type    = string
  default = "k8s_admin_cluster_1"
}
