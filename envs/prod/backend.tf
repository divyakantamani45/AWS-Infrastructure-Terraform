terraform {
  backend "s3" {
    bucket         = "my-terraform-states-prod-012"   # replace with your bucket name
    key            = "eks/terraform.tfstate"      # path within bucket
    region         = "us-east-1"                  # same region as bucket
    #dynamodb_table = "terraform-locks"            # DynamoDB table for state locking
    encrypt        = true
  }
}
