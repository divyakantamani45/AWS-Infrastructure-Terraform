variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "vpc_sg_id" {
  type = string,
  default = "" 
}
variable "region" { type = string }
