terraform {
  required_version = ">= 1.8.4"
  required_providers {
    local = {
      source = "hashicorp/local"
      version = ">= 2.5.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.51"
    }
  }
}