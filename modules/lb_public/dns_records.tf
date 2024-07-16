resource "aws_route53_record" "lb_record_main" {
  count   = var.lb_has_allocated_eip ? length(var.subnet_ids) : 0
  zone_id = var.zone_id_for_dns_record
  name    = var.ld_custom_domain_name
  type    = "A"
  ttl     = 3600
  records = [aws_eip.main[count.index].public_ip]
}

resource "aws_route53_record" "lb_records" {
#   count = length(var.zone_records)
  for_each = {
    for product in setproduct(var.zone_records, aws_eip.main) : "${product[0].name}|${product[1].public_ip}" => {
      zone_id = product[0].zone_id
      name = product[0].name
      ttl = product[0].ttl
      record = product[1].public_ip
    }
}
  zone_id = each.value.zone_id
  name    = each.value.name
  type    = "A"
  ttl     = each.value.ttl
  records = [each.value.record]
}