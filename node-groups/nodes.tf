resource "aws_launch_configuration" "nodes_launch_configuration" {
  name_prefix                 = join("-",[var.stack_name,"nodes-"])
  image_id                    = var.node_k8s_ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.nodes_iam_instance_profile.id
  security_groups             = [var.nodes_security_group_id]
  associate_public_ip_address = true
  user_data                   = file("data/aws_launch_configuration_nodes_user_data")

  root_block_device  {
    volume_type           = "gp2"
    volume_size           = var.nodes_volume_size
    delete_on_termination = true
  }

  lifecycle {
    create_before_destroy = true
  }

  enable_monitoring = false
}


resource "aws_autoscaling_group" "nodes_asg" {
  name                 = join("-",[var.stack_name,"nodes-asg"])
  launch_configuration = aws_launch_configuration.nodes_launch_configuration.id
  max_size             = 2
  min_size             = 2
  vpc_zone_identifier  = var.nodes_subnets

  tags = [
    {
      KubernetesCluster = var.cluster_name
      Name = join("-", [var.stack_name,"nodes"])
      k8s.io/cluster-autoscaler/node-template/label/kops.k8s.io/instancegroup ="nodes"
      k8s.io/role/node  ="1"
      kops.k8s.io/instancegroup = "nodes"
    }]

  metrics_granularity = "1Minute"
  enabled_metrics     = ["GroupDesiredCapacity", "GroupInServiceInstances", "GroupMaxSize", "GroupMinSize", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
}

