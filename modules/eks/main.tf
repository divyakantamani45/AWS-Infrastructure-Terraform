module "eks_cluster" {
  source = "terraform-aws-modules/eks/aws"
  version = "20.0.0" # pin an appropriate version

  cluster_name = var.cluster_name
  cluster_version = "1.27"
  subnet_ids = var.private_subnets
  vpc_id = var.vpc_id

  eks_managed_node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 4
      min_capacity     = 2
      instance_types   = ["t3.medium"]
    }
  }
}
