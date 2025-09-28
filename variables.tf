variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# variable "cluster_name" {
#   type    = string
#   default = "devops-eks"
# }

variable "domain_name" {
  description = "Route53 domain used for the app (example: app.example.com)"
  type        = string
  default     = "app.devops.com"
}

variable "vpc_cidr" { 
  type = string 
  default = "10.0.0.0/16" 
}
