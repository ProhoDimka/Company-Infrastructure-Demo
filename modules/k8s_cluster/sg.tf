data "aws_subnet" "k8s_cluster" {
  count = length(var.subnet_ids)
  id = var.subnet_ids[count.index]
}

resource "aws_security_group" "k8s_cluster" {
  name        = "k8s_sg_${var.k8s.cluster.name}_${local.k8s_cluster_version}"
  description = "Security group for allowing TCP communication for Kubernetes"
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Full connectivity between nodes in cluster
#   ingress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = [for subnet in data.aws_subnet.k8s_cluster : subnet.cidr_block]
# #     ipv6_cidr_blocks = [for subnet in data.aws_subnet.k8s_cluster : subnet.ipv6_cidr_block]
#   }

}

# # Allow full connectivity between nodes in cluster
# resource "aws_security_group_rule" "ingress_cluster" {
#   type              = "ingress"
#   from_port         = 0
#   to_port           = 0
#   protocol          = "-1"
#   cidr_blocks      = [for subnet in data.aws_subnet.k8s_cluster : subnet.cidr_block]
#   security_group_id = aws_security_group.k8s_cluster.id
# }

# Allow tcp on port 22 for IPv4 within security group (ssh)
resource "aws_security_group_rule" "ingress_for_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = concat([data.aws_vpc.k8s.cidr_block], tolist(var.additional_cidr_blocks_for_ingress_rules))
  security_group_id = aws_security_group.k8s_cluster.id
}

# Allow tcp on port 2379-2380 for IPv4 within security group (etcd)
resource "aws_security_group_rule" "ingress_for_etcd" {
  type              = "ingress"
  from_port         = 2378
  to_port           = 2380
  protocol          = "tcp"
  cidr_blocks       = concat([data.aws_vpc.k8s.cidr_block], tolist(var.additional_cidr_blocks_for_ingress_rules))
  security_group_id = aws_security_group.k8s_cluster.id
}

# Allow tcp on port 6443 for IPv4 within security group (API server)
resource "aws_security_group_rule" "ingress_for_apiserver" {
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  cidr_blocks       = concat([data.aws_vpc.k8s.cidr_block], tolist(var.additional_cidr_blocks_for_ingress_rules))
  security_group_id = aws_security_group.k8s_cluster.id
}

# Allow tcp on port 10250 for IPv4 within security group (Kubelet API)
resource "aws_security_group_rule" "ingress_for_kublet" {
  type              = "ingress"
  from_port         = 10250
  to_port           = 10250
  protocol          = "tcp"
  cidr_blocks       = concat([data.aws_vpc.k8s.cidr_block], tolist(var.additional_cidr_blocks_for_ingress_rules))
  security_group_id = aws_security_group.k8s_cluster.id
}

# Allow tcp on port 10257 for IPv4 within security group (kube-controller-manager)
resource "aws_security_group_rule" "ingress_for_kube_control" {
  type              = "ingress"
  from_port         = 10257
  to_port           = 10257
  protocol          = "tcp"
  cidr_blocks       = concat([data.aws_vpc.k8s.cidr_block], tolist(var.additional_cidr_blocks_for_ingress_rules))
  security_group_id = aws_security_group.k8s_cluster.id
}

# Allow tcp on port 10259 for IPv4 within security group (kube-scheduler)
resource "aws_security_group_rule" "ingress_for_scheduler" {
  type              = "ingress"
  from_port         = 10259
  to_port           = 10259
  protocol          = "tcp"
  cidr_blocks       = concat([data.aws_vpc.k8s.cidr_block], tolist(var.additional_cidr_blocks_for_ingress_rules))
  security_group_id = aws_security_group.k8s_cluster.id
}

# Allow tcp on port 30000-32767 for IPv4 within security group (NodePort Services)
resource "aws_security_group_rule" "ingress_for_nodeport" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "-1"
  cidr_blocks       = concat([data.aws_vpc.k8s.cidr_block], tolist(var.additional_cidr_blocks_for_ingress_rules))
  security_group_id = aws_security_group.k8s_cluster.id
}