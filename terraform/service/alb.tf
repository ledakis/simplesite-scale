resource "aws_route53_record" "site" {
  zone_id = data.terraform_remote_state.infrastructure.outputs.route_53_zone
  name    = "site"
  type    = "A"

  alias {
    name                   = module.alb.this_lb_dns_name
    zone_id                = module.alb.this_lb_zone_id
    evaluate_target_health = false
  }
}

module "alb" {
  source             = "terraform-aws-modules/alb/aws"
  version            = "~> 5.0"
  name               = "site"
  load_balancer_type = "application"
  vpc_id             = data.terraform_remote_state.infrastructure.outputs.vpc_id
  subnets            = data.terraform_remote_state.infrastructure.outputs.public_subnets
  security_groups    = [aws_security_group.alb.id]

  access_logs = {
    bucket = data.terraform_remote_state.infrastructure.outputs.s3_logs_bucket_name
  }
  target_groups = [
    {
      name_prefix      = "site"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "ip"
    }
  ]
  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = data.terraform_remote_state.infrastructure.outputs.certificate_arn
      target_group_index = 0
    }
  ]

}

resource "aws_security_group" "alb" {
  name        = "${var.service_name}-ingress"
  description = "Allow from internet to ALB"
  vpc_id      = data.terraform_remote_state.infrastructure.outputs.vpc_id
}

resource "aws_security_group_rule" "alb_in" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_out" {
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_service.id
  security_group_id        = aws_security_group.alb.id
}
