terraform {
  required_version = ">= 0.14.0"

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 5.2.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.38.0"
    }
  }
}

provider "vault" {
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
