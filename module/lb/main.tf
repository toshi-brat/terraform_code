resource "aws_lb" "dev-lb" {
  name               = "dev-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.lb_sg]
  subnets            = [for v in var.snet: v.snet-id]

   # subnets = var.pubsnet
  enable_deletion_protection = false

  tags = {
    Environment = "dev"
  }
}
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.dev-lb.arn
  port              = "80"
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}


resource "aws_lb_target_group" "tg" {
  name     = "dev-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc-id
}

resource "aws_lb_target_group_attachment" "tg-attach" {
  for_each = var.attach
  #count = length(var.attach)
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = each.value
  port             = 80
}
