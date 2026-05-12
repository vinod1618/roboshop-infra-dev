resource "aws_iam_role" "mysql" {
  name = local.my_sql_role_name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge (
    {
        Name = local.my_sql_role_name
    },
    local.common_tags
  )
}


resource "aws_iam_policy" "mysql" {
  name        = "RoboshopMySqlParameter"
  description = "A policy for mysql EC2 instance"
  policy      = file("my-sql-iam-policy.json")
}


resource "aws_iam_role_policy_attachment" "mysql" {
  role       = aws_iam_role.mysql.name
  policy_arn = aws_iam_policy.mysql.arn
}


resource "aws_iam_instance_profile" "mysql" {
  name = "${var.project}-${var.environment}-mysql"
  role = aws_iam_role.mysql.name
}