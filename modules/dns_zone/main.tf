resource "aws_route53_zone" "main" {
  name = var.account_domain_init_name
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_route53_record" "main" {
  allow_overwrite = true
  name            = var.account_domain_init_name
  ttl             = var.account_domain_ns_ttl
  type            = "NS"
  zone_id         = aws_route53_zone.main.zone_id

  records = [
    aws_route53_zone.main.name_servers[0],
    aws_route53_zone.main.name_servers[1],
    aws_route53_zone.main.name_servers[2],
    aws_route53_zone.main.name_servers[3],
  ]
}

resource "aws_route53_record" "records" {
  count = length(var.zone_records)
  zone_id = aws_route53_zone.main.zone_id
  name    = var.zone_records[count.index].name
  type    = var.zone_records[count.index].type
  ttl     = var.zone_records[count.index].ttl
  records = var.zone_records[count.index].records
}