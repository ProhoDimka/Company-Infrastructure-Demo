output "instance_ip_private" {
  value = aws_instance.main.private_ip
}

output "instance_ip_public" {
  value = aws_instance.main.public_ip
}

output "instance_public_dns_name" {
  value = { for k, v in aws_route53_record.main : k => v }
}