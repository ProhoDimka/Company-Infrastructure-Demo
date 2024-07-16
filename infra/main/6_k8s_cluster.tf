module "k8s_cluster_1_29_6" {
  source = "../../modules/k8s_cluster"

  region = var.region
  vpc_id = module.vpc_default.vpc_id
  subnet_ids = [module.vpc_default.vpc_subnets_private[0].id] # better the same amount of subnets loadbalancer has

  additional_cidr_blocks_for_ingress_rules = [] # for example - vpn clients
  k8s = {
    loadbalancer = {
      dns_name   = module.lb_public_common.lb_dns_name
      private_ip = module.lb_public_common.lb_private_ip
      private_ip_list = module.lb_public_common.lb_private_ips
      public_ip  = module.lb_public_common.lb_public_ip
      # It should be collection in k8s.cluster.instances.*.target_groups and iterate aws_lb_target_group_attachment
      #   with setproduct(aws_instance.k8s_workers, var.k8s.cluster.instances.workers.target_groups)
      # Docs:
      # https://developer.hashicorp.com/terraform/language/functions/setproduct
      # https://stackoverflow.com/questions/76252852/terraform-setproduct-where-values-from-both-lists-are-only-known-after-apply
      target_groups = {
        api_server_tg_arn    = module.lb_public_common.lb_target_groups_map["apiserver"].arn
        ingress_http_tg_arn  = module.lb_public_common.lb_target_groups_map["ingress-http"].arn
        ingress_https_tg_arn = module.lb_public_common.lb_target_groups_map["ingress-https"].arn
        postgresql_main_tg_arn = module.lb_public_common.lb_target_groups_map["postgresql-main"].arn
      }
    }
    s3 = {
      bucket_name = ""
    }
    cluster = {
      name     = var.cluster_name
      dns_name = module.account_dns_zone.zone_id_name
      version = {
        major = "1"
        minor = "29"
        patch = "6"
      }
      instances = {
        master = {
          quantity = 1
          type     = "t4g.small"
          user     = "ubuntu"
          aws_ami_id = var.ami_id # 1.29.6
          aws_ssh_key_name = ""                     # Don't use it - not necessary, because we prepared image with keys
          storage = {
            size = 30
            type = "gp2"
          }
          # Additional SG
          security_groups_ids = []
        }
        worker = {
          quantity = 2
          type     = "t4g.medium"
          user     = "ubuntu"
          aws_ami_id = var.ami_id # 1.29.6
          aws_ssh_key_name = ""                     # Don't use it - not necessary, because we prepare image with keys
          storage = {
            size = 20
            type = "gp2"
          }
          # Additional SG
          security_groups_ids = []
        }
      }
    }
  }
}
