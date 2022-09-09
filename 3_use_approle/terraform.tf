terraform {
  cloud {
    organization = "ned-in-the-cloud"

    workspaces {
      name = "tfc-vault-approle-demo"
    }
  }
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~>3.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}