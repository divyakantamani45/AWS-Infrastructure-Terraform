module "eks_cluster" {
  source = "terraform-aws-modules/eks/aws"
  version = "20.0" # pin an appropriate version

  cluster_name = var.cluster_name
  cluster_version = "1.29"
  subnet_ids = var.private_subnets
  vpc_id = var.vpc_id

  eks_managed_node_groups = {
    default = {
      desired_capacity = 1
      max_capacity     = 1
      min_capacity     = 1
      instance_types   = ["t3.small"]
      capacity_type    = "SPOT"
    }
  }
}
