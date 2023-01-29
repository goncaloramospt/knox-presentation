variable "SUBSCRIPTION_ID" {
    description = "Azure Tenant Subscription ID"
    type = string
}
variable "CLIENT_ID" {
    description = "Service Principal App ID"
    type = string
}
variable "CLIENT_SECRET" {
    description = "Service Principal Password"
    type = string
}
variable "TENANT_ID" {
    description = "Azure Tenant ID"
    type = string
}
variable "rg_name" {
    description = "Resource Group Name"
    type = string
    default = "knox-tf-rg-486998"
}
variable "rg_location" {
    description = "Resource Group Location"
    type = string
    default = "West Europe"
}
variable "kv_name" {
    description = "Azure Key Vault Name"
    type = string
    default = "knox-tf-kv-486998"
}
variable "kv_location" {
    description = "Azure Key Vault Location"
    type = string
    default = "West Europe"
}
variable "kv_enabled_for_deployment" {
    description = "Azure Key Vault Enabled for Deployment"
    type = string
    default = "true"
}
variable "kv_enabled_for_disk_encryption" {
    description = "Azure Key Vault Enabled for Disk Encryption"
    type = string
    default = "true"
}
variable "kv_enabled_for_template_deployment" {
    description = "Azure Key Vault Enabled for Deployment"
    type = string
    default = "true"
}
variable "kv_sku_name" {
    description = "Azure Key Vault SKU (Standard or Premium)"
    type = string
    default = "standard"
}
variable "kv_secret_name" {
    description = "Azure Key Vault Secret Name"
    type = string
    default = "TerraformSecretVault"
}
variable "kv_secret_value" {
    description = "Azure Key Vault Secret Value"
    type = string
    default = "Terraform Secret"
}
variable "app_config_name" {
    description = "App Config Name"
    type = string
    default = "knox-tf-app-config-486998"
}