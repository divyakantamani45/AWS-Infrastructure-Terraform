############################
# IAM role for node group
############################
resource "aws_iam_role" "eks_node_role" {
  name = "${var.cluster_name}-nodegroup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach required policies
resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ecr" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

############################
# EKS Cluster with Node Group
############################
module "eks_cluster" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  subnet_ids      = var.private_subnets
  vpc_id          = var.vpc_id

  # 👇 Enable both private + public access
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  eks_managed_node_groups = {
    default = {
      desired_capacity = 1
      max_capacity     = 1
      min_capacity     = 1
      instance_types   = ["t3.small"]
      capacity_type    = "SPOT"

      # Use the manually created IAM role
      iam_role_arn = aws_iam_role.eks_node_role.arn
    }
  }
   # 👇 Addons (EFS CSI + optional others)
  # cluster_addons = {
  #   aws-efs-csi-driver = {
  #     most_recent              = true
  #     service_account_role_arn = aws_iam_role.efs_csi_role.arn
  #   }
  }
}
resource "aws_iam_policy" "efs_csi_policy" {
  name        = "${var.cluster_name}-AmazonEKS_EFS_CSI_Driver_Policy"
  description = "EFS CSI driver policy"
  policy      = file("${path.module}/efs-csi-policy.json")
}

resource "aws_iam_role" "efs_csi_role" {
  name = "${var.cluster_name}-efs-csi-role"

  assume_role_policy = data.aws_iam_policy_document.efs_assume_role.json
}

data "aws_iam_policy_document" "efs_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [module.eks_cluster.oidc_provider_arn]
    }

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "${module.eks_cluster.oidc_provider}:sub"
      values   = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "efs_csi_attach" {
  role       = aws_iam_role.efs_csi_role.name
  policy_arn = aws_iam_policy.efs_csi_policy.arn
}


