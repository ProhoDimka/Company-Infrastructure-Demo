resource "aws_lb" "main" {
  name                             = var.lb_name
  internal                         = false
  load_balancer_type               = "network"
  enable_deletion_protection       = var.lb_enable_deletion_protection
  enable_cross_zone_load_balancing = true

  dynamic "subnet_mapping" {
    for_each = var.lb_has_allocated_eip ? {
      for subnet in var.subnet_ids : subnet => {
        subnet = subnet
      }
    } : {}
    content {
      subnet_id     = subnet_mapping.value.subnet
      allocation_id = aws_eip.main[index(var.subnet_ids, subnet_mapping.value.subnet)].id
    }
  }
}

resource "aws_eip" "main" {
  count            = var.lb_has_allocated_eip ? length(var.subnet_ids) : 0
  domain           = "vpc"
  public_ipv4_pool = "amazon"
}

resource "aws_lb_target_group" "main" {
  for_each                          = var.lb_target_groups
  name                              = each.key
  port                              = each.value.port
  protocol                          = each.value.protocol
  proxy_protocol_v2                 = false
  target_type                       = each.value.target_type
  vpc_id                            = var.vpc_id
  preserve_client_ip                = false
  load_balancing_cross_zone_enabled = true

  dynamic "health_check" {
    for_each = each.value.health_check.enabled ? [0] : []
    content {
      enabled             = each.value.health_check.enabled
      healthy_threshold   = each.value.health_check.healthy_threshold
      unhealthy_threshold = each.value.health_check.unhealthy_threshold
      interval            = each.value.health_check.interval
      protocol            = each.value.health_check.protocol
      matcher             = each.value.health_check.matcher
      path                = each.value.health_check.path
      timeout             = each.value.health_check.timeout
    }
  }

  dynamic "health_check" {
    for_each = each.value.health_check.enabled ? [] : [0]
    content {
      enabled = false
    }
  }

  target_health_state {
    enable_unhealthy_connection_termination = true
  }
}

resource "aws_lb_listener" "main" {
  for_each = {
    for k, v in aws_lb_target_group.main : k => v
  }
  load_balancer_arn = aws_lb.main.arn
  port              = var.lb_target_groups[each.value.name].lb_listener_port
  protocol          = var.lb_target_groups[each.value.name].protocol

  default_action {
    target_group_arn = each.value.arn
    type             = "forward"
  }

  depends_on = [aws_lb_target_group.main]
}
