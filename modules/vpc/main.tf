resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = { Name = "${var.region}-vpc" }
}

resource "aws_subnet" "private" {
  count = 2
  vpc_id = aws_vpc.this.id
  cidr_block = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name                                      = "private-${count.index}"
    "kubernetes.io/cluster/devops-eks-prod"   = "shared"
    "kubernetes.io/role/internal-elb"         = "1"
  }
}

resource "aws_subnet" "public" {
  count = 2
  vpc_id = aws_vpc.this.id
  cidr_block = cidrsubnet(aws_vpc.this.cidr_block, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name                                    = "public-${count.index}"
    "kubernetes.io/cluster/devops-eks-prod" = "shared"
    "kubernetes.io/role/elb"                = "1"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_security_group" "default" {
  name = "eks-cluster-sg"
  vpc_id = aws_vpc.this.id
}
