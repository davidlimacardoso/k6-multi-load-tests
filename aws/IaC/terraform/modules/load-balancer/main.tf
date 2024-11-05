resource "aws_lb_target_group" "create_lb_tg" {
  name     = "${var.name}-${var.project}-${var.env}-tg"
  port     = var.port
  protocol = var.protocol
  vpc_id   = var.vpc_id

  load_balancing_algorithm_type = "round_robin"
  slow_start                    = 0
  deregistration_delay          = 60

  health_check {
    port                = var.port
    protocol            = var.protocol
    interval            = var.health_interval
    path                = var.health_path
    unhealthy_threshold = var.unhealthy_threashold
    healthy_threshold   = var.health_threashold
  }

}

resource "aws_lb_target_group_attachment" "create_tg_att" {
  target_group_arn = aws_lb_target_group.create_lb_tg.arn
  target_id        = var.instance_id
  port             = var.port
}

resource "aws_lb" "create_lb" {
  name                       = "${var.name}-${var.project}-${var.env}-elb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = var.lb_security_group
  subnets                    = var.subnets
  enable_deletion_protection = false
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.create_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.create_lb_tg.arn
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.create_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.create_lb_tg.arn
  }
}