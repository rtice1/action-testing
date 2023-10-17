variable "region" {
  type        = string
  default     = "us-east-2"
  description = "The region the resources will be deployed in."
}

variable "use_kms" {
  type        = bool
  default     = true
  description = "True to create and use KMS key, false for managed key."
}

variable "tls_policy" {
  type        = bool
  default     = true
  description = "Enables public access for TLS traffic."
}

variable "user_name" {
  type        = string
  description = "User Name."
}

variable "application_name" {
  type        = string
  description = "Name of the application."
}

variable "create_ecr" {
  type        = bool
  default     = false
  description = "Creates AWS ECR repository"
}

variable "create_eks" {
  type        = bool
  default     = false
  description = "Creates AWS EKS Cluster"
}