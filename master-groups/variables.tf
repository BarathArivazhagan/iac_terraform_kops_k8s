variable "cluster_name" {}
variable "stack_name" {}
variable "key_name" {}
variable "master_security_group_id" {}
variable "master_k8s_ami" {
  default = "ami-077b21be2bc9db012"
}
variable "master_instance_type" {
  default = "t2.micro"
}

variable "master_subnet_id" {}
variable "master_volume_size" {}
variable "elb_security_group_id" {}
variable "public_subnets" {
  type = list(string)
}