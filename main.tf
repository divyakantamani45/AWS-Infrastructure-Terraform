# VPC
module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  region = var.region
}

# EKS cluster (uses terraform-aws-modules/eks underneath)
module "eks" {
  source = "./modules/eks"
  cluster_name = var.cluster_name
  region = var.region
  vpc_id = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  public_subnets = module.vpc.public_subnets
}

# data sources for providers (used in providers.tf)
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

# IAM for IRSA (role for application service account)
module "iam" {
  source = "./modules/iam"
  region = var.region
  eks_cluster_name = module.eks.cluster_id
  oidc_provider = module.eks.oidc_provider_url
}

# RDS (Postgres)
module "rds" {
  source = "./modules/rds"
  region = var.region
  vpc_security_group_ids = [module.vpc.default_sg_id]
  db_subnet_ids = module.vpc.private_subnets
  db_name = "appdb"
  db_username = "appuser"
  db_password = random_password.rds_password.result
}

resource "random_password" "rds_password" {
  length = 16
  special = true
}

# Put RDS credentials into Secrets Manager
resource "aws_secretsmanager_secret" "app_secret" {
  name = "my-app-secrets"
  description = "DB credentials for devops app"
}

resource "aws_secretsmanager_secret_version" "app_secret_version" {
  secret_id = aws_secretsmanager_secret.app_secret.id
  secret_string = jsonencode({
    DB_USERNAME = module.rds.db_username
    DB_PASSWORD = module.rds.db_password
    DB_HOST     = module.rds.db_endpoint
    DB_NAME     = module.rds.db_name
  })
}

# EFS
module "efs" {
  source = "./modules/efs"
  vpc_id = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  region = var.region
}

# Install AWS Load Balancer Controller (Helm) + create IAM role for it
module "alb_controller" {
  source = "./modules/alb_controller"
  cluster_name = module.eks.cluster_id
  vpc_id = module.vpc.vpc_id
  region = var.region
  oidc_provider = module.eks.oidc_provider_arn
  service_account_role_arn = module.iam.alb_sa_role_arn
}

# Outputs for reference
output "cluster_name" {
  value = module.eks.cluster_id
}

output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_id}"
}
