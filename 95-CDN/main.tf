resource "aws_cloudfront_distribution" "roboshop" {
  origin {

   # https://frontend-dev.vinoddevops.online
    domain_name              = "frontend-${var.environment}.${var.domain_name}"
    origin_id                = "frontend-${var.environment}.${var.domain_name}"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only" # CloudFront to ALB communication protocol
      origin_ssl_protocols     = ["TLSv1.2"]
    }

  }

  enabled             = true
  is_ipv6_enabled     = false

# CDN URL : https://roboshop-dev.vinoddevops.online

  aliases = ["${var.project}-${var.environment}.${var.domain_name}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "frontend-${var.environment}.${var.domain_name}"
    cache_policy_id = local.caching_disabled
    viewer_protocol_policy = "https-only"
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/media/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "frontend-${var.environment}.${var.domain_name}"
    cache_policy_id = local.caching_optimized

    viewer_protocol_policy = "https-only"
  }

  # Cache behavior with precedence 1
  ordered_cache_behavior {
    path_pattern     = "/images/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "frontend-${var.environment}.${var.domain_name}"
    cache_policy_id = local.caching_optimized

    viewer_protocol_policy = "https-only"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
      # locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags = merge(local.common_tags,
  {
    Name = "${var.project}-${var.environment}-frontend"
  })


  viewer_certificate {
    acm_certificate_arn = local.frontend_alb_certificate_arn
    ssl_support_method  = "sni-only"
  }
}



resource "aws_route53_record" "cdn" {
  zone_id = var.zone_id
  name    = "${var.project}-${var.environment}.${var.domain_name}"
  type    = "A"

# CDN details

  alias {
    name                   = aws_cloudfront_distribution.roboshop.domain_name
    zone_id                = aws_cloudfront_distribution.roboshop.hosted_zone_id
    evaluate_target_health = true
  }
  allow_overwrite = true
}