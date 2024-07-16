output "s3_bucket_for_backups_name" {
  value = {
    s3_bucket_backups = {
      id                   = aws_s3_bucket.backups.id
      arn                  = aws_s3_bucket.backups.arn
      domain_name          = aws_s3_bucket.backups.bucket_domain_name
      regional_domain_name = aws_s3_bucket.backups.bucket_regional_domain_name
    }
  }
}

output "k8s_iam_user_name" {
  value = aws_iam_user.k8s.name
}