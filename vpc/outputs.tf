output "vpc_id" {
  value = aws_vpc.k8s_vpc.id
}

output "public_subnets" {
  value = aws_subnet.public_subnets.*.id
}

output "private_subnets" {
  value = aws_subnet.private_subnets.*.id
}

output "internet_gateway" {
  value = aws_internet_gateway.internet_gateway.id
}

output "vpc_cidr_block" {
  value = aws_vpc.k8s_vpc.cidr_block
}