output "eks_cluster_name" {
  description = "The name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance (only available if deployed)."
  # deploy_rds가 false이면 모듈이 생성되지 않으므로, 오류 방지를 위해 조건부로 출력합니다.
  value       = var.deploy_rds ? module.rds[0].rds_endpoint : "RDS not deployed"
}

output "rds_port" {
  description = "The port of the RDS instance (only available if deployed)."
  value       = var.deploy_rds ? module.rds[0].rds_port : "RDS not deployed"
}