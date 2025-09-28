resource "aws_iam_role" "irsa_role" {
  name = "${var.eks_cluster_name}-pod-role"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume_role.json
}

data "aws_iam_policy_document" "irsa_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type = "Federated"
      identifiers = [var.oidc_provider]
    }
    condition {
      test = "StringEquals"
      values = ["system:serviceaccount:devops-app:devops-sa"]
      variable = "${replace(var.oidc_provider, "https://", "")}:sub"
    }
  }
}

resource "aws_iam_role_policy" "irsa_policy" {
  name = "irsa-secret-s3-policy"
  role = aws_iam_role.irsa_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["secretsmanager:GetSecretValue"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["s3:GetObject","s3:PutObject"]
        Resource = "*"
      },
       # Allow ECR image pull
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}
