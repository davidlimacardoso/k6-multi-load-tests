variable "bucket_artifact_name" {
  description = "Name of the S3 bucket to codepipeline artifact"
  type        = string
}

variable "env" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name"
  type        = string
}
