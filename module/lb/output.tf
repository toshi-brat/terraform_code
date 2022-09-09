output "frontend-tg-arn" {
    value = aws_lb_target_group.frontend-tg.arn  
}
output "backend-tg-arn" {
    value = aws_lb_target_group.backend-tg.arn  
}