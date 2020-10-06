resource "azurerm_virtual_network" "vnet" {
  name                = "prancer-app-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  tags = {
    environment = "Production"
    project     = "Prancer App"
  }
}

resource "azurerm_subnet" "subnet" {
  name                                           = "prancer-app-subnet"
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  resource_group_name                            = azurerm_resource_group.rg.name
  address_prefixes                               = ["10.0.10.0/24"]
  enforce_private_link_endpoint_network_policies = true
}
