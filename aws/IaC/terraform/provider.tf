provider "aws" {
  region  = var.region
  profile = var.profile

  default_tags {
    tags = {
      terraform_managed = "true"
      Project           = var.project
      env               = var.env
    }
  }
}

terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "devops-tests-core"
    key    = "k6-test-loads/dev/us-east-1/k6/terraform.tfstate"
    region = "us-east-1"
    # external_id = "XXXXXXXXXXX"
    # role_arn    = "arn:aws:iam::999999999999:role/k6-tests-load-s3-role"
  }
}
