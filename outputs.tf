output "cluster_name" {
  value = "demo.k8s.local"
}

//output "master_autoscaling_group_ids" {
//  value = module.security_groups.
//}
//
//output "master_security_group_ids" {
//  value = [aws_security_group.masters-demo-k8s-local.id]
//}
//
//output "masters_role_arn" {
//  value = aws_iam_role.masters-demo-k8s-local.arn
//}
//
//output "masters_role_name" {
//  value = aws_iam_role.masters-demo-k8s-local.name
//}
//
//output "node_autoscaling_group_ids" {
//  value = [aws_autoscaling_group.nodes-demo-k8s-local.id]
//}
//
//output "node_security_group_ids" {
//  value = [aws_security_group.nodes-demo-k8s-local.id]
//}
//
//output "node_subnet_ids" {
//  value = [aws_subnet.us-east-1a-demo-k8s-local.id, aws_subnet.us-east-1b-demo-k8s-local.id]
//}
//
//output "nodes_role_arn" {
//  value = aws_iam_role.nodes-demo-k8s-local.arn
//}
//
//output "nodes_role_name" {
//  value = aws_iam_role.nodes-demo-k8s-local.name
//}

output "region" {
  value = "us-east-1"
}
//
//output "route_table_public_id" {
//  value = aws_route_table.demo-k8s-local.id
//}

output "public_subnets" {
  value = module.vpc.public_subnets
}


output "vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

