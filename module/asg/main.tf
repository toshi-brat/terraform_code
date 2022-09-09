resource "aws_launch_configuration" "as_conf" {
  name_prefix   = "nginx-config"
  image_id      = var.ami
  instance_type = var.instance-type

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web-asg" {
  name                      = "nginx-asg"
  max_size                  = 3
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 2
  force_delete              = true
  launch_configuration      = aws_launch_configuration.as_conf.name
  vpc_zone_identifier       = var.snet
  target_group_arns         = [var.tg-arn]
  lifecycle {
    create_before_destroy = true
  }
}