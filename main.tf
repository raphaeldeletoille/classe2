terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.95.0"
    }
  }
}

provider "azurerm" {
    features {
    }
}

#terraform init
#terraform plan
#terraform apply 

resource "azurerm_resource_group" "rg" {
  name     = "rgraphdkjsdhqk"
  location = "West Europe"
}

#DEPLOYER UN KEYVAULT AVEC TERRAFORM 
#DEPLOYER UN SECRET DANS VOTRE KEYVAULT AVEC TERRAFORM

#POUR VOIR SI VOUS ETES CONNECTES : az account list
#POUR SE CONNECTER : az login
#POUR SE DECONNECTER : az logout

data "azurerm_client_config" "current" {}

# data "azurerm_resource_group" "NOTMYRG" {
#   name = "notmyrg"
# }

resource "azurerm_key_vault" "kv" {
  name                        = "raphkeyvaultqkfjh"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover",
      "List"
    ]
  }
}

resource "azurerm_key_vault_secret" "mdpSQL" {
  name         = "secret-sauce"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.kv.id
}

#GENEREZ UN MDP ALEATOIRE ET FAIRE EN SORTE QU IL SOIT LA VALEUR DE VOTRE SECRET
# 25 carac min
# 1 maj
# 1 caractère spécial 
resource "random_password" "password" {
  length           = 25
  special          = true
  upper            = true 
  min_upper        = 1
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

#DEPLOYER UN MSSQL SERVEUR POUR LA LOCATION "francecentral","West US", "East US". 
#RENDRE VOTRE COMPTE UTILISATEUR ADMIN DE VOTRE SERVEUR SQL
#SECURISEZ LE COMPTE LOCAL SQL AVEC VOTRE PASSWORD PRESENT DANS VOTRE KEYVAULT

resource "azurerm_mssql_server" "sqlsrv" {
  name                         = "raphsqlsrvsefiuh"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = "West US"
  version                      = "12.0"
  administrator_login          = "missadministrator"
  administrator_login_password = random_password.password.result #azurerm_key_vault_secret.mdpSQL.value
  minimum_tls_version          = "1.2"

  azuread_administrator {
    login_username = "AzureAD Admin"
    object_id      = data.azurerm_client_config.current.object_id
  }
}

#DEPLOYER UN MSSQL DATABASE SUR VOTRE MSSQL SERVER
#SKU_NAME / SKU = GP_S_Gen5_2
#ALLER SUR LE PORTAIL AZURE, ALLEZ SUR VOTRE DATABASE, ALLEZ DANS QUERY

resource "azurerm_mssql_database" "sqldb" {
  name           = "sql-db"
  server_id      = azurerm_mssql_server.sqlsrv.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb    = 4
  min_capacity   = 1 
  read_scale     = false
  sku_name       = "GP_S_Gen5_2"
  zone_redundant = false
  enclave_type   = "VBS"
  auto_pause_delay_in_minutes = 60
}