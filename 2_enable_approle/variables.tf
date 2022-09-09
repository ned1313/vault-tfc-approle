variable "vault_namespace" {
  type        = string
  description = "(Optional) The namespace to use on the Vault instance. Defaults to null"
  default     = null
}

variable "vault_address" {
  type        = string
  description = "(Required) The address of the Vault instance"
}

variable "tfc_organization" {
  type        = string
  description = "(Required) The Terraform Cloud organization to use for the workspace."
}