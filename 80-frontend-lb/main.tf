resource "aws_lb" "frontend-alb" {
  name               = "${var.project}-${var.environment}-frontend"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [local.frontend_alb_sg_id]
  subnets            = local.public_subnet_ids

# keeping it as false, just to delete using terraform while practicing
  enable_deletion_protection = false

  tags = merge(local.common_tags,
  {
    Name = "${var.project}-${var.environment}-frontend"
  })

}



resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.frontend-alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.frontend_alb_certificate_arn


   default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "Hi i am https frontend alb"
      status_code  = "200"
    }
  }
}


resource "aws_route53_record" "backend-alb" {
  zone_id = var.zone_id
  name    = "*.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.frontend-alb.dns_name
    zone_id                = aws_lb.frontend-alb.zone_id
    evaluate_target_health = true
  }
  allow_overwrite = true
}