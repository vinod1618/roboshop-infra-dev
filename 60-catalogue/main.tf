#Mongodb

resource "aws_instance" "catalogue" {
  ami           = local.ami_id
  instance_type = "t3.micro"
  subnet_id = local.private_subnet_id
  vpc_security_group_ids = [local.catalogue_sg_id]

  tags = merge (
    {
        Name = "${var.project}-${var.environment}-catalogue"
    },
    local.common_tags

  )
}

resource "terraform_data" "catalogue" {
  triggers_replace = [
    aws_instance.catalogue.id
    
    ]

    connection {
    type = "ssh"
    user = "ec2-user"
    password = "DevOps321"
    host = aws_instance.catalogue.private_ip
  }

    provisioner "file" {
    source      = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

    provisioner "remote-exec" {
    inline = [
        "chmod +x /tmp/bootstrap.sh",
        "sudo sh /tmp/bootstrap.sh catalogue dev"
    ]
  }
}

resource "aws_ec2_instance_state" "catalogue" {
  instance_id = aws_instance.catalogue.id
  state       = "stopped" # Change to "running" to start it back up
  depends_on = [terraform_data.catalogue]
}


resource "aws_ami_from_instance" "catalogue" {
  name               = "${var.project}-${var.environment}-catalogue"
  source_instance_id = aws_instance.catalogue.id
  depends_on = [aws_ec2_instance_state.catalogue] 
  tags = merge (
    {
        Name = "${var.project}-${var.environment}-catalogue"
    },
    local.common_tags

  )
}

# target group creation

resource "aws_lb_target_group" "catalogue" {
  name     = "${var.project}-${var.environment}-catalogue"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  deregistration_delay = 60
  health_check {
    healthy_threshold = 2
    interval = 10
    matcher = "200-299"
    path = "/health"
    protocol = "HTTP"
    timeout = 2
    unhealthy_threshold = 3
  }
}

# launch template



resource "aws_launch_template" "catalogue" {
  name = "${var.project}-${var.environment}-catalogue"
  image_id = aws_ami_from_instance.catalogue.id
  instance_initiated_shutdown_behavior = "terminate"
  
  # Once auto scaling sees less traffic, it will terminate the instance

  instance_type = "t3.micro"
  vpc_security_group_ids = [local.catalogue_sg_id]
# each time we apply terraform this version will update as default
  update_default_version = true

# tags for instances created by launch teamplate

  tag_specifications {
    resource_type = "instance"
    tags = merge (
    {
        Name = "${var.project}-${var.environment}-catalogue"
    },
    local.common_tags

  )
  }
# tags for volume

  tag_specifications {
    resource_type = "volume"
    tags = merge (
    {
        Name = "${var.project}-${var.environment}-catalogue"
    },
    local.common_tags

  )
  }

  tags = merge (
    {
        Name = "${var.project}-${var.environment}-catalogue"
    },
    local.common_tags

  )

}


# Autoscaling group

resource "aws_autoscaling_group" "catalogue" {
  name                      = "${var.project}-${var.environment}-catalogue"
  max_size                  = 10
  min_size                  = 1
  health_check_grace_period = 120
  health_check_type         = "ELB"
  desired_capacity          = 1
  force_delete              = false
  target_group_arns = [aws_lb_target_group.catalogue.arn]

  launch_template {
    id      = aws_launch_template.catalogue.id
    version = "$Latest"
  }
  vpc_zone_identifier       = [local.private_subnet_id]

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.environment}-catalogue"
    propagate_at_launch = true
  }

# within 15 min autoscaling should be successful. This block is a safeguard that tells Terraform:
# “When deleting this Auto Scaling Group, be patient for up to 15 minutes before failing.

  timeouts {
    delete = "15m"
  }
}


#Autoscalaning policy


resource "aws_autoscaling_policy" "catalogue" {
  name                   = "${var.project}-${var.environment}-catalogue"
  autoscaling_group_name = aws_autoscaling_group.catalogue.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value              = 70.0
  }
}


resource "aws_lb_listener_rule" "redirect_http_to_https" {
  listener_arn = local.backend_listener_arn
  priority = 10
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.catalogue.arn
  }

  condition {
    host_header {
      values           = ["catalogue.backend_alb-${var.environment}.${var.domain_name}"]
    }
  }
}

# destroying the instance which is used for creating the AMI


resource "terraform_data" "catalogue_delete" {
  depends_on = [aws_autoscaling_policy.catalogue]
  triggers_replace = [aws_instance.catalogue.id]
    provisioner "local-exec" {
      command = "aws ec2 terminate-instances ${aws_instance.catalogue.id}"
  }
}