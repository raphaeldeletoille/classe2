#terraform init
#terraform plan
#terraform apply 

resource "azurerm_resource_group" "rg" {
  name     = "exampleraphrg"
  location = "West Europe"
}
resource "azurerm_resource_group" "count_rg" {
  count = 2

  name     = "${var.my_name}${count.index}"
  location = "West Europe"
}

## DEPLOYER 2 RG (West Europe, West US) avec FOR_EACH
## VOUS ALLEZ AVOIR BESOIN D UNE VARIABLE DE TYPE MAP

resource "azurerm_resource_group" "all_rg" {
  for_each = var.rg_map

  name     = each.value.name
  location = each.value.location
}
