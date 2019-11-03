

resource "aws_launch_configuration" "master_launch_configuration" {
  name_prefix                 =  join("-",[var.stack_name,"master",var.cluster_name])
  image_id                    = var.master_k8s_ami
  instance_type               = var.master_instance_type
  key_name                    = aws_key_pair.k8s_key_pair.id
  iam_instance_profile        = aws_iam_instance_profile.masters_instance_profile.id
  security_groups             = [var.master_security_group_id]
  associate_public_ip_address = true
  user_data                   = file("data/aws_launch_configuration_master_user_data")

  root_block_device  {
    volume_type           = "gp2"
    volume_size           = var.master_volume_size
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }

  enable_monitoring = false
}

resource "aws_autoscaling_group" "master_autoscaling_group" {
  name                 = join("-",[var.stack_name,"master-asg",var.cluster_name])
  launch_configuration = aws_launch_configuration.master_launch_configuration.id
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = [var.master_subnet_id]

  tags = [
    {
      KubernetesCluster =   var.cluster_name,
      Name = join("-",[var.stack_name, "master"])
    }]




  metrics_granularity = "1Minute"
  enabled_metrics     = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

resource "aws_autoscaling_attachment" "master_autoscaling_attachment" {
    elb                    = aws_elb.master_k8s_api.id
    autoscaling_group_name = aws_autoscaling_group.master_autoscaling_group.id
}


resource "aws_key_pair" "k8s_key_pair" {
  key_name   = var.key_name
  public_key = file("data/aws_key_pair_kubernetes_public_key")
}

resource "aws_elb" "master_k8s_api" {
  name = join("-",[var.stack_name,"elb"])

  listener  {
    instance_port     = 443
    instance_protocol = "TCP"
    lb_port           = 443
    lb_protocol       = "TCP"
  }

  security_groups = [var.elb_security_group_id]
  subnets         = var.public_subnets

  health_check  {
    target              = "SSL:443"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
  }

  cross_zone_load_balancing = false
  idle_timeout              = 300

  tags = {
    KubernetesCluster                      = var.cluster_name
    Name                                   = join("-",[var.stack_name,"elb"])
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_ebs_volume" "a_etcd_events" {
  availability_zone = var.master_azs[0]
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                      = var.cluster_name
    Name                                   = join("-",[var.stack_name,"etcd"])
    "k8s.io/etcd/events"                   = "a/a"
    "k8s.io/role/master"                   = "1"
    "kubernetes.io/cluster/demo.k8s.local" = "owned"
  }
}

resource "aws_ebs_volume" "a_etcd_main" {
  availability_zone = var.master_azs[0]
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                      = var.cluster_name
    Name                                   = join("-",[var.stack_name,"etcd-main"])
    "k8s.io/etcd/main"                     = "a/a"
    "k8s.io/role/master"                   = "1"
    "kubernetes.io/cluster/demo.k8s.local" = "owned"
  }
}


