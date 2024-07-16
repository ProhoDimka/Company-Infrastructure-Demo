module "lb_public_common" {
  source               = "../../modules/lb_public"
  region               = var.region
  vpc_id               = module.vpc_default.vpc_id
  subnet_ids = [module.vpc_default.vpc_subnets_public[0].id]
  zone_id_for_dns_record = module.account_dns_zone.zone_id

  zone_records = [
    {
      zone_id = module.account_dns_zone.zone_id
      name    = module.account_dns_zone.zone_id_name
      ttl     = 3600
    },
    {
      zone_id = module.account_dns_zone.zone_id
      name    = "*.k8s.${module.account_dns_zone.zone_id_name}"
      ttl     = 3600
    },
    {
      zone_id = module.account_dns_zone.zone_id
      name    = "*.api.${module.account_dns_zone.zone_id_name}"
      ttl     = 3600
    }
  ]

  lb_name              = "lb-main-common"
  ld_custom_domain_name = "*.${module.account_dns_zone.zone_id_name}"
  lb_has_allocated_eip = true
  lb_target_groups = {
    "ingress-http" = {
      name             = "ingress-http"
      port             = 30080
      lb_listener_port = 80
      protocol         = "TCP"
      target_type      = "instance"
      health_check = {
        enabled             = true
        healthy_threshold   = 2
        unhealthy_threshold = 3
        interval            = 10
        protocol            = "TCP"
        matcher             = null
        path                = null
        timeout             = 5
      }
    }
    "ingress-https" = {
      name             = "ingress-https"
      port             = 30443
      lb_listener_port = 443
      protocol         = "TCP"
      target_type      = "instance"
      health_check = {
        enabled             = true
        healthy_threshold   = 2
        unhealthy_threshold = 3
        interval            = 10
        protocol            = "TCP"
        matcher             = null
        path                = null
        timeout             = 5
      }
    }
    "postgresql-main" = {
      name             = "postgresql-main"
      port             = var.pg_node_port_main
      lb_listener_port = 5432
      protocol         = "TCP"
      target_type      = "instance"
      health_check = {
        enabled             = true
        healthy_threshold   = 2
        unhealthy_threshold = 3
        interval            = 10
        protocol            = "TCP"
        matcher             = null
        path                = null
        timeout             = 5
      }
    }
    "apiserver" = {
      name             = "apiserver"
      port             = 6443
      lb_listener_port = 6443
      protocol         = "TCP"
      target_type      = "instance"
      health_check = {
        enabled             = true
        healthy_threshold   = 2
        unhealthy_threshold = 2
        interval            = 5
        protocol            = "HTTPS"
        matcher             = "200"
        path                = "/livez"
        timeout             = 3
      }
    }
  }
}