terraform {
  required_version = ">= 1.8.4"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.0"
    }
    postgresql = {
      source = "cyrilgdn/postgresql"
      version = ">=1.22.0"
    }
  }
}