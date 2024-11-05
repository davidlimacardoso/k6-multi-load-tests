variable "secret_value" {
  type = list(object({
    key   = string
    value = string
  }))
  description = "List of objects with key value pairs"
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "env" {
  type        = string
  description = "Environment name"
}
