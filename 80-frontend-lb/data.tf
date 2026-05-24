data "aws_ssm_parameter" "frontend_sg_id" {
  name  = "/${var.project}/${var.environment}/frontend_sg_id"
}


data "aws_ssm_parameter" "public_subnet_ids" {
  name  = "/${var.project}/${var.environment}/public_subnet_id"
}


data "aws_ssm_parameter" "frontend_alb_certificate_arn" {
  name  = "/${var.project}/${var.environment}/frontend_alb_certificate_arn"
}