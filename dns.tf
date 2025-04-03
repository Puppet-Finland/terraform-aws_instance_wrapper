resource "aws_route53_record" "private_ipv4" {
  count   = var.hosted_zone_id != "" && var.amount == 1 ? 1 : 0
  zone_id = var.hosted_zone_id
  name    = split(var.hostname, ".")[0]
  type    = "A"
  ttl     = 300
  records = [aws_instance.ec2_instance[0].private_ip]
}
