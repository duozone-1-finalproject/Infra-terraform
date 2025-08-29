variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "node_security_group_id" {
  description = "The ID of the EKS node security group"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for the Ingress."
  type        = string
}

variable "ingress_namespace" {
  description = "Namespace for the ingress resource."
  type        = string
  default     = "default"
}

variable "backend_service_name" {
  description = "Name of the backend service for the ingress."
  type        = string
  default     = "frontend"
}

variable "alb_controller_version" {
  description = "Version of the aws-load-balancer-controller helm chart"
  type        = string
  default     = "1.8.1"
}