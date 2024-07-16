output "lb_dns_name" {
  value = aws_lb.main.dns_name
}

output "lb_private_ips" {
  value = flatten([data.aws_network_interface.ifs.*.private_ips])
}

output "lb_private_ip" {
  value = flatten([data.aws_network_interface.ifs.*.private_ips])[0]
}


output "lb_public_ip" {
  value = flatten([aws_eip.main.*.public_ip])[0]
}

output "lb_target_groups_map" {
  value = {
    for tg in aws_lb_target_group.main : tg.name => {
      arn = tg.arn
    }
  }
}