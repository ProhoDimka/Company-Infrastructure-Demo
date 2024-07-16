resource "aws_s3_bucket" "backups" {
  bucket = var.s3_bucket_for_backups_name
}