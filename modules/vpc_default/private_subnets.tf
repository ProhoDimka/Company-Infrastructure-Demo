# create_private_subnets = 1
# create_private_subnets_route_to_nat = true

resource "aws_subnet" "private" {
  count  = var.create_private_subnets_counter
  vpc_id = data.aws_vpc.default.id
  cidr_block = cidrsubnet(data.aws_vpc.default.cidr_block, 4, length(data.aws_availability_zones.available.zone_ids) + count.index)
  availability_zone_id = data.aws_availability_zones.available.zone_ids[count.index]
}

resource "aws_nat_gateway" "main" {
  count         = var.create_nat_gw ? var.nat_gw_subnets_count : 0
  allocation_id = aws_eip.main[count.index].id
  subnet_id     = data.aws_subnet.default[count.index].id
#   subnet_id     = element([
#     for subnet in data.aws_subnet.default : subnet.id
#   ], count.index)
}

resource "aws_eip" "main" {
  count            = var.create_nat_gw ? var.nat_gw_subnets_count : 0
  domain           = "vpc"
  public_ipv4_pool = "amazon"
}

resource "aws_route_table" "private" {
  count = length(aws_nat_gateway.main)
  vpc_id = data.aws_vpc.default.id

  route {
    cidr_block = data.aws_vpc.default.cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block      = "0.0.0.0/0"
#     ipv6_cidr_block = "::/0"
    nat_gateway_id  = aws_nat_gateway.main[count.index].id
  }
}

resource "aws_route_table_association" "private" {
  count = length(aws_route_table.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}