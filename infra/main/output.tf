output "dns_zone_ns" {
  value = module.account_dns_zone.name_servers
}

output "lb_dns_name" {
  value = module.lb_public_common.lb_dns_name
}

output "lb_target_groups_map" {
  value = module.lb_public_common.lb_target_groups_map
}

output "k8s_s3_bucket_backups" {
  value = module.k8s_cluster_equipment.s3_bucket_for_backups_name.s3_bucket_backups
}


output "k8s_iam_user_name" {
  value = module.k8s_cluster_equipment.k8s_iam_user_name
}