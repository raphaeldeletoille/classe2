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

data "azurerm_subscription" "primary" {
}

resource "azurerm_dashboard_grafana" "grafana" {
  name                              = "raph-grafana"
  resource_group_name               = azurerm_resource_group.rg.name
  location                          = "West Europe"
  api_key_enabled                   = true
  deterministic_outbound_ip_enabled = true
  public_network_access_enabled     = true

  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_role_assignment" "grafana_permission" {
  role_definition_name = "Monitoring Reader"
  scope = data.azurerm_subscription.primary.id
  principal_id = azurerm_dashboard_grafana.grafana.identity[0].principal_id
}
resource "azurerm_role_assignment" "my_user_permission" {
  role_definition_name = "Grafana Admin"
  scope = azurerm_dashboard_grafana.grafana.id 
  principal_id = data.azurerm_client_config.current.object_id
}

User (classe2, Grafana Admin) --> Grafana (identité, Monitoring Reader) --> Logs & Metrics 

#DEPLOYER GRAFANA (AZURERM_DASHBOARD_GRAFANA)
#DONNER LE DROIT "Grafana Admin" à votre compte utilisateur sur votre grafana  (Role_Assignment)
#DONNER LE DROIT "Monitoring Reader" à l'identité de votre Grafana sur votre souscription (Role_Assignment)
#ACCEDEZ A VOTRE GRAFANA 