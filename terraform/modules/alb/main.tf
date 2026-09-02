variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

resource "aws_lb" "main" {
  name               = "safeshare-alb"
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnets
}

resource "aws_lb_target_group" "main" {
  name     = "safeshare-flask-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 10
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

output "target_group_arn" {
  value = aws_lb_target_group.main.arn
}

output "dns_name" {
  value = aws_lb.main.dns_name
}