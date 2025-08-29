variable "aws_region" {
  description = "The AWS region to deploy resources."
  type        = string
  default     = "ap-northeast-2"
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for the Ingress."
  type        = string
}

variable "deploy_rds" {
  description = "RDS 인스턴스를 배포하려면 true로 설정하세요."
  type        = bool
  default     = false # 기본적으로 RDS를 배포하지 않도록 설정
}
