################################################################################
# VPC
################################################################################

output "region" {
  description = "Region of VPC"
  value       = var.region
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = try(data.aws_vpc.default.id, null)
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = try(data.aws_vpc.default.arn, null)
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = try(data.aws_vpc.default.cidr_block, null)
}

output "default_security_group_ids" {
  description = "The ID of the security group created by default on VPC creation"
  value       = try(data.aws_security_groups.default.ids, null)
}

output "default_network_acl_ids" {
  description = "The ID of the default network ACL"
  value       = try(data.aws_network_acls.default.ids, null)
}

output "default_route_table_ids" {
  description = "The ID of the default route table"
  value       = try(data.aws_route_tables.default.ids, null)
}

output "vpc_instance_tenancy" {
  description = "Tenancy of instances spin up within VPC"
  value       = try(data.aws_vpc.default.instance_tenancy, null)
}

output "vpc_enable_dns_support" {
  description = "Whether or not the VPC has DNS support"
  value       = try(data.aws_vpc.default.enable_dns_support, null)
}

output "vpc_enable_dns_hostnames" {
  description = "Whether or not the VPC has DNS hostname support"
  value       = try(data.aws_vpc.default.enable_dns_hostnames, null)
}

output "vpc_ipv6_association_id" {
  description = "The association ID for the IPv6 CIDR block"
  value       = try(data.aws_vpc.default.ipv6_association_id, null)
}

output "vpc_ipv6_cidr_block" {
  description = "The IPv6 CIDR block"
  value       = try(data.aws_vpc.default.ipv6_cidr_block, null)
}

output "vpc_owner_id" {
  description = "The ID of the AWS account that owns the VPC"
  value       = try(data.aws_vpc.default.owner_id, null)
}

################################################################################
# Subnets
################################################################################

output "vpc_subnets" {
  description = "List of IDs of public subnets"
  value       = data.aws_subnets.default.ids
}

output "vpc_subnets_public" {
  description = "List of public subnets"
  value       = data.aws_subnet.default
}

output "vpc_subnets_private" {
  description = "List of private subnets"
  value       = aws_subnet.private
}

# output "subnet_cidr_blocks" {
#   value = [for s in data.aws_subnet.default : tomap({ "${s.id}" = "${s.cidr_block}" })]
# }
output "subnet_cidr_blocks" {
  value = [for s in data.aws_subnet.default : {
    subnet_id = s.id
    cidr_block = s.cidr_block
  }]
}

################################################################################
# DHCP Options Set
################################################################################

output "dhcp_options_id" {
  description = "The ID of the DHCP options"
  value       = try(data.aws_vpc.default.dhcp_options_id, null)
}

################################################################################
# Internet Gateway
################################################################################

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = try(data.aws_internet_gateway.default.id, null)
}

output "igw_arn" {
  description = "The ARN of the Internet Gateway"
  value       = try(data.aws_internet_gateway.default.arn, null)
}