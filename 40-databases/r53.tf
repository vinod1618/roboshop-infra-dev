resource "aws_route53_record" "mongodb" {
  zone_id = var.zone_id # Replace with your Hosted Zone ID
  name    = "mongodb-${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = 1
  records = [aws_instance.mongodb.private_Ip]
  allow_overwrite = true
}



resource "aws_route53_record" "redis" {
  zone_id = var.zone_id # Replace with your Hosted Zone ID
  name    = "redis-${var.environment}.${var.domain_name}"
  type    = "A"
  ttl     = 1
  records = [aws_instance.redis.private_Ip]
  allow_overwrite = true
}