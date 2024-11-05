output "r53_names" {
  value = values(aws_route53_record.internal).*.name
}