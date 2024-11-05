
output "ec2_instance" {
  value = {
    for k, instance in aws_instance.create_instance : k => {
      id         = instance.id
      private_ip = instance.private_ip
      public_ip  = instance.public_ip
    }
  }
}

output "key_pair_name" {
  value = aws_key_pair.create_key.key_name
}

# output "ec2_private_ip" {
#   value = { for k, instance in aws_instance.create_instance : k => { instance = instance.id, private_ip = instance.private_ip } }
# }

# output "ec2_public_ip" {
#   value = { for k, instance in aws_instance.create_instance : k => { instance = instance.id, public_ip = instance.public_ip } }
# }