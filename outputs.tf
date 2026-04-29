output "public_subnet_id" {
  value = {
    for k, subnet in data.aws_subnet.public :
    k => subnet.id
  }
}

output "private_subnet_id" {
  value = {
    for k, subnet in data.aws_subnet.private :
    k => subnet.id
  }
}