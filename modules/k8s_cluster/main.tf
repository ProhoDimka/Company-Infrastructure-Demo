locals {
  k8s_cluster_version      = "${var.k8s.cluster.version.major}_${var.k8s.cluster.version.minor}_${var.k8s.cluster.version.patch}"
  k8s_cluster_version_dots = "${var.k8s.cluster.version.major}.${var.k8s.cluster.version.minor}.${var.k8s.cluster.version.patch}"
}

data "aws_vpc" "k8s" {
  id = var.vpc_id
}

resource "aws_placement_group" "k8s_masters" {
  name         = "k8s_mstr_pg_${var.k8s.cluster.name}_${local.k8s_cluster_version}"
  strategy     = "spread"
  spread_level = "rack"
}

resource "aws_placement_group" "k8s_workers" {
  name         = "k8s_wrkr_pg_${var.k8s.cluster.name}_${local.k8s_cluster_version}"
  strategy     = "spread"
  spread_level = "rack"
}

resource "aws_instance" "k8s_masters" {
  count                       = var.k8s.cluster.instances.master.quantity
  ami                         = var.k8s.cluster.instances.master.aws_ami_id
  instance_type               = var.k8s.cluster.instances.master.type
  associate_public_ip_address = false
  key_name                    = var.k8s.cluster.instances.master.aws_ssh_key_name
  placement_group             = aws_placement_group.k8s_masters.id

  subnet_id = element(var.subnet_ids, count.index)
  vpc_security_group_ids = concat(var.k8s.cluster.instances.master.security_groups_ids, [aws_security_group.k8s_cluster.id])

  root_block_device {
    delete_on_termination = true
    kms_key_id            = null
    volume_size           = var.k8s.cluster.instances.master.storage.size
    volume_type           = var.k8s.cluster.instances.master.storage.type
  }

  private_dns_name_options {
    enable_resource_name_dns_a_record = true
    hostname_type                     = "resource-name"
  }

  tags = {
    k8s_node_type = "master"
  }
}

resource "aws_instance" "k8s_workers" {
  count                       = var.k8s.cluster.instances.worker.quantity
  ami                         = var.k8s.cluster.instances.master.aws_ami_id
  instance_type               = var.k8s.cluster.instances.worker.type
  associate_public_ip_address = false
  key_name                    = var.k8s.cluster.instances.worker.aws_ssh_key_name
  placement_group             = aws_placement_group.k8s_masters.id

  subnet_id = element(var.subnet_ids, count.index)
  vpc_security_group_ids = concat(var.k8s.cluster.instances.worker.security_groups_ids, [aws_security_group.k8s_cluster.id])

  root_block_device {
    delete_on_termination = true
    kms_key_id            = null
    volume_size           = var.k8s.cluster.instances.worker.storage.size
    volume_type           = var.k8s.cluster.instances.worker.storage.type
  }

  private_dns_name_options {
    enable_resource_name_dns_a_record = true
    hostname_type                     = "resource-name"
  }

  tags = {
    k8s_node_type = "workers"
  }
}
# ansible_ssh_private_key_file=${var.user_key_path.private}
resource "local_file" "ansible_inventory" {
  content = <<EOT
[masters]
%{ for master_instance in aws_instance.k8s_masters[*] }${master_instance.private_dns} ansible_host=${master_instance.private_ip}
%{ endfor }
[workers]
%{ for master_instance in aws_instance.k8s_workers[*] }${master_instance.private_dns} ansible_host=${master_instance.private_ip}
%{ endfor }
[all:vars]
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_extra_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
k8s_cluster_name=${var.k8s.cluster.name}
k8s_cluster_lb_host=${var.k8s.loadbalancer.dns_name}
k8s_version_major=${var.k8s.cluster.version.major}
k8s_version_minor=${var.k8s.cluster.version.minor}
k8s_version_patch=${var.k8s.cluster.version.patch}
[masters:vars]
ansible_user=${var.k8s.cluster.instances.master.user}
[workers:vars]
ansible_user=${var.k8s.cluster.instances.worker.user}
EOT

  file_permission = "0600"
  filename        = "k8s_cluster/${local.k8s_cluster_version_dots}.hosts"
}

resource "local_file" "master_init_env" {
  count = length(aws_instance.k8s_masters) > 0 ? 1 : 0
  content = <<EOT
# export K8S_MASTER_IP=${length(aws_instance.k8s_masters) > 0 ? aws_instance.k8s_masters[0].private_ip : ""}
export K8S_AWS_REGION=${var.region}
export K8S_CLUSTER_NAME=${var.k8s.cluster.name}
export K8S_LB_IP_INT=${var.k8s.loadbalancer.private_ip}
export K8S_LB_IP_INT_LIST=${join(",", var.k8s.loadbalancer.private_ip_list)}
export K8S_LB_IP_EXT=${var.k8s.loadbalancer.public_ip}
export K8S_LB_DNS=${var.k8s.loadbalancer.dns_name}
export K8S_IP_DNS1=k8s.${var.k8s.cluster.dns_name}
export K8S_IP_DNS2=${var.k8s.cluster.name}.k8s.${var.k8s.cluster.dns_name}
export K8S_MAIN_VERSION=${local.k8s_cluster_version_dots}
EOT

  file_permission = "0600"
  filename        = "k8s_cluster/.init.env"
}