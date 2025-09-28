variable "allowed_principals" {
description = "List of IAM principal ARNs allowed to access this ECR repository"
type = list(string)
default = []
}