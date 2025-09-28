resource "aws_ecr_repository" "this" {
    name = "devops-ecr-prod"
    # image_scanning_configuration {
    #     scan_on_push = true
    # }


    image_tag_mutability = "IMMUTABLE"


    #tags = var.tags


    lifecycle {
        prevent_destroy = true
    }
}


#### Secure Repository Policy: allow only specified principals ####
data "aws_iam_policy_document" "repo_policy" {
    statement {
        sid = "AllowSpecificPrincipals"
        effect = "Allow"


        principals {
            type = "AWS"
            identifiers = var.allowed_principals
        }


        actions = [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:DescribeImages",
            "ecr:DescribeRepositories",
            "ecr:BatchCheckLayerAvailability"
        ]
        resources = [aws_ecr_repository.this.arn]
    }
}

resource "aws_ecr_repository_policy" "this" {
    repository = aws_ecr_repository.this.name
    policy = data.aws_iam_policy_document.repo_policy.json
}