#Outputs for reference
output "cluster_name" {
  value = module.eks.cluster_id
}

output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_id}"
}
output "rds_endpoint" {
  value = module.rds.db_endpoint
}
output "efs_id" {
  value = module.efs.efs_id
}
