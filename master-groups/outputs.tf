output "aws_key_pair_id" {
  value = aws_key_pair.k8s_key_pair.id
}

output "master_autoscaling_group_id" {
  value = aws_autoscaling_group.master_autoscaling_group.id
}

output "master_autoscaling_group_azs" {
  value = aws_autoscaling_group.master_autoscaling_group.availability_zones
}

output "elb_dns_name" {
  value = aws_lb.master_k8s_api.dns_name
}

output "elb_zone_id" {
  value = aws_lb.master_k8s_api.zone_id
}