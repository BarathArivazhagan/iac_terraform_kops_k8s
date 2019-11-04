provider "aws" {
  region = var.aws_region

}



module "vpc" {
  source = "./vpc"
  cluster_name = var.cluster_name
  stack_name = var.stack_name
  nat_enabled = var.nat_enabled
  subnets = var.subnets
  vpc_cidr_block = var.vpc_cidr_block
}

module "security_groups" {
  source = "./security_groups"
  cluster_name = var.cluster_name
  stack_name = var.stack_name
  vpc_id = module.vpc.vpc_id
}

module "kubernetes" {
  source = "./k8s"
  cluster_name = "dev"
  dns_zone = "barath-devops.com"
  kubernetes_version = "1.15.4"
  master_node_type = "t2.micro"
  max_worker_nodes = "1"
  min_worker_nodes = "1"
  state_bucket = "kops-us-east-1-barath-bucket"
  region = "us-east-1"
  subnets = length(module.vpc.public_subnets)
  public_subnets = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  vpc_cidr = module.vpc.vpc_cidr_block
  vpc_id = module.vpc.vpc_id
  worker_node_type = "t2.micro"
  node_image = "ami-077b21be2bc9db012"
}

module "master_groups" {
  source = "./master-groups"
  cluster_name = var.cluster_name
  stack_name = var.stack_name
  elb_security_group_id = module.security_groups.elb_master_security_group_id
  master_security_group_id = module.security_groups.master_security_group_id
  vpc_id = module.vpc.vpc_id
  master_subnet_id = element(module.vpc.public_subnets_ids,0 )
  key_name = var.key_name
  master_volume_size = var.master_volume_size
  public_subnets = module.vpc.public_subnets_ids
  master_azs = module.vpc.public_subnets_azs
  bucket_name = var.bucket_name
}

module "node_groups" {
  source = "./node-groups"
  cluster_name = var.cluster_name
  stack_name = var.stack_name
  key_name = var.key_name
  nodes_security_group_id = module.security_groups.nodes_security_group_id
  nodes_subnets = var.cluster_topology == "public" ? module.vpc.public_subnets_ids : module.vpc.private_subnets_ids
  bucket_name = var.bucket_name
}

module "route53" {
  source = "./route53"
  elb_name = module.master_groups.elb_dns_name
  elb_zone_id = module.master_groups.elb_zone_id
  route53_zone_id = var.route53_zone_id
  api_server_route_name = var.api_server_route_name

}