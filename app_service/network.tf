resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.vnet_address_space
  dns_servers         = var.vnet_dns_servers

  tags = var.tags
}

resource "azurerm_subnet" "subnet" {
  name                                           = var.subnet_name
  virtual_network_name                           = azurerm_virtual_network.vnet.name
  resource_group_name                            = azurerm_resource_group.rg.name
  address_prefixes                               = var.subnet_address_prefixes
  service_endpoints                              = ["Microsoft.KeyVault", "Microsoft.Sql"]
  enforce_private_link_endpoint_network_policies = true
}
