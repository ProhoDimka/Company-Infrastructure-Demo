output "zone_id" {
  value = aws_route53_zone.main.zone_id
}

output "zone_id_name" {
  value = aws_route53_zone.main.name
}

output "name_servers" {
  value = aws_route53_zone.main.name_servers
}