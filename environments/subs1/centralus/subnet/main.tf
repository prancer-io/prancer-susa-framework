resource "azurerm_subnet" "subnet" {
  name                                           = var.subnet_name
  virtual_network_name                           = var.vnet_name
  resource_group_name                            = var.resource_group
  address_prefixes                               = var.subnet_address_prefixes
  service_endpoints                              = ["Microsoft.KeyVault", "Microsoft.Sql"]
  enforce_private_link_endpoint_network_policies = true
}
