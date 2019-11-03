output "master_security_group_id" {
  value = aws_security_group.masters_security_group.id
}

output "nodes_security_group_id" {
  value = aws_security_group.nodes_security_group.id
}

output "elb_master_security_group_id" {
  value = aws_security_group.elb_security_group.id
}