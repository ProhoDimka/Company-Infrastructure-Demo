resource "aws_lb_target_group_attachment" "k8s_api_server" {
  for_each = {
    for k, v in aws_instance.k8s_masters :
    k => v
  }
  target_group_arn = var.k8s.loadbalancer.target_groups.api_server_tg_arn
  target_id        = each.value.id
  port             = 6443
}

resource "aws_lb_target_group_attachment" "k8s_ingress_http" {
  for_each = {
    for k, v in aws_instance.k8s_workers :
    k => v
  }
  target_group_arn = var.k8s.loadbalancer.target_groups.ingress_http_tg_arn
  target_id        = each.value.id
  port             = 30080
}

resource "aws_lb_target_group_attachment" "k8s_ingress_https" {
  for_each = {
      for k, v in aws_instance.k8s_workers :
    k => v
  }
  target_group_arn = var.k8s.loadbalancer.target_groups.ingress_https_tg_arn
  target_id        = each.value.id
  port             = 30443
}

resource "aws_lb_target_group_attachment" "k8s_postgresql_main" {
  for_each = {
      for k, v in aws_instance.k8s_workers :
    k => v
  }
  target_group_arn = var.k8s.loadbalancer.target_groups.postgresql_main_tg_arn
  target_id        = each.value.id
  port             = 32432
}