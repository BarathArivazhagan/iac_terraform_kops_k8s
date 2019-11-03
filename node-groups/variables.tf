variable "cluster_name" {}
variable "stack_name" {}
variable "key_name" {}
variable "node_k8s_ami" {
  default = "ami-077b21be2bc9db012"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "nodes_security_group_id" {}
variable "nodes_volume_size" {
  default = 128
}

variable "nodes_subnets" {
  type = list(string)
}

