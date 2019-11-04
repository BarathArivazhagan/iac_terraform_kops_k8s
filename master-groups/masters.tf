

resource "aws_launch_configuration" "master_launch_configuration" {
  name_prefix                 =  join("-",[var.stack_name,"master",var.cluster_name])
  image_id                    = var.master_k8s_ami
  instance_type               = var.master_instance_type
  key_name                    = aws_key_pair.k8s_key_pair.id
  iam_instance_profile        = aws_iam_instance_profile.masters_instance_profile.id
  security_groups             = [var.master_security_group_id]
  associate_public_ip_address = true
  user_data                   = templatefile("./templates/kops/aws_launch_configuration_master_user_data.tmpl",{
    cluster_name = var.cluster_name
    bucket_name = var.bucket_name

  })

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
      key                 = "KubernetesCluster"
      value               =  join("-",[var.cluster_name])
      propagate_at_launch = true
    }, {
      key                 = "Name"
      value               = join("-",["master",var.cluster_name])
      propagate_at_launch = true
    }, {
      key                 = "k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup"
      value               = "master"
      propagate_at_launch = true
    }, {
      key                 = "k8s.io/role/node"
      value               = "1"
      propagate_at_launch = true
    },
    {
      key                 = "kops.k8s.io/instancegroup"
      value               = "master"
      propagate_at_launch = true
    }

  ]


  metrics_granularity = "1Minute"
  enabled_metrics     = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

resource "aws_autoscaling_attachment" "master_autoscaling_attachment" {
    //alb_target_group   = aws_alb_target_group.
    autoscaling_group_name = aws_autoscaling_group.master_autoscaling_group.id
}


resource "aws_key_pair" "k8s_key_pair" {
  key_name   = var.key_name
  public_key = file("data/aws_key_pair_kubernetes_public_key")
}

resource "aws_lb" "master_k8s_api" {

  name = join("-",[var.stack_name,"elb"])
  load_balancer_type = "network"


  security_groups = [var.elb_security_group_id]
  subnets         = var.public_subnets
  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true
  idle_timeout              = 300

  tags = {
    KubernetesCluster                      = var.cluster_name
    Name                                   = join("-",[var.stack_name,"elb"])
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_lb_listener" "elb_listener" {
  load_balancer_arn = aws_lb.master_k8s_api.arn
  port              = "443"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elb_target_group.arn
  }
}


resource "aws_lb_target_group" "elb_target_group" {
  name     = "${var.stack_name}-lb-tg"
  port     = 443
  protocol = "TCP"
  target_type = "instance"
  vpc_id   =  var.vpc_id
  health_check  {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
  }
}



resource "aws_ebs_volume" "a_etcd_events" {
  availability_zone = var.master_azs[0]
  size              = 20
  type              = "gp2"
  encrypted         = false


  tags = {
    KubernetesCluster                      = var.cluster_name
    Name                                   = join("-",["a.etcd-events",var.cluster_name])
    "k8s.io/etcd/events"                   = "a/a"
    "k8s.io/role/master"                   = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_ebs_volume" "a_etcd_main" {
  availability_zone = var.master_azs[0]
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster                      = var.cluster_name
    Name                                   = join("-",["a.etcd-main",var.cluster_name])
    "k8s.io/etcd/main"                     = "a/a"
    "k8s.io/role/master"                   = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}



