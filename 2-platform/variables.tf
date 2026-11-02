variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "profile" {
  description = "The AWS profile to use"
  type        = string
  default     = "personal"
}

variable "remote_state_bucket" {
  description = "The S3 bucket to store Terraform state"
  type        = string
  default     = "ecs-fargate-terraform-remote-state-v1"
}
variable "remote_state_key" {
  description = "The S3 key to store Terraform state"
  type        = string
  default     = "layer2/platform.tfstate"
}

variable "ecs-cluster-name" {
  description = "The name of the ECS cluster"
  type        = string
  default     = "production-fargate-cluster"
}

variable "internet_cidr_block" {
  description = "The CIDR block for internet access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "domain_name" {
  description = "The domain name for the ECS cluster"
  type        = string
}