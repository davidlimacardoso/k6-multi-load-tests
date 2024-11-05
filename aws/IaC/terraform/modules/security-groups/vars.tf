variable "sg_ingress" {
  description = "Security groups ingress"
  type = map(object({
    name        = string
    description = string
    ingress = list(object({
      protocol        = string
      from_port       = number
      to_port         = number
      cidr_blocks     = list(string)
      security_groups = optional(list(string))
      description     = string
    }))
  }))

  default = {}
}

variable "sg_egress" {
  default = {
    protocol    = "-1"
    port        = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
  description = "Allow default egress"
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}