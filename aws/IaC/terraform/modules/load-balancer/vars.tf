variable "subnets" {
  description = "List of subnets to attach the Load Balancer"
  type        = list(string)
}

variable "lb_security_group" {
  description = "Security group for the Load Balancer"
  type        = list(string)
}

variable "instance_id" {
  type        = string
  description = "Instance EC2 ID to target group"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "name" {
  type        = string
  description = "Name of the Load Balancer"
}

variable "health_path" {
  type        = string
  description = "Path to check the health of the instance"
}

variable "health_threashold" {
  description = "Total of requests to consider the instance healthy"
  default     = 5
}

variable "unhealthy_threashold" {
  description = "Total of requests to consider the instance to stay failed"
  default     = 2
}

variable "health_interval" {
  type        = number
  description = "Interval in seconds to check the health of the instance"
  default     = 30
}

variable "port" {
  type        = number
  description = "Port of the instance application"
  default     = 3000
}

variable "protocol" {
  type        = string
  description = "Protocol of the instance application"
  default     = "HTTP"
}

variable "env" {
  type        = string
  description = "Environment of the application"
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "certificate" {
  type        = string
  description = "ACM SSL Certificate ARN"
}