resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 12
  min_capacity       = 3
  resource_id        = "service/${var.service_name}-ecs-cluster/${aws_ecs_service.site.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_scale_policy" {
  name               = "ecs_scale"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = 30
    disable_scale_in   = false
    scale_in_cooldown  = 60
    scale_out_cooldown = 60
    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${module.alb.this_lb_arn_suffix}/${module.alb.target_group_arn_suffixes.0}"
    }
  }
}
