resource "aws_ssm_parameter" "aws_lb_listener" {
  name  = "/${var.project}/${var.environment}/aws_lb_listener"
  type  = "String"
  value = aws_lb_listener.https.arn
}