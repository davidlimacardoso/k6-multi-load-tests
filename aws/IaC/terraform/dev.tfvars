# Project source
region  = "us-east-1"
profile = "default"
env     = "dev"
project = "k6-test-loads"

# VPC initial source
vpc_cdir_block     = "10.248.240.0/21"
vpc_id             = "vpc-028e5bd127ffb9444"
private_subnet_ids = ["subnet-0c9478d9da82f0579", "subnet-04e972ab97a50a310"]
public_subnet_ids  = ["subnet-096be37972e2ccc99", "subnet-0809240826dda5375"]

# Your IP address to be allowed in security group, to access Bastion and ELB domain
my_external_ip = "191.222.222.222"