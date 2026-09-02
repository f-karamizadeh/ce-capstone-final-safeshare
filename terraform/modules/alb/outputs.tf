output "alb_dns" { value = aws_lb.main.dns_name }
output "tg_arn" { value = aws_lb_target_group.app.arn }
output "alb_arn" { value = aws_lb.main.arn }