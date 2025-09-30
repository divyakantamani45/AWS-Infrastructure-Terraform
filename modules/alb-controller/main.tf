# Create IAM role & policy for ALB controller (policy JSON omitted here for brevity; normally use aws_iam_policy_document or AWS-managed policy)
resource "aws_iam_role" "alb_role" {
  name = "${var.cluster_name}-alb-role"
  assume_role_policy = data.aws_iam_policy_document.alb_assume_role.json
}

data "aws_iam_policy_document" "alb_assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    condition {
      test = "StringEquals"
      variable = "${replace(var.oidc_issuer, "https://", "")}:sub"
      values = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

# attach managed policy (or create inline with required permissions)
resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.alb_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLoadBalancerControllerIAMPolicy"
}
#create Service account
resource "kubernetes_service_account" "alb_sa" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_role.arn
    }
  }
}

# Install Helm chart
resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  create_namespace = false

  set {
    name  = "clusterName"
    value = var.cluster_name
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
  values = [file("${path.module}/values.yaml")]
}
