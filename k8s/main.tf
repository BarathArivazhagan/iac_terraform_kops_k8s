data "template_file" "public_subnet_map" {
  count    = var.subnets
  template = file("./templates/kops/subnet.tmpl.yaml")

  vars = {
    name = "PublicSubnet-${count.index}"
    cidr = lookup(var.public_subnets[count.index], "cidr_block")
    id = lookup(var.public_subnets[count.index], "id")
    type = "Public"
    az = lookup(var.public_subnets[count.index], "availability_zone")
  }
}

data "template_file" "private_subnet_map" {
  count    =  var.subnets
  template = file("./templates/kops/subnet.tmpl.yaml")

  vars = {
    name = "PrivateSubnet-${count.index}"
    cidr = lookup(var.private_subnets[count.index], "cidr_block")
    id = lookup(var.private_subnets[count.index], "id")
    type = "Private"
    az = lookup(var.private_subnets[count.index], "availability_zone")
  }
}

data "template_file" "kops_values_file" {
  template = file("./templates/kops/values.tmpl.yaml")

  vars = {
    cluster_name = var.cluster_name
    dns_zone = var.dns_zone
    kubernetes_version = var.kubernetes_version
    state_bucket = var.state_bucket
    node_image = var.node_image
    vpc_id = var.vpc_id
    vpc_cidr = var.vpc_cidr
    region = var.region
    private_subnets = join("", data.template_file.private_subnet_map.*.rendered)
    public_subnets = join("", data.template_file.public_subnet_map.*.rendered)
    master_subnets = templatefile("./templates/kops/subnet.tmpl.yaml", {
      name = "PrivateSubnet-${count.index}"
      cidr = lookup(var.public_subnets[0], "cidr_block")
      id = lookup(var.public_subnets[0], "id")
      type = "Public"
      az = lookup(var.private_subnets[0], "availability_zone")
    })
    worker_node_type = var.worker_node_type
    min_worker_nodes = var.min_worker_nodes
    max_worker_nodes = var.max_worker_nodes
    master_node_type = var.master_node_type
  }
}

resource "local_file" "rendered_kops_values_file" {
  content  = data.template_file.kops_values_file.rendered
  filename = "/tmp/kops/values-rendered.yaml"
}
# TODO make more parameters
resource "null_resource" "provision_kops" {
  depends_on = ["local_file.rendered_kops_values_file"]
  provisioner "local-exec" {
    environment = {
      KOPS_STATE_STORE ="s3://${var.state_bucket}"
    }

    command = <<EOT
    kops toolbox template --template ./templates/kops/cluster.tmpl.yaml \
    --template ./templates/kops/worker.tmpl.yaml \
    --template ./templates/kops/master.tmpl.yaml --values /tmp/kops/values-rendered.yaml > /tmp/kops/output.yaml
    kops create -f /tmp/kops/output.yaml

EOT
  }

  provisioner "local-exec" {
    when = "destroy"
    environment = {
      KOPS_STATE_STORE = "s3://${var.state_bucket}"
    }
    command = "kops delete cluster ${var.cluster_name}.${var.dns_zone} --yes"
  }
}

