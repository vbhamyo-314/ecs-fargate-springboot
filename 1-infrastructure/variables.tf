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
variable "bucket" {
  description = "The S3 bucket to store the Terraform state"
  type        = string
  default     = "ecs-fargate-terraform-remote-state-v1"
}

variable "key" {
  description = "The S3 key to store the Terraform state"
  type        = string
  default     = "PROD/infrastructure.tfstate"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "The CIDR block for the public subnet"
  type        = string
}

variable "public_subnet_2_cidr" {
  description = "The CIDR block for the public subnet"
  type        = string
}

variable "public_subnet_3_cidr" {
  description = "The CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_1_cidr" {
  description = "The CIDR block for the private subnet"
  type        = string
}

variable "private_subnet_2_cidr" {
  description = "The CIDR block for the private subnet"
  type        = string
}


variable "private_subnet_3_cidr" {
  description = "The CIDR block for the private subnet"
  type        = string
}
