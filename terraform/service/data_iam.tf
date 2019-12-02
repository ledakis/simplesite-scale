data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  config = {
    bucket = var.infra_state_bucket
    key    = var.infra_state_key
    region = var.region
  }
}

resource "random_id" "target_group_suffix" {
  byte_length = 8
}

locals {
  randomness = random_id.target_group_suffix.hex
}

resource "aws_iam_role" "ecs_task_definition_role" {
  name               = "${var.service_name}-ecs-task-${local.randomness}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_definition_ecs_task_exec" {
  role       = aws_iam_role.ecs_task_definition_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "ecs_task_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
