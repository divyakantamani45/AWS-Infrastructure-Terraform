output "cluster_id" {
  value = module.eks_cluster.cluster_id
}
output "oidc_provider_url" {
  value = module.eks_cluster.oidc_issuer_url
}
output "oidc_provider_arn" {
  value = module.eks_cluster.oidc_issuer_arn
}
