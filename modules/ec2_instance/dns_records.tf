resource "aws_route53_record" "main" {
  count   = var.instance.associate_public_ip_address ? 1 : 0
  zone_id = var.zone_id_for_dns_record
  name    = "${var.instance.name}.${var.account_domain_name}"
  type    = "A"
  ttl     = 3600
  records = [aws_eip.main[0].public_ip]
}

resource "aws_route53_record" "instance_records" {
  count = length(var.zone_records)
  zone_id = var.zone_records[count.index].zone_id
  name    = var.zone_records[count.index].name
  type    = var.zone_records[count.index].type
  ttl     = var.zone_records[count.index].ttl
  records = var.zone_records[count.index].records
}