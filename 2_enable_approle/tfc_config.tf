# Create the workspace

resource "tfe_workspace" "vault_demo" {
  name         = "tfc-vault-approle-demo"
  organization = var.tfc_organization
  description  = "Demo workspace for Vault AppRole authentication"
}

# Populate the variables for the workspace
locals {
  workspace_variables = {
    tenant_id = {
      value     = data.azuread_client_config.current.tenant_id
      category  = "terraform"
      sensitive = false
    }
    subscription_id = {
      value     = data.azurerm_subscription.current.subscription_id
      category  = "terraform"
      sensitive = false
    }
    approle_path = {
      value     = vault_auth_backend.approle.path
      category  = "terraform"
      sensitive = false
    }
    role_id = {
      value     = vault_approle_auth_backend_role.tfc_dev.role_id
      category  = "terraform"
      sensitive = false
    }
    secret_id = {
      value     = vault_approle_auth_backend_role_secret_id.tfc_dev.secret_id
      category  = "terraform"
      sensitive = true
    }
    vault_azure_secret_backend_path = {
      value     = "azure-dev"
      category  = "terraform"
      sensitive = false
    }
    vault_azure_secret_backend_role_name = {
      value     = "dev-role"
      category  = "terraform"
      sensitive = false
    }
    vault_namespace = {
      value     = var.vault_namespace
      category  = "terraform"
      sensitive = false
    }
    vault_address = {
      value     = var.vault_address
      category  = "terraform"
      sensitive = false
    }
  }
}

resource "tfe_variable" "approle_variables" {
  for_each     = local.workspace_variables
  key          = each.key
  value        = each.value["value"]
  sensitive    = each.value["sensitive"]
  category     = each.value["category"]
  workspace_id = tfe_workspace.vault_demo.id
}
