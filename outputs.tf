output "instance_name" {
  value = aws_instance.this[*].tags["Name"]
}

output "public_subnets_found" {
  value = [for s in data.aws_subnet.public : { id = s.id, az = s.availability_zone }]
}

output "private_subnets_found" {
  value = [for s in data.aws_subnet.private : { id = s.id, az = s.availability_zone }]
}