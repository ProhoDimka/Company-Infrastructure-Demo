variable "region" {
  description = "Region"
  type        = string
  default     = "eu-central-1"
}

variable "account_domain_init_name" {
  description = "account domain zone name"
  type        = string
  default     = "example-domain.com"
}


variable "account_domain_ns_ttl" {
  description = "account domain zone name main ttl"
  type        = number
  default     = 3600
}

variable "zone_records" {
  description = "account domain zone name"
  type = list(object(
    {
      name = string
      type = string
      ttl  = number
      records = list(string)
    }
  ))
  default = null
}