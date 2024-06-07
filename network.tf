resource "azurerm_virtual_network" "vnet" {
  name                = "raph-network"
  location            = azurerm_resource_group.all_rg["rg1"].location
  resource_group_name = azurerm_resource_group.all_rg["rg1"].name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]
}

resource "azurerm_subnet" "subnet" {
  count                = 3
  name                 = "subnet${count.index}"
  resource_group_name  = azurerm_resource_group.all_rg["rg1"].name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.${count.index}.0/24"]

  #1ER SUBNET = 10.0.0.0 / 10.0.0.255
  #2eme SUBNET = 10.0.1.0 / 10.0.1.255
  #...

  # delegation {
  #   name = "delegation"

  #   service_delegation {
  #     name    = "Microsoft.ContainerInstance/containerGroups"
  #     actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
  #   }
  # }
}