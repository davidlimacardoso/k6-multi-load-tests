output "elb" {
  value = {
    dns_name = aws_lb.create_lb.dns_name
    arn      = aws_lb.create_lb.arn
  }
}