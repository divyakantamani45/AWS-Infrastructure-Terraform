output "irsa_role_arn" { value = aws_iam_role.irsa_role.arn }
output "alb_sa_role_arn" { value = aws_iam_role.irsa_role.arn } # demo reuse
