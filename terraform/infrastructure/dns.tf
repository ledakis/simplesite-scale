resource "aws_route53_zone" "main" {
  name = "${var.aws_subdomain}.${var.cloudflare_zone}"
}

## cloudflare top level domain.

resource "cloudflare_record" "aws_ns" {
  count   = length(aws_route53_zone.main.name_servers)
  zone_id = data.cloudflare_zones.master.zones.0.id
  name    = var.aws_subdomain
  value   = aws_route53_zone.main.name_servers[count.index]
  type    = "NS"
  ttl     = 300
}

data "cloudflare_zones" "master" {
  filter {
    name   = var.cloudflare_zone
    status = "active"
    paused = false
  }
}
