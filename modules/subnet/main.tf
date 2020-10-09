resource "azurerm_subnet" "sub" {
  name                                           = var.subnet_name
  resource_group_name                            = var.subnet_rg
  virtual_network_name                           = var.vnet_name
  address_prefixes                               = var.address_prefixes
  service_endpoints                              = var.service_endpoints
  enforce_private_link_endpoint_network_policies = var.enforce_private_link
}
