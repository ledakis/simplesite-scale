resource "aws_ecs_cluster" "cluster" {
  name = "${var.service_name}-ecs-cluster"
}

locals {
  app_ecr_url = length(var.app_repo_url) > 0 ? var.app_repo_url : data.terraform_remote_state.infrastructure.outputs.ecr_url
}


resource "aws_ecs_task_definition" "service" {
  family                   = var.service_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_definition_role.arn
  container_definitions    = <<EOF
[
    {
        "name": "${var.service_name}",
        "image": "${local.app_ecr_url}",
        "portMappings": [
            {
                "containerPort": 80,
                "hostPort": 80
            }
        ],
        "memory": 300,
        "networkMode": "awsvpc"
    }
]
EOF
}

resource "aws_ecs_service" "site" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 3
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.terraform_remote_state.infrastructure.outputs.private_subnets
    security_groups = aws_security_group.ecs_service.*.id
  }

  load_balancer {
    target_group_arn = module.alb.target_group_arns[0]
    container_name   = var.service_name
    container_port   = 80
  }

  depends_on = [
    module.alb
  ]

}

resource "aws_security_group" "ecs_service" {
  name        = "${var.service_name}-${local.randomness}"
  description = "ECS cluster security group"
  vpc_id      = data.terraform_remote_state.infrastructure.outputs.vpc_id
}

resource "aws_security_group_rule" "ecs_in_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ecs_service.id
}

resource "aws_security_group_rule" "ecs_out" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_service.id
}
