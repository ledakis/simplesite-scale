output "site_url" {
  value = "https://${aws_route53_record.site.fqdn}"
}
