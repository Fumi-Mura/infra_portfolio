terraform {
  required_version = "1.9.0"

  required_providers {
    aws = {
      version = "5.59.0"
      source  = "hashicorp/aws"
    }
  }
}