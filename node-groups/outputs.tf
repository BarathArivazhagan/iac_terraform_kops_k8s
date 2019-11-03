output "nodes_autoscaling_group_id" {
  value = aws_autoscaling_group.nodes_asg.id
}

output "nodes_azs" {
  value = aws_autoscaling_group.nodes_asg.availability_zones
}