resource "aws_security_group" "elb_security_group" {
  name        = join("-",[var.stack_name,"elb-sg"])
  vpc_id      =  var.vpc_id
  description = join("-",[var.stack_name,"elb-sg"])

  tags = {
    KubernetesCluster                      = join("-",[var.stack_name,var.cluster_name])
    Name                                   = join("-",[var.stack_name,"elb-sg"])
    "kubernetes.io/cluster/demo.k8s.local" = "owned"
  }
}

resource "aws_security_group" "masters_security_group" {
  name        = join("-",[var.stack_name,"master-sg"])
  vpc_id      =  var.vpc_id
  description = "Security group for masters"

  tags = {
    KubernetesCluster                      = join("-",[var.stack_name,var.cluster_name])
    Name                                   = join("-",[var.stack_name,"master-sg"])
    "kubernetes.io/cluster/demo.k8s.local" = "owned"
  }
}

resource "aws_security_group" "nodes_security_group" {
  name        = join("-",[var.stack_name,"nodes-sg"])
  vpc_id      = var.vpc_id
  description = "Security group for nodes"

  tags = {
    KubernetesCluster                      = join("-",[var.stack_name,var.cluster_name])
    Name                                   = join("-",[var.stack_name,"nodes-sg"])
    "kubernetes.io/cluster/demo.k8s.local" = "owned"
  }
}

resource "aws_security_group_rule" "all_master_to_master" {
  type                     = "ingress"
  security_group_id        = aws_security_group.masters_security_group.id
  source_security_group_id = aws_security_group.masters_security_group.id
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all_master_to_node" {
  type                     = "ingress"
  security_group_id        = aws_security_group.nodes_security_group.id
  source_security_group_id = aws_security_group.masters_security_group.id
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all_node_to_node" {
  type                     = "ingress"
  security_group_id        = aws_security_group.nodes_security_group.id
  source_security_group_id = aws_security_group.nodes_security_group.id
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "api_elb_egress" {
  type              = "egress"
  security_group_id = aws_security_group.elb_security_group.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https_api_elb_ingress" {
  type              = "ingress"
  security_group_id = aws_security_group.elb_security_group.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "https_elb_to_master" {
  type                     = "ingress"
  security_group_id        = aws_security_group.masters_security_group.id
  source_security_group_id = aws_security_group.elb_security_group.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "icmp-pmtu-api-elb-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = aws_security_group.elb_security_group.id
  from_port         = 3
  to_port           = 4
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "master-egress" {
  type              = "egress"
  security_group_id = aws_security_group.masters_security_group.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-egress" {
  type              = "egress"
  security_group_id = aws_security_group.nodes_security_group.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "node-to-master-tcp-1-2379" {
  type                     = "ingress"
  security_group_id        = aws_security_group.masters_security_group.id
  source_security_group_id = aws_security_group.nodes_security_group.id
  from_port                = 1
  to_port                  = 2379
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-2382-4000" {
  type                     = "ingress"
  security_group_id        = aws_security_group.masters_security_group.id
  source_security_group_id = aws_security_group.nodes_security_group.id
  from_port                = 2382
  to_port                  = 4000
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-tcp-4003-65535" {
  type                     = "ingress"
  security_group_id        = aws_security_group.masters_security_group.id
  source_security_group_id = aws_security_group.nodes_security_group.id
  from_port                = 4003
  to_port                  = 65535
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node-to-master-udp-1-65535" {
  type                     = "ingress"
  security_group_id        = aws_security_group.masters_security_group.id
  source_security_group_id = aws_security_group.nodes_security_group.id
  from_port                = 1
  to_port                  = 65535
  protocol                 = "udp"
}

resource "aws_security_group_rule" "ssh-external-to-master-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = aws_security_group.masters_security_group.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ssh-external-to-node-0-0-0-0--0" {
  type              = "ingress"
  security_group_id = aws_security_group.nodes_security_group.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}