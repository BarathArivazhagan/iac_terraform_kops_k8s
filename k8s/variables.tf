variable "cluster_name" {}
variable "dns_zone" {}
variable "kubernetes_version" {}
variable "state_bucket" {}
variable "node_image" {}
variable "vpc_id" {}
variable "vpc_cidr" {}
variable "region" {}
variable "worker_node_type" {}
variable "min_worker_nodes" {}
variable "max_worker_nodes" {}
variable "master_node_type" {}


variable "public_subnets" {
  type        = "list"
  default     = []
}

variable "private_subnets" {
  type        = "list"
  default     = []
}

variable "subnets" {}