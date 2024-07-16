# resource "aws_s3_bucket" "k8s" {
#   bucket = "k8s.${var.cluster_name}.${var.environment}.${var.project}"
# }