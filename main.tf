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
  name     = "exampleraphrg"
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
  name                        = "examplevaultraph"
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
  name                         = "exampleraphsqlsrv"
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

## DEPLOYER 2 RESOURCE GROUP DEPUIS LE MEME BLOC (COUNT)
## METTRE UNE VARIABLE DANS LE NOM DE VOTRE RESOURCE

resource "azurerm_resource_group" "count_rg" {
  count = 2

  name = "${var.my_name}${count.index}"
  location = "West Europe"
}

## DEPLOYER 2 RG (West Europe, West US) avec FOR_EACH
## VOUS ALLEZ AVOIR BESOIN D UNE VARIABLE DE TYPE MAP

resource "azurerm_resource_group" "foreach_rg" {
  for_each = var.rg_map

  name = each.value.name 
  location = each.value.location
}

#DEPLOYER 1 VIRTUAL NETWORK DANS LE RG WEST EUROPE (DE VOTRE FOR_EACH)
#DEPLOYER 3 SUBNETS AVEC COUNT DANS CE VNET

resource "azurerm_virtual_network" "vnet" {
  name                = "raph-network"
  location            = azurerm_resource_group.foreach_rg["rg1"].location
  resource_group_name = azurerm_resource_group.foreach_rg["rg1"].name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
}

resource "azurerm_subnet" "subnet" {
  count                = 3
  name                 = "subnet${count.index}"
  resource_group_name  = azurerm_resource_group.foreach_rg["rg1"].name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.${count.index}.0/24"] 

  #1ER SUBNET = 10.0.0.0 / 10.0.0.255
  #2eme SUBNET = 10.0.1.0 / 10.0.1.255
  #...

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.ContainerInstance/containerGroups"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}

#DEPLOYER 1VM EN LINUX OU WINDOWS SERVER DANS VOTRE SUBNET 2
#VOUS CONNECTER A VOTRE VM DEPUIS VOTRE PC 

# SIZE OU SKU --> 	Standard_F2