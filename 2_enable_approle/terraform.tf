terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~>3.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }

    tfe = {
      source  = "hashicorp/tfe"
      version = "~>0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "vault" {
  namespace = var.vault_namespace
}