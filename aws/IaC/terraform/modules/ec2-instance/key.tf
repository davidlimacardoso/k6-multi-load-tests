
# Generate a secure private key for the EC2 instance and save it as a file on disk
# XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
resource "tls_private_key" "create_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "null_resource" "save_key" {
  provisioner "local-exec" {
    command     = <<-EOT
        echo '${tls_private_key.create_key.private_key_pem}' > ./grafana-${var.env}-key.pem
    EOT
    interpreter = ["bash", "-c"]
  }
}

# Create a key-pair for the EC2 instance
resource "aws_key_pair" "create_key" {
  key_name   = "grafana-${var.env}-key"
  public_key = tls_private_key.create_key.public_key_openssh
}
