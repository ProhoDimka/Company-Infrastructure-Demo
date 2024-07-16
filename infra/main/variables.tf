variable "region" {
  description = "List of regions to add cert"
  type        = string
  default     = "ap-south-1"
}
variable "vpc_id" {
  type = string
  default = "vpc-0f4e8e46f62f929fc"
}
variable "environment" {
  type = string
  default = "main"
}
variable "account_domain_init_name" {
  description = "account domain zone name"
  type        = string
  default     = "example-domain.com"
}
variable "account_domain_name" {
  description = "SHIT STICKS! IT MUST BE !NULL! BECAUSE DEPENDENCY WAITING ITS INITIALIZATION!"
  type        = string
  default     = null
}
variable "ecr_registry_name" {
  description = "ECR registry name"
  type        = string
  default     = "main"
}
variable "cluster_name" {
  type = string
  default = "cluster-1"
}
variable "pg_node_port_main" {
  type    = number
  default = 32432
}
variable "is_prebuilded_ami" {
  description = "Did you know ami_id instead?"
  type        = bool
  default     = true
}

variable "ami_id" {
  description = "Known ami ID"
  type        = string
  default     = "ami-089d939ba6738652f"
}

variable "cert_arn" {
  description = "AWS managed cert ARN."
  type        = string
  default     = ""
}
variable "ca_secret_name" {
  type    = string
  default = "ca_key_pair"
}
variable "cert_validation_options" {
  description = "AWS managed cert DNS validation options."
  type        = set(map(string))
  default     = [{}]
}
variable "ecr_registry_scan_on_push" {
  description = "ECR registry scan on push action https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-scanning.html"
  type        = bool
  default     = true
}

variable "k8s_iam_user_name" {
  type    = string
  default = "k8s_admin_cluster_1"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
