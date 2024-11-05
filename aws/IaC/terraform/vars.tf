variable "profile" {
  description = "The AWS profile to use for authentication"
  type        = string
  default     = "default"
}

variable "project" {
  description = "The name of the project"
  type        = string
  default     = "k6-test-loads"
}

variable "region" {
  description = "The AWS region where resources will be created"
  type        = string
}

variable "env" {
  description = "The environment (e.g., dev, staging, prod)"
  type        = string
}

variable "platform" {
  description = "The platform name"
  type        = string
  default     = "k6"
}

# VPC initial source
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cdir_block" {
  description = "VPC CIDR block ex: 10.0.0.0/24"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "my_external_ip" {
  description = "Your external IP to restrict access to ingress on security group"
  type        = string
}