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

output "public_subnets_found" {
  value = [for s in data.aws_subnet.public : { id = s.id, az = s.availability_zone }]
}

output "private_subnets_found" {
  value = [for s in data.aws_subnet.private : { id = s.id, az = s.availability_zone }]
}