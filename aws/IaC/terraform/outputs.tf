output "secrets_manager" {
  description = "Secrets Manager variables"
  value       = module.asm
}

output "s3" {
  description = "S3 bucket Codebuild artifact"
  value       = module.s3
}

output "sgs" {
  description = "Security Groups of the project"
  value       = module.sgs
}

output "ec2" {
  description = "EC2 instances and network information"
  value       = module.ec2-instance
}

output "elb" {
  description = "Load Balancer DNS name"
  value       = module.elb
}