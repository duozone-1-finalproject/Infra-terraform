# --------------------------------------------------------------------------------------------------
# 부모 모듈로부터 전달받는 변수
# --------------------------------------------------------------------------------------------------
variable "vpc_id" {
  description = "The ID of the VPC where the RDS instance will be deployed"
  type        = string
}

variable "public_subnets" {
  description = "A list of public subnet IDs for the RDS subnet group"
  type        = list(string)
}

variable "node_sg_id" {
  description = "The ID of the EKS node security group to allow access from"
  type        = string
}

# --------------------------------------------------------------------------------------------------
# RDS 자체 설정 변수
# --------------------------------------------------------------------------------------------------
variable "db_username" {
  description = "Username for the RDS database"
  type        = string
  default     = "admin"
}

variable "db_name" {
  description = "Name for the RDS database"
  type        = string
  default     = "userdb"
}

variable "db_instance_class" {
  description = "Instance class for the RDS database"
  type        = string
  default     = "db.t3.small"
}

variable "db_engine_version" {
  description = "MariaDB engine version"
  type        = string
  default     = "10.11"
}

variable "db_allocated_storage" {
  description = "Allocated storage for the RDS database in GB"
  type        = number
  default     = 20
}