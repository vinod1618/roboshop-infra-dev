resource "aws_ssm_parameter" "backend_listener_arn" {
  name  = "/${var.project}/${var.environment}/backend_listener_arn"
  type  = "String"
  value = aws_lb_listener.http.arn
}