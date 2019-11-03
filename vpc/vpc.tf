
data "aws_availability_zones" "azs" {
  state = "available"
}

resource "aws_vpc" "k8s_vpc" {

  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = join("-", [var.stack_name,"vpc"])
    KubernetesCluster =  join("-",[])
  }
}


resource "aws_subnet" "private_subnets" {

  count =  var.subnets > 0 ? var.subnets : 1
  vpc_id = aws_vpc.k8s_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  map_public_ip_on_launch = "false"
  tags = {
    Name = join("-",[var.stack_name, "private-subnet", data.aws_availability_zones.azs.names[count.index]])
    SubnetType                             = "Private"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/elb"               = "1"
  }
}

resource "aws_subnet" "public_subnets" {

  count = var.subnets > 0 ? var.subnets : 1
  vpc_id = aws_vpc.k8s_vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr_block, 8, count.index + var.subnets)
  availability_zone = data.aws_availability_zones.azs.names[count.index]
  map_public_ip_on_launch = "true"
  tags = {
     Name = join("-",[var.stack_name,"public-subnet",data.aws_availability_zones.azs.names[count.index]])
     SubnetType = "Public"
     "kubernetes.io/cluster/${var.cluster_name}" = "owned"
     "kubernetes.io/role/elb" = "1"
  }
}


resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.k8s_vpc.id
  tags = {
    Name = join("-",[var.stack_name,"internet-gateway"])
  }
}

resource "aws_nat_gateway" "nat_gateway" {

  count = var.nat_enabled ? 1 : 0
  subnet_id     = aws_subnet.public_subnets[0].id
  allocation_id = aws_eip.nat_gateway_eip[0].id
  tags = {
    Name = join("-",[var.stack_name,"nat-gateway"])
  }
}

resource "aws_eip" "nat_gateway_eip" {
  count = var.nat_enabled ? 1 : 0
  vpc      = true
}


resource "aws_route_table" "public_route_table" {

  vpc_id = aws_vpc.k8s_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = join("-",[var.stack_name,"public-route-table"])
  }

}

resource "aws_route_table" "private_route_table" {

  vpc_id = aws_vpc.k8s_vpc.id
  tags = {
    Name = join("-",[var.stack_name,"private-route-table"])
  }

}

resource "aws_route_table_association" "public_subnets_association" {

  count = var.subnets > 0 ? var.subnets : 1
  subnet_id = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnets_association" {

  count = var.subnets > 0 ? var.subnets : 1
  subnet_id = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table.id

}



resource "aws_route" "internet_gateway_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route" "nat_gateway_route" {
  count = var.nat_enabled ? 1: 0
  route_table_id = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gateway[0].id
}

resource "aws_vpc_dhcp_options" "k8s_vpc_dhcp" {
  domain_name         = "ec2.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    KubernetesCluster                             = var.cluster_name
    Name                                          = var.cluster_name
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_vpc_dhcp_options_association" "k8s_vpc_dhcp_association" {
  vpc_id          =  aws_vpc.k8s_vpc.id
  dhcp_options_id =  aws_vpc_dhcp_options.k8s_vpc_dhcp.id
}


