resource "azurerm_mssql_server" "sqlsrv" {
  name                         = "exampleraphsqlsrv"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = "West US"
  version                      = "12.0"
  administrator_login          = "missadministrator"
  administrator_login_password = random_password.password[0].result #azurerm_key_vault_secret.mdpSQL.value
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
  name                        = "sql-db"
  server_id                   = azurerm_mssql_server.sqlsrv.id
  collation                   = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb                 = 4
  min_capacity                = 1
  read_scale                  = false
  sku_name                    = "GP_S_Gen5_2"
  zone_redundant              = false
  enclave_type                = "VBS"
  auto_pause_delay_in_minutes = 60
}