# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
  required_version = ">= 0.14.9"
}
provider "azurerm" {
  skip_provider_registration = "true"
  features {}

  subscription_id = var.SUBSCRIPTION_ID
  client_id = var.CLIENT_ID
  client_secret = var.CLIENT_SECRET
  tenant_id = var.TENANT_ID
}
locals {
  config_mapping = {
    mykey = "myvalue"
    mykey2 = "myvalue2"
    mykey3 = "myvalue3"
    mykey4 = "myvalue4"
  }
}

data "azurerm_client_config" "current" {}

# Generate a random integer to create a globally unique name
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

# Create the resource group
resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.rg_location
}

# Create the Azure Key Vault
resource "azurerm_key_vault" "key-vault" {
  name = var.kv_name
  location = var.kv_location
  resource_group_name = var.rg_name

  enabled_for_deployment = var.kv_enabled_for_deployment
  enabled_for_disk_encryption = var.kv_enabled_for_disk_encryption
  enabled_for_template_deployment = var.kv_enabled_for_template_deployment

  tenant_id = var.TENANT_ID
  sku_name = var.kv_sku_name

  access_policy {
        tenant_id = data.azurerm_client_config.current.tenant_id
        object_id = data.azurerm_client_config.current.object_id
        key_permissions = ["Create", "Get", "List", "Purge", "Recover",]
        secret_permissions = ["Get", "List", "Purge", "Recover", "Set"]
        certificate_permissions = ["Create", "Get", "List", "Purge", "Recover", "Update"]
    }

  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_key_vault_secret" "key-vault-secret" {
    name = var.kv_secret_name
    value = var.kv_secret_value
    key_vault_id = azurerm_key_vault.key-vault.id
    depends_on = [azurerm_resource_group.rg, azurerm_key_vault.key-vault]
}

# App Config Provision
resource "azurerm_app_configuration" "appconf" {
  name                = var.app_config_name
  resource_group_name = var.rg_name
  location            = var.rg_location
}

resource "null_resource" "demo_config_values" {
  for_each = local.config_mapping

  provisioner "local-exec" {
    command = "az appconfig kv set --connection-string $CONNECTION_STRING --key $KEY --value $VALUE --yes"

    environment = {
      CONNECTION_STRING = azurerm_app_configuration.appconf.primary_write_key.0.connection_string
      KEY               = each.key
      VALUE             = each.value
    }
  }

}

# Create the Linux App Service Plan
resource "azurerm_service_plan" "appserviceplan" {
  name                = "webapp-asp-${random_integer.ri.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"
}

# Create the web app, pass in the App Service Plan ID
resource "azurerm_linux_web_app" "webapp" {
  name                  = "knox-tf-webapp-test"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  service_plan_id       = azurerm_service_plan.appserviceplan.id
  #https_only            = true
  site_config { 
   # minimum_tls_version = "1.2"
  }
}

#  Deploy code from a public GitHub repo
resource "azurerm_app_service_source_control" "sourcecontrol" {
  app_id             = azurerm_linux_web_app.webapp.id
  repo_url           = "https://github.com/goncaloramospt/knox-presentation/"
  branch             = "main"
  use_manual_integration = true
  use_mercurial      = false
}