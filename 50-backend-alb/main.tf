resource "aws_lb" "backend-alb" {
  name               = "${var.project}-${var.environment}-catalogue"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [local.backend_alb_sg_id]
  subnets            = local.private_subnet_ids

# keeping it as false, just to delete using terraform while practicing
  enable_deletion_protection = false

  tags = merge(local.common_tags,
  {
    Name = "${var.project}-${var.environment}"
  })

}



resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.backend.arn
  port              = "80"
  protocol          = "HTTP"

   default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "Hi this is vinod"
      status_code  = "200"
    }
  }
}


resource "aws_route53_record" "backend-alb" {
  zone_id = var.zone_id
  name    = "*.backend-alb-${var.environment}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.backend_alb.dns_name
    zone_id                = aws_lb.backend_alb.zone_id
    evaluate_target_health = true
  }
}