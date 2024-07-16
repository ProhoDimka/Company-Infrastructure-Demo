resource "aws_eip" "main" {
  count            = var.instance.associate_public_ip_address ? 1 : 0
  domain           = "vpc"
  public_ipv4_pool = "amazon"
  instance         = aws_instance.main.id
}

resource "aws_instance" "main" {
  ami           = var.instance.aws_ami_id
  instance_type = var.instance.type
  key_name      = var.instance.aws_ssh_key_name

  subnet_id                   = var.subnet_id
  vpc_security_group_ids = [aws_security_group.main.id]
  associate_public_ip_address = var.instance.associate_public_ip_address

  root_block_device {
    delete_on_termination = true
    kms_key_id            = null
    volume_size           = var.instance.storage.size
    volume_type           = var.instance.storage.type
  }

  private_dns_name_options {
    enable_resource_name_dns_a_record = false
    hostname_type                     = "resource-name"
  }
}
data "aws_subnet" "main" {
  id = var.subnet_id
}
resource "aws_ebs_volume" "main" {
  count = length(var.instance.storage.additional_volumes)
  availability_zone = data.aws_subnet.main.availability_zone
  type              = var.instance.storage.additional_volumes[count.index].type
  size              = var.instance.storage.additional_volumes[count.index].size
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_volume_attachment" "main" {
  count = length(var.instance.storage.additional_volumes)
  device_name = var.instance.storage.additional_volumes[count.index].device_name
  volume_id   = aws_ebs_volume.main[count.index].id
  instance_id = aws_instance.main.id
}

data "local_file" "key" {
  count    = var.instance.use_existing_aws_ssh_key ? 0 : 1
  filename = var.user_key_path.public
}

resource "aws_key_pair" "main" {
  count      = var.instance.use_existing_aws_ssh_key ? 0 : 1
  key_name   = var.instance.aws_ssh_key_name
  public_key = data.local_file.key[0].content
}

resource "aws_security_group" "main" {
  name        = "sg_for_instance_${var.instance.name}"
  description = "Security group for allowing communication for EC2 instance"
  vpc_id      = var.vpc_id

  dynamic "egress" {
    for_each = {
      for egr in var.instance.security_groups_rules.egress : egr.to_port => {
        from_port        = egr.from_port
        to_port          = egr.to_port
        protocol         = egr.protocol
        cidr_blocks      = egr.cidr_blocks
        ipv6_cidr_blocks = egr.ipv6_cidr_blocks
      }
    }
    content {
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
    }
  }
}

resource "aws_security_group_rule" "main" {
  for_each = {
    for ing in var.instance.security_groups_rules.ingress : ing.from_port => {
      from_port   = ing.from_port
      to_port     = ing.to_port
      protocol    = ing.protocol
      cidr_blocks = ing.cidr_blocks
    }
  }
  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  security_group_id = aws_security_group.main.id
}

resource "aws_lb_target_group_attachment" "main" {
  count = length(var.instance.lb_tg_attachment)
  target_group_arn = var.instance.lb_tg_attachment[count.index].arn
  target_id        = aws_instance.main.id
  port             = var.instance.lb_tg_attachment[count.index].target_port
}

resource "local_file" "instance_hosts" {
#   count           = var.create_ansible_hosts ? 1 : 0
  filename        = "${var.instance.name}/hosts"
  file_permission = "0600"
  content         = <<EOT
[${var.instance.name}]
${aws_instance.main.private_dns}  ansible_host=${var.use_custom_ip_port ? var.custom_instance_ip : coalesce(aws_eip.main[0].public_ip, aws_instance.main.private_ip) } ansible_port=${var.use_custom_ip_port ? var.custom_instance_ssh_port : 22}

[${var.instance.name}:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_extra_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
ansible_user=${var.instance.user}
aws_region=${var.add_iam_creds_to_hosts ? var.region : "null"}
aws_access_key=${var.add_iam_creds_to_hosts ? aws_iam_access_key.main.id : "null"}
aws_secret_key=${var.add_iam_creds_to_hosts ? aws_iam_access_key.main.secret : "null"}
EOT
}