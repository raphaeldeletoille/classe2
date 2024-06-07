#DEPLOYER UN LOG ANALYTICS WORKSPACE 

#ENVOYEZ LES LOGS ET METRICS DE VOTRE KEYVAULT (DIAGNOSTIC SETTING) SUR LE LOG ANALYTICS "GLGL"
#CE LOG ANALYTICS EXISTE DEJA, VOUS DEVREZ UTILISER UN DATASOURCE
data "azurerm_log_analytics_workspace" "CECINESTPASMONLOGANALYTICS" {
  name                = "glgl"
  resource_group_name = "salut"
}

resource "azurerm_log_analytics_workspace" "lw" {
  name                = "raph-01"
  location            = azurerm_resource_group.count_rg[0].location #  azurerm_resource_group.all_rg["rg1"].location 
  resource_group_name = azurerm_resource_group.count_rg[0].name #  azurerm_resource_group.all_rg["rg1"].name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_diagnostic_setting" "rule" {
  name               = "sendlogfromkvtolw"
  target_resource_id = azurerm_key_vault.kv.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.CECINESTPASMONLOGANALYTICS.id 

  enabled_log {
    category = "AuditEvent"

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}

#DEPLOYER GRAFANA (AZURERM_DASHBOARD_GRAFANA)
#DONNER LE DROIT "Grafana Admin" à votre compte utilisateur sur votre grafana  (Role_Assignment)
#DONNER LE DROIT "Monitoring Reader" à l'identité de votre Grafana sur votre souscription (Role_Assignment)
#ACCEDEZ A VOTRE GRAFANA 