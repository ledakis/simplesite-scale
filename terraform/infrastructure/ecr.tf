resource "aws_ecr_repository" "simplesite" {
  name = var.service_name
}

data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket" "logs" {
  bucket        = "${var.service_name}-logs"
  acl           = "private"
  force_destroy = true
  tags = {
    Name = "${var.service_name}-logs"
  }
  policy = <<EOF
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.service_name}-logs/AWSLogs/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.main.arn}"
        ]
      }
    }
  ]
}
EOF
}
