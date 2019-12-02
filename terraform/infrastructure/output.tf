output "ecr_url" {
  value = aws_ecr_repository.simplesite.repository_url
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "certificate_arn" {
  value = module.certificate.this_acm_certificate_arn
}

output "s3_logs_bucket_name" {
  value = aws_s3_bucket.logs.bucket
}

output "route_53_zone" {
  value = aws_route53_zone.main.zone_id
}
