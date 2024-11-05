output "id" {
  value = {
    grafana_sg   = aws_security_group.grafana_sg.id,
    codebuild_sg = aws_security_group.codebuild_sg.id,
    bastion_sg   = aws_security_group.bastion_sg.id,
    elb_sg       = aws_security_group.elb_sg.id
  }
  description = "Security group ID's"
}