output "public_subnet_id" {
  value = {
    for k, subnet in data.aws_subnets.public :
    k => subnet.id
  }
}

output "private_subnet_id" {
  value = {
    for k, subnet in data.aws_subnets.private :
    k => subnet.id
  }
}