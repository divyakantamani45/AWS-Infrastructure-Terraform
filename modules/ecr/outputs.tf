output "repository_url" {
description = "URL of the ECR repository"
value = aws_ecr_repository.this.repository_url
}


output "repository_arn" {
description = "ECR repository ARN"
value = aws_ecr_repository.this.arn
}


output "repository_name" {
description = "ECR repository name"
value = aws_ecr_repository.this.name
}


output "registry_id" {
description = "AWS account registry ID"
value = aws_ecr_repository.this.registry_id
}