module "account_dns_zone" {
  source                   = "../../modules/dns_zone"
  account_domain_init_name = var.account_domain_init_name
  account_domain_ns_ttl = 3600
  zone_records = [
    {
      name    = "www.example-domain.com"
      type    = "CNAME"
      ttl = 3600
      records = ["example-domain.com."]
    }
  ]
}