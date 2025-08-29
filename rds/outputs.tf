# --------------------------------------------------------------------------------------------------
# RDS 출력 (RDS Outputs)
# --------------------------------------------------------------------------------------------------
output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.mariadb.endpoint
}

output "rds_port" {
  description = "The port of the RDS instance"
  value       = aws_db_instance.mariadb.port
}