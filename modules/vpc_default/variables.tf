variable "default_vpc_id" {
  description = "Default VPC id"
  type        = string
  default     = ""
}

variable "region" {
  description = "Region"
  type        = string
  default     = "eu-central-1"
}

variable "create_nat_gw" {
  description = "If necessary to create NAT gateway"
  type        = bool
  default     = false
}

variable "nat_gw_subnets_count" {
  description = "For how many subnets?"
  type        = number
  default     = 0
}

variable "create_private_subnets_counter" {
  description = "How many private subnets you want to create?"
  type        = number
  default     = 0
}

variable "create_private_subnets_route_to_nat" {
  description = "route private subnets to internet"
  type        = bool
  default     = false
}