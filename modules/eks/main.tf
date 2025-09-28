module "eks_cluster" {
  source = "terraform-aws-modules/eks/aws"
  version = "21.3.1" # pin an appropriate version

  eks_cluster = {
    name    = var.cluster_name
    version = "1.27"
  }
  subnet_ids = var.private_subnets
  vpc_id = var.vpc_id

  eks_managed_node_groups = {
    default = {
      desired_size   = 1
      min_size       = 1
      max_size       = 1
      instance_types = ["t3.small"]
      capacity_type  = "SPOT"
    }
  }
}
