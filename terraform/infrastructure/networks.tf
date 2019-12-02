module "vpc" {
  source                  = "terraform-aws-modules/vpc/aws"
  name                    = "ecs_vpc"
  cidr                    = "10.0.0.0/16"
  azs                     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets         = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets          = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  map_public_ip_on_launch = false
  enable_nat_gateway      = true
  single_nat_gateway      = true
  one_nat_gateway_per_az  = false
}

module "certificate" {
  source = "github.com/ledakis/terraform-aws-acm"

  domain_name = "${var.endpoind_name}"
  zone_id     = aws_route53_zone.main.id
}
