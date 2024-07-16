module "vpc_default" {
  source                              = "../../modules/vpc_default"
  default_vpc_id                      = var.vpc_id
  region                              = var.region
  create_private_subnets_route_to_nat = true
  create_private_subnets_counter      = 1
  create_nat_gw                       = true
  nat_gw_subnets_count                = 1
}