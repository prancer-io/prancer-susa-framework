resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group
  address_space       = var.vnet_address_space
  dns_servers         = var.vnet_dns_servers

  tags = var.tags
}
