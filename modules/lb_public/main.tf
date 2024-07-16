data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_network_interfaces" "main" {
  filter {
    name = "description"
    values = ["ELB net/${aws_lb.main.name}/*"]
  }
  filter {
    name = "vpc-id"
    values = [var.vpc_id]
  }
  filter {
    name = "status"
    values = ["in-use"]
  }
  filter {
    name = "attachment.status"
    values = ["attached"]
  }
}

locals {
  nlb_interface_ids = flatten([data.aws_network_interfaces.main.ids])
}

data "aws_network_interface" "ifs" {
  id = local.nlb_interface_ids[0]
}
