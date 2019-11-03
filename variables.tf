## Common Variables
variable "aws_region" {
  default = "us-east-1"
}

variable "cluster_name" {}

variable "stack_name" {}

## VPC related Variables

variable "vpc_cidr_block" {}
variable "subnets" {}
variable "nat_enabled" {}

### Master Group Variables

variable "key_name" {}
variable "master_volume_size" {}

### Nodes Group Variables

variable "cluster_topology" {
  default = "public"
}