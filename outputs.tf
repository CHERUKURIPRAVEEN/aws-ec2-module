output "instance_name" {
  value = aws_instance.this[*].tags["Name"]
}

output "private_ips" {
  description = "Private IP addresses of EC2 instances"
  value       = aws_instance.this[*].private_ip
}

output "public_ips" {
  description = "Public IP addresses of EC2 instances"
  value       = aws_instance.this[*].public_ip
}

output "public_subnets_found" {
  value = [for s in data.aws_subnet.public : { id = s.id, az = s.availability_zone }]
}

output "private_subnets_found" {
  value = [for s in data.aws_subnet.private : { id = s.id, az = s.availability_zone }]
}