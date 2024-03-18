terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.21"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4.2"
    }
  }
  required_version = ">= 1.5.0"
}

