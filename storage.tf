# #DEPLOYER UN STORAGE ACCOUNT DANS VOTRE RG EN "COOL"

# resource "azurerm_storage_account" "storage" {
#   name                     = "kjhkjqbfjbqfqf"
#   resource_group_name      = azurerm_resource_group.rg.name
#   location                 = azurerm_resource_group.rg.location
#   account_tier             = "Standard"
#   account_replication_type = "GRS"
#   access_tier              = "Cool" 
# }
# #DEPLOYER UN storage_container DANS NOTRE STORAGE ACCOUNT

# resource "azurerm_storage_container" "container" {
#   name                  = "vhds"
#   storage_account_name  = azurerm_storage_account.storage.name
#   container_access_type = "private"
# }
# # (OPTIONAL)GENEREZ UNE SAS KEY POUR ACCEDER A VOTRE CONTAINER STORAGE ET L AFFICHER DANS VOTRE TERMINAL
# # TELECHARGEZ AZURE STORAGE EXPLORER POUR VOUS CONNECTER SUR VOTRE CONTAINER ET Y DEPOSER CE QUE VOUS VOULEZ
# data "azurerm_storage_account_blob_container_sas" "sas_key" {
#   connection_string = azurerm_storage_account.storage.primary_connection_string
#   container_name    = azurerm_storage_container.container.name
#   https_only        = true

#   ip_address = "83.118.207.194"

#   start  = "2018-03-21"
#   expiry = "2030-03-21"

#   permissions {
#     read   = true
#     add    = true
#     create = false
#     write  = false
#     delete = true
#     list   = true
#   }

#   cache_control       = "max-age=5"
#   content_disposition = "inline"
#   content_encoding    = "deflate"
#   content_language    = "en-US"
#   content_type        = "application/json"
# }

# output "sas_url_query_string" {
#   value = data.azurerm_storage_account_blob_container_sas.sas_key.sas
#   sensitive = false
# }