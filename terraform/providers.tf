terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend configuration
  # NOTE: The bucket must be created manually or via bootstrap script before running init.
  # We use S3 for state storage and native locking (available in recent Terraform versions with S3).
  # Uncomment and configure after creating the bucket.
  # backend "s3" {
  #   bucket         = "proxecto-asir-tfstate-UNIQUEID" # Replace UNIQUEID
  #   key            = "terraform.tfstate"
  #   region         = "us-east-1" # Or your region
  #   encrypt        = true
  #   use_lockfile   = true
  # }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "Dev"
      ManagedBy   = "Terraform"
    }
  }
}
