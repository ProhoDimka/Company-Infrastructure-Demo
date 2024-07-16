variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "vpc_id" {
  type    = string
  default = "vpc-23d2204a"
}

variable "subnet_ids" {
  type = list(string)
  default = ["subnet-bee6d9f4", "subnet-905fa3f9", "subnet-9d9855e6"]
}

variable "lb_name" {
  type    = string
  default = "lb-1"
}

variable "lb_enable_deletion_protection" {
  type    = bool
  default = false
}

variable "lb_has_allocated_eip" {
  description = "Has LoadBalancer public IP for allocation"
  type        = bool
  default     = true
}

variable "zone_id_for_dns_record" {
  description = "DNS Zone ID for DNS A-type record"
  type        = string
  default     = ""
}

variable "ld_custom_domain_name" {
  description = "DNS Zone ID for DNS A-type record"
  type        = string
  default     = ""
}

variable "zone_records" {
  description = "Hosted zone records! Warning for conflicts in case associate_public_ip_address = true"
  type = list(
    object({
      zone_id = string
      name    = string
      ttl     = number
    }))
  default = []
}

variable "lb_target_groups" {
  description = "LoadBalancer target groups"
  type = map(object({
    name             = string
    port             = number
    lb_listener_port = number
    protocol         = string
    target_type      = string
    health_check = object({
      enabled             = bool
      healthy_threshold   = number
      unhealthy_threshold = number
      interval            = number
      protocol            = string
      matcher             = string
      path                = string
      timeout             = number
    })
  }))
  default = {
    "apiserver" = {
      name             = "apiserver"
      port             = 6443
      lb_listener_port = 6443
      protocol         = "TCP"
      target_type      = "instance"
      health_check = {
        enabled             = true
        healthy_threshold = 2         # default 3
        unhealthy_threshold = 2
        interval = 10        # default 30
        protocol            = "HTTPS"
        matcher = "200"     # default 200
        path                = "/livez"
        timeout             = 5         # default 30
      }
    }
    "gitlab-ssh" = {
      name             = "gitlab-ssh"
      port             = 22
      lb_listener_port = 22
      protocol         = "TCP"
      target_type      = "instance"
      health_check = {
        enabled             = false
        healthy_threshold   = 0
        unhealthy_threshold = 0
        interval            = 0
        protocol            = ""
        matcher             = ""
        path                = ""
        timeout             = 0
      }
    }
    "gitlab-https" = {
      name             = "gitlab-https"
      port             = 4433
      lb_listener_port = 4433
      protocol         = "TCP"
      target_type      = "instance"
      health_check = {
        enabled             = false
        healthy_threshold   = 0
        unhealthy_threshold = 0
        interval            = 0
        protocol            = ""
        matcher             = ""
        path                = ""
        timeout             = 0
      }
    }
  }
}

