aws_region = "us-east-1"
cluster_name = "dev.barath-devops.com"
stack_name = "dev"
cluster_topology = "public"
subnets = 2
vpc_cidr_block = "10.0.0.0/16"
nat_enabled = false
master_volume_size = 64
key_name = "barath_k8s_key"
route53_zone_id="Z35CHBMLOTDXJ9"
api_server_route_name ="api.dev.barath-devops.com"