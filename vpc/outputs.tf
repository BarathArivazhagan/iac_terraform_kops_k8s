output "vpc_id" {
  value = aws_vpc.k8s_vpc.id
}

output "public_subnets_ids" {
  value = aws_subnet.public_subnets.*.id
}

output "private_subnets_ids" {
  value = aws_subnet.private_subnets.*.id
}

output "public_subnets" {
  value = aws_subnet.public_subnets
}

output "private_subnets" {
  value = aws_subnet.private_subnets
}

output "internet_gateway" {
  value = aws_internet_gateway.internet_gateway.id
}

output "vpc_cidr_block" {
  value = aws_vpc.k8s_vpc.cidr_block
}

output "public_subnets_azs" {
  value = aws_subnet.public_subnets.*.availability_zone
}

output "private_subnets_azs" {
  value = aws_subnet.private_subnets.*.availability_zone
}