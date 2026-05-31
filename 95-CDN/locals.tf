locals {
    caching_disabled = data.aws_cloudfront_cache_policy.caching_disabled.id
    caching_optimized = data.aws_cloudfront_cache_policy.caching_optimized.id
    frontend_alb_certificate_arn = data.aws_ssm_parameter.frontend_alb_certificate_arn.value



    common_tags = {
        Project = var.project
        Environment = var.environment
        Terraform = true
        }
}