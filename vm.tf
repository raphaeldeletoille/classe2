resource "azurerm_network_interface" "card" {
  name                = "raph-nic"
  location            = azurerm_resource_group.all_rg["rg1"].location
  resource_group_name = azurerm_resource_group.all_rg["rg1"].name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet[1].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip.id
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = "raph-machine"
  resource_group_name = azurerm_resource_group.all_rg["rg1"].name
  location            = azurerm_resource_group.all_rg["rg1"].location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.card.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_public_ip" "ip" {
  name                = "raph-ip"
  resource_group_name = azurerm_resource_group.all_rg["rg1"].name
  location            = azurerm_resource_group.all_rg["rg1"].location
  allocation_method   = "Static"
}